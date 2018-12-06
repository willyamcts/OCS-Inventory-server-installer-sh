#!/bin/bash

packages=("apache2" "libmysqlclient15-dev" "php5" "php5-gd" "php5-mysql" "php5-curl" "php5-imap" "php5-ldap" "libapache-dbi-perl" "libnet-ip-perl" "libsoap-lite-perl" "libapache2-mod-perl2" "libxml-simple-perl" "libcompress-zlib-perl" "libdbi-perl" "libdbd-mysql-perl" "make")

function check() {
	clear; printf "Installed\t\t\Pack\n\n"

	for pack in "${packages[@]}"; do

		dpkg-query -W $pack 1>/dev/null 2>/dev/stdout
		[ $? == 0 ] && \
			printf "  [ OK ] \t\t%s \t\t\t \n" $pack || \
				printf "  [  X  ] \t\t%s \n" $pack

	done
}

check
