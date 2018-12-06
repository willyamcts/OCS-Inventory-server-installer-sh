#!/bin/bash

##
# Author: Willyam da S. C. de Castro
#
# Description: Install and configure OCS Inventory server;
#
#
##

###############################################################
###################### VARIABLES ##############################

readonly RED='\033[1;31m'
readonly GREEN='\033[0;32m'
readonly DEFAULT_COLOR='\033[0;0m'

readonly PACKAGES=("apache2" "libmysqlclient15-dev" "php5" "php5-gd" "php5-mysql" "php5-curl" "php5-imap" "php5-ldap" "libapache-dbi-perl" "libnet-ip-perl" "libsoap-lite-perl" "libapache2-mod-perl2" "libxml-simple-perl" "libio-compress-perl" "libdbi-perl" "libdbd-mysql-perl" "make")

readonly PID=$(echo $0 | cut -d'/' -f2)


###############################################################
###################### Functions ##############################

# Funcao que verifica se os pacotes foram instalados
function checkPackInstalled() {
	# $1 is package name

	[ $1 ] || (clear && printf %s '\n\tNome de pacote requerido. - call checkPackInstalled\n' && read && exit)

	dpkg-query -W $1 1>/dev/null 2>/dev/stdout
	[ $? == 0 ] && \
		printf "  [ ${GREEN}OK ${DEFAULT_COLOR}] \t\t%s \t\t\t \n" $1 && return 0 || \
			printf "  [ ${RED}X ${DEFAULT_COLOR}] \t\t${RED}%s ${DEFAULT_COLOR}\n" $1 && return 1
}

# Install packages
function installPackages() {

	for pack in "${PACKAGES[@]}"; do

		apt-get install -y $pack 1>/dev/null 2>/dev/stdout

		checkPackInstalled $pack
	done
}


# Setting from Data Base, create and set user and password
configMySQL() {
	# $1 is username
	# $2 is password
	#[ $1 && $2 ] || printf "Requer usuário e senha, respectivamente. - call configMySQL\n"
	
	printf "\n\n ENTRE COM A SENHA DE ROOT DO MYSQL\n"
	mysql -u root -p << OE
	CREATE DATABASE ocsweb character set utf8;
	CREATE USER "$1"@localhost IDENTIFIED BY "$2";
	GRANT ALL PRIVILEGES ON ocsweb.* TO "$1"@localhost;
	flush privileges;
	exit
OE

	[ $? == 0 ] && (printf "\n\n\tDatabase criada, usuário e senha definidos..." && sleep 7) || (printf "\n\n\t Usuário não foi criado na DB, execute novamente." && killall $PID)

}

# Setting install OCS NG SERVER, after you have downloaded and extracted OCS NG Server
configFilesOCS() {

	# Setting parameters from DB in OCS
	sed -i "/PerlSetEnv OCS_DB_USER/ s/R .*/R $1/" /etc/apache2/conf-enabled/z-ocsinventory-server.conf
	sed -i "/PerlSetVar OCS_DB_PWD/ s/D .*/D $2/" /etc/apache2/conf-enabled/z-ocsinventory-server.conf
		
	
	sed -i '/SESSION/d' /usr/share/ocsinventory-reports/ocsreports/dbconfig.inc.php
	declare -i line=$(cat -n /usr/share/ocsinventory-reports/ocsreports/dbconfig.inc.php | grep ?php | cut -f1)
	line=$(($line + 1))
	
	sed -i ""$line"s/^/define\(\"DB_NAME\", \"ocsweb\"\);\ndefine\(\"SERVER_READ\",\"localhost\"\);\ndefine\(\"SERVER_WRITE\",\"localhost\"\);\ndefine\(\"COMPTE_BASE\",\""$1"\"\);\ndefine\(\"PSWD_BASE\",\""$2"\"\);\n/" /usr/share/ocsinventory-reports/ocsreports/dbconfig.inc.php


	# Setting parameters in PHP
	sed -i '/max_execution_time\|max_input_time/ s/= .*/= 200/' /etc/php5/apache2/php.ini
	sed -i '/post_max_size\|upload_max_filesize/ s/= .*/= 300M/' /etc/php5/apache2/php.ini
	sed -i '/memory_limit/ s/= .*/= 512M/' /etc/php5/apache2/php.ini

	# Setting parameters in OCS
	sed -i '/php_value post_max_size\|php_value upload_max_filesize/ s/[[:digit:]][[:digit:]][[:digit:]]/300/' /etc/apache2/conf-enabled/ocsinventory-reports.conf
	
	unset line
}

# Step 2 - Settings OCS Server
configureOCS() {
	# Setting DB in MySQL
	clear; printf "\n CONFIGURANDO DB OCS MYSQL\n"
	
	printf "\n Informe um user name para DB OCS: "
	read usernameOCS
	
	printf "\n Informe uma senha para %s: " $usernameOCS
	read -s pwdOCS
	
	configMySQL $usernameOCS $pwdOCS
	
	
	# Changing parameters in OCS
	configFilesOCS $usernameOCS $pwdOCS
		
	unset usernameOCS pwdOCS

	
	clear; printf "\nReiniciando serviço Apache2...\n\n"
	/etc/init.d/apache2 restart

	echo; echo
	printf "\t Acesse via navegador: localhost/ocsreports \n\n"

	# Search content "GET /ocsreports/themes/OCS/logo.png" in log access apache for remove file install.php
	:(){ [ -e /usr/share/ocsinventory-reports/ocsreports/install.php ] && grep "GET /ocsreports/themes/OCS/logo.png" /var/log/apache2/access.log 1>/dev/null && rm /usr/share/ocsinventory-reports/ocsreports/install.php || :&}; :&	
	exit
}


installOCS() {
	[ -z $1 ] && cd /tmp

	(cd ./OCSNG_UNIX_SERVER_2.4.1 && sed -i 's/conf-available/conf-enabled/' setup.sh && \
	clear && echo && \
	echo "+----------------------------------------------------------+" && \
	echo "|  ****                                              ****  |" && \
	echo "|      Apenas pressione <ENTER> em todas as perguntas      |" && \
	echo "|  ****                                              ****  |" && \
	echo "+----------------------------------------------------------+" && \
	./setup.sh) || (printf "\n\tFalha ao executar o arquivo de instalação do OCS..." && killall $PID)
	
	configureOCS
}


###############################################################
###########				Implementation				###########
###############################################################
clear; printf "\n\tAtualizando repositório...."

# Check user is root
[ $USER == "root" ] || printf "\n\tA execução requer root"

case $1 in 
	"step2"|"Step2"|"STEP2") installOCS 0;;
esac


# Check connection and update repository apt-get update
apt-get update 1>/dev/null 2>/dev/null
if [ $? -ne 0 ]; then
	clear
	printf "\tErro ao atualizar o repositorio.\n"
fi


# Install required packages 
clear; echo; printf "     Status\t\t\tPacote\n\n"
installPackages

printf "\n	Tecle < Enter > para continuar"
read



#Install and configure MySQL Server
checkPackInstalled "mysql-server"
[ $? == 1 ] && (clear; printf "\n\t Instalando MySQL Server..."; sleep 7; apt-get install "mysql-server" -y)



# Install modules Perl
clear; printf "\n    Instalando módulos necessários, a instalação pode demorar alguns minutos...\n	Tecle < Enter > para continuar"
read

# Install modules Perl
cpan -f -i Archive::Zip Plack::Handler << OE
	yes
OE
[ $? != 0 ] && (clear; echo; echo; printf "Falha na instalação de módulos Perl" && killall $PID)

cpan -f -i Mojolicious::Lite XML::Entities
[ $? != 0 ] && (clear; echo; echo; printf "Falha na instalação de módulos Perl" && killall $PID)

service apache2 restart



# Download pack OCS Server
clear; printf "\n\t FAZENDO DOWNLOAD OCS SERVER 2.4.1... \n\n"
wget -t 1 -P /tmp -c https://github.com/OCSInventory-NG/OCSInventory-ocsreports/releases/download/2.4.1/OCSNG_UNIX_SERVER_2.4.1.tar.gz

# Install OCS Server in /tmp
[ $? == 0 ] && cd /tmp && tar -xzvf OCSNG_UNIX_SERVER_2.4.1.tar.gz || (clear; printf "\nFalha no download OCS NG Server 2.4.1.\n\n\t Faça o download e extraia o arquivo manualmente e...\n" && printf "\n\t ${RED}Execute ${GREEN}\'"$0" step2\' ${RED}posteriormente\n\n${DEFAULT_COLOR}" && killall $PID 1>/dev/null)

installOCS

printf "\n Instalação finalizada.\n\n\t Tecle < Enter > para sair."
read