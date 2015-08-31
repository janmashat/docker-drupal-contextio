#!/bin/bash

if [ ! -f /var/www/sites/default/settings.php ]; then
	# Upgrade debian packages
	DEBIAN_FRONTEND=noninteractive apt-get update
	DEBIAN_FRONTEND=noninteractive apt-get -y upgrade

	# Start mysql
	/usr/bin/mysqld_safe & 
	sleep 10s
	
	# Generate random passwords 
	DRUPAL_DB="drupal"
	MYSQL_PASSWORD=`pwgen -c -n -1 12`
	DRUPAL_PASSWORD=`pwgen -c -n -1 12`
	echo mysql root password: $MYSQL_PASSWORD
	echo drupal password: $DRUPAL_PASSWORD
	echo $MYSQL_PASSWORD > /mysql-root-pw.txt
	echo $DRUPAL_PASSWORD > /drupal-db-pw.txt
	
	# Create database
	mysqladmin -u root password $MYSQL_PASSWORD 
	mysql -uroot -p$MYSQL_PASSWORD -e "CREATE DATABASE drupal; GRANT ALL PRIVILEGES ON drupal.* \
		TO 'drupal'@'localhost' IDENTIFIED BY '$DRUPAL_PASSWORD'; FLUSH PRIVILEGES;"
	
	# Install Drupal
	rm -rf /var/www/html
	cd /var/www
	drush dl drupal-7.x --drupal-project-rename=html
	cd /var/www/html
	drush site-install standard -y --account-name=admin --account-pass=admin \
		--db-url="mysqli://drupal:${DRUPAL_PASSWORD}@localhost:3306/drupal"
	mkdir /var/www/html/sites/default/files
	chmod a+w /var/www/html/sites/default
	chown -R www-data:www-data .

	# Install PHP-ContextIO
	cd /var/www/html/sites/all/libraries
	git clone https://github.com/contextio/PHP-ContextIO
	cd /var/www/html/sites/all/libraries/PHP-ContextIO
	curl -sS https://getcomposer.org/installer | php
	php composer.phar install

	# Install Context.IO module
	cd /var/www/html
	drush dl contextio
	drush en contextio -y

	# Stop mysql
	killall mysqld
	sleep 10s
fi

supervisord -n
