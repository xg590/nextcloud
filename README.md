# Dockerized Nextcloud
## Highlights
* Apache + PHP + Nextcloud + MariaDB
* Maximum customization: public file sharing (https://my_domain_name/file) and private cloud (https://my_domain_name/cloud) at the same time.
## Plan
1. Using official image of MariaDB
2. Build a personalized image, in which the apache2 and php are installed. 
3. In the same image, nextcloud is placed in /var/www/html/nextcloud while pulic files are in /var/www/html/file
## Procedure
1. [Install](https://github.com/xg590/tutorials/blob/master/docker/setup.md) docker-compose
2. [Get](https://github.com/xg590/tutorials/blob/master/LetsEncrypt.md) ssl certificate from <i>let's encrypt</i><br>
Now a public cert (<i>fullchain.pem</i>) and a private key (<i>privkey.pem</i>) appears in <i>/etc/letsencrypt/live/my_domain_name/</i>
3. Place this repository on server
4. Change configurations<br>
4.1 Edit ./docker-compose.yml 
```
  services:
    db:
      environment:
        - MYSQL_ROOT_PASSWORD=123456
        - MYSQL_DATABASE=dbname
        - MYSQL_USER=username
        - MYSQL_PASSWORD=passwd 
    nextcloud:
      volumes:
        - /etc/letsencrypt/live/my_domain_name/fullchain.pem:/ssl/fullchain.pem:ro
        - /etc/letsencrypt/live/my_domain_name/privkey.pem:/ssl/privkey.pem:ro  
        - /path_to_a_directory_you_like:/var/www/html/file:ro 
```
4.2 Edit ./nextcloud/000-default.conf
```
  <VirtualHost *:443>
  	ServerName my_domain_name
  </VirtualHost>
```
4.3 Edit ./nextcloud/Dockerfile
```
# Change the Time Zone 
ENV TZ=Europe/Amsterdam 
``` 
5. Start services
```
docker-compose up
```
