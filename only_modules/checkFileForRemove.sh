#!/bin/bash

	# Search content "GET /ocsreports/themes/OCS/logo.png" in log access apache for remove file install.php - is loop
:( [ -f /usr/share/ocsinventory-reports/ocsreports/install.php ] && grep "GET /ocsreports/themes/OCS/logo.png" /var/log/apache2/access.log && rm /usr/share/ocsinventory-reports/ocsreports/install.php || :); :