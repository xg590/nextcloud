FROM ubuntu:latest  
ENV TZ=Europe/Amsterdam 
# America/New_York
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt update 
RUN apt install -y wget apache2        \
				   php-curl            \
				   php-gd              \
				   php-mysql           \
				   php-mbstring        \
				   php-xml             \
				   php-zip             \
				   php-intl            \
				   php-imagick         \
				   libapache2-mod-php 
				   
RUN rm -rf /var/lib/apt/lists/*    
RUN wget https://download.nextcloud.com/server/releases/latest.tar.bz2 >/dev/null 2>&1 
RUN mkdir -p /var/www/html/ 
RUN tar jxvf latest.tar.bz2 -C /var/www/html/
RUN rm latest.tar.bz2   
RUN chown -R www-data:www-data /var/www/html/nextcloud
RUN a2enmod ssl
COPY 000-default.conf /etc/apache2/sites-enabled/000-default.conf 
CMD ["apachectl", "-D", "FOREGROUND"]
