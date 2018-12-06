#!/bin/bash


# Setting Proxy in Perl
confProxyToPerl() {

	clear; echo; printf "	Possui proxy em sua rede? [s/N]: "
	read input

	if [ $input == "y" ] || [ $input == "s" ]; then
		printf "\n\nInforme o [endereço]:[porta]: "
		read addressProxy
		
		printf "\nInforme nome de usuário para o proxy: "
		read userProxy
		
		printf "Informe senha para o usuário %s: " $userProxy
		read -s pwdProxy
	fi

	# Configure connection CPAN with proxy;
	perl -e shell -MCPAN << OE
	yes
	o conf http_proxy 'http://'${addressProxy}
	o conf ftp_proxy 'http://'${addressProxy}
	o conf proxy_user ${userProxy}
	o conf proxy_pass ${pwdProxy}
	o conf commit
	quit
OE

	unset input addressProxy userProxy pwdProxy
	
}

confProxyToPerl