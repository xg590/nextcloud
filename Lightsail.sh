#!/bin/bash
domain_name=$1 # Change this to your domain name
email=$2       # Provide Email to Electronic Frontier Foundation

# Random Variables
mysql_dbname=$(cat /dev/urandom | tr -dc 'a-zA-Z' | fold -w 10 | head -n 1)
mysql_dbuser=$(cat /dev/urandom | tr -dc 'a-zA-Z' | fold -w 10 | head -n 1)
mysql_dbpass=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
nextcloud_admin_username=$(cat /dev/urandom | tr -dc 'a-z' | fold -w 3 | head -n 1)$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 7 | head -n 1)
nextcloud_admin_passwd=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)

# Install php mariadb certbot
echo "libssl1.1 libraries/restart-without-asking boolean true" | debconf-set-selections # Prevent prompt when update ssl library
apt update -y && apt install -y php-gd                 \
                                php-xml                \
                                php-zip                \
                                php-intl               \
                                php-curl               \
                                php-mysql              \
                                php-imagick            \
                                php-mbstring           \
                                mariadb-server         \
                                libapache2-mod-php     \
                                python-certbot-apache
# Get SSL certificate
certbot --apache --agree-tos --non-interactive --email $email -d $domain_name

# Install Nextcloud
nextcloud_dir=/var/www/nextcloud
sed  -i "s|DocumentRoot /var/www/html|DocumentRoot $nextcloud_dir|g" /etc/apache2/sites-enabled/000-default-le-ssl.conf
wget -O nextcloud.tar.bz2 https://download.nextcloud.com/server/releases/latest.tar.bz2
tar jxf nextcloud.tar.bz2 -C /var/www/
wget -O spreed.tgz https://github.com/nextcloud/spreed/releases/download/v9.0.3/spreed-9.0.3.tar.gz
tar zxf spreed.tgz -C $nextcloud_dir/apps
rm -rf /var/lib/apt/lists/* nextcloud.tar.bz2 spreed.tgz
cat << EOF > $nextcloud_dir/config/autoconfig.php
<?php
\$AUTOCONFIG = array(
  "dbtype"        => "mysql",
  "dbname"        => "$mysql_dbname",
  "dbuser"        => "$mysql_dbuser",
  "dbpass"        => "$mysql_dbpass",
  "dbhost"        => "127.0.0.1:3306",
  "dbtableprefix" => "",
  "adminlogin"    => "$nextcloud_admin_username",
  "adminpass"     => "$nextcloud_admin_passwd",
  "directory"     => "$nextcloud_dir/data",
);
EOF
chown -R www-data:www-data $nextcloud_dir

# Configure Database
mysqladmin create $mysql_dbname
mysql $mysql_dbname << EOF
CREATE USER '$mysql_dbuser'@'localhost' IDENTIFIED BY '$mysql_dbpass';
GRANT ALL ON $mysql_dbname.* TO '$mysql_dbuser'@'localhost' IDENTIFIED BY '$mysql_dbpass' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF

# Document Some Sensitive Info
cat << EOF > /root/nextcloud_admin.info
MySQL Database Info:
  dbname    : $mysql_dbname
  dbuser    : $mysql_dbuser
  dbpassword: $mysql_dbpass
Nextcloud Administrator Account Info:
  Admin_username, Admin_password = $nextcloud_admin_username, $nextcloud_admin_passwd
Where to visit nextcloud:
  https://$domain_name
EOF
systemctl restart apache2
