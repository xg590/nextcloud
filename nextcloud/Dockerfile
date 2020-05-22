FROM ubuntu:latest  
ENV TZ=Europe/Amsterdam 
# America/New_York
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
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
RUN a2enmod ssl
COPY 000-default.conf /etc/apache2/sites-enabled/000-default.conf
RUN mkdir -p /var/www/html/
RUN chown -R www-data:www-data /var/www/html/
USER www-data 
WORKDIR /var/www/html/
RUN wget https://download.nextcloud.com/server/releases/latest.tar.bz2 >/dev/null 2>&1 
RUN tar jxvf latest.tar.bz2 
RUN rm latest.tar.bz2 
RUN mkdir /var/www/html/nextcloud/data   
COPY --chown=www-data:www-data autoconfig.php /var/www/html/nextcloud/config/autoconfig.php
USER root 
CMD ["apachectl", "-D", "FOREGROUND"]
