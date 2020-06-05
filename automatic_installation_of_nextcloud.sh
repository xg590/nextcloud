#!/bin/bash
# Creating a non-root user
echo "We are going to create a new non-root user..."
read -e -p 'What name would you like: ' -i "johndoe" non_root_username
adduser $non_root_username
usermod -aG docker $non_root_username
usermod -aG sudo $non_root_username
# Customized Envs
read    -p "Domain name of this server: " domain_name
read -e -p "Port to serve nextcloud: " -i "12345" port
read -e -p "Nextcloud directory you want on host machine: " -i "$(pwd)/nextcloud" nextcloud_dir
read -e -p "SSL certificate on host machine: " -i "/etc/letsencrypt/live/$domain_name/fullchain.pem" cert
read -e -p "SSL private key on host machine: " -i "/etc/letsencrypt/live/$domain_name/privkey.pem" key

# Randomized Envs
mysql_root_password=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
mysql_dbname=$(cat /dev/urandom | tr -dc 'a-zA-Z' | fold -w 10 | head -n 1)
mysql_dbuser=$(cat /dev/urandom | tr -dc 'a-zA-Z' | fold -w 10 | head -n 1)
mysql_dbpass=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
nextcloud_admin_username=$(cat /dev/urandom | tr -dc 'a-zA-Z' | fold -w 10 | head -n 1)
nextcloud_admin_passwd=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)

mkdir -p $nextcloud_dir/data
chown www-data:www-data $nextcloud_dir/data
su - $non_root_username
mkdir -p $nextcloud_dir/app 
# docker-compose directory
cat << EOF > $nextcloud_dir/app/000-default.conf
<VirtualHost *:443>
	ServerName $domain_name
	DocumentRoot /var/www/html
	<Directory /var/www/html/>
		# See https://docs.nextcloud.com/server/18/admin_manual/installation/source_installation.html
		Require all granted
		AllowOverride All
		Options FollowSymLinks MultiViews
		<IfModule mod_dav.c>
			Dav off
		</IfModule>
	</Directory>
    ErrorLog  \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
	# SSL ------------------------------------
    SSLCertificateFile      /var/www/letsencrypt/fullchain.pem
    SSLCertificateKeyFile   /var/www/letsencrypt/privkey.pem
    # --------------------------------------
    # This file (/etc/letsencrypt/options-ssl-apache.conf) contains important security parameters.
	# If you modify this file manually, Certbot will be unable to automatically provide future
    # security updates. Instead, Certbot will print and log an error message with a path to
    # the up-to-date file that you will need to refer to when manually updating this file.
    SSLEngine on
    # Intermediate configuration, tweak to your needs
    SSLProtocol             all -SSLv2 -SSLv3
    SSLCipherSuite          ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA:ECDHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES256-SHA:ECDHE-ECDSA-DES-CBC3-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:DES-CBC3-SHA:!DSS
    SSLHonorCipherOrder     on
    SSLCompression          off
    SSLOptions +StrictRequire
    # -----------------------
</VirtualHost>
EOF

cat << EOF > $nextcloud_dir/app/autoconfig.php
<?php
\$AUTOCONFIG = array(
  "dbtype"        => "mysql",
  "dbname"        => "$mysql_dbname",
  "dbuser"        => "$mysql_dbuser",
  "dbpass"        => "$mysql_dbpass",
  "dbhost"        => "db:3306",
  "dbtableprefix" => "",
  "adminlogin"    => "$nextcloud_admin_username",
  "adminpass"     => "$nextcloud_admin_passwd",
  "directory"     => "/var/www/html/data",
);
EOF

# Dockerfile
cat << EOF > $nextcloud_dir/app/Dockerfile
FROM ubuntu:latest
ENV TZ=Europe/Amsterdam
# America/New_York
RUN ln -snf /usr/share/zoneinfo/\$TZ /etc/localtime && echo \$TZ > /etc/timezone
RUN apt update
RUN apt install -y apache2 wget \
                   php-gd       \
                   php-xml      \
                   php-zip      \
                   php-intl     \
                   php-curl     \
                   php-mysql    \
                   php-imagick  \
                   php-mbstring \
                   libapache2-mod-php
RUN rm -rf /var/lib/apt/lists/*
RUN chown www-data:www-data /var/www
RUN a2enmod ssl
COPY 000-default.conf /etc/apache2/sites-enabled/000-default.conf
USER www-data
WORKDIR /var/www/
RUN  mkdir -p   /var/www/letsencrypt/
COPY $cert $key /var/www/letsencrypt/
RUN  mkdir -p   /var/www/nextcloud/data 
RUN wget https://download.nextcloud.com/server/releases/latest.tar.bz2 >/dev/null 2>&1
RUN tar jxvf latest.tar.bz2 -C /var/www/
RUN rm latest.tar.bz2 
COPY autoconfig.php /var/www/nextcloud/config/autoconfig.php
USER root
CMD ["apachectl", "-D", "FOREGROUND"]
EOF

# docker-compose
cat << EOF > $nextcloud_dir/docker-compose.yml
version: '3'

services:
  db: 
    image: mariadb
    command: --transaction-isolation=READ-COMMITTED --binlog-format=ROW
    restart: always
    volumes:
      - db_vol:/var/lib/mysql
    environment:
      - MYSQL_ROOT_PASSWORD=$mysql_root_password
      - MYSQL_DATABASE=$mysql_dbname
      - MYSQL_USER=$mysql_dbuser
      - MYSQL_PASSWORD=$mysql_dbpass
    networks:
      - intranet

  app: 
    build: ./app
    restart: always
    ports:
      - $port:443
    volumes: 
      - $nextcloud_dir/data:/var/www/nextcloud/data 
    networks:
      - intranet

volumes:
  db_vol:

networks:
  intranet:

EOF
rm -rf $temp_dir
cat << EOF > $nextcloud_dir/admin.info
nextcloud_web : https://$domain_name:$port/
Admin_username: $nextcloud_admin_username
Admin_password: $nextcloud_admin_passwd
EOF
cat << EOF
---------------------------------

    How to start nextcloud:
      cd $nextcloud_dir && docker-compose up
    Where to visit nextcloud:
      https://$domain_name:$port/
    Administration account info:
      Admin_username: $nextcloud_admin_username
      Admin_password: $nextcloud_admin_passwd
      These info are also stored in $nextcloud_dir/admin.info

---------------------------------
EOF
