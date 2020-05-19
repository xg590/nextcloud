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
4. Edit ./docker-compose.yml 
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
5. Edit ./nextcloud/000-default.conf
```
  <VirtualHost *:443>
  	ServerName my_domain_name
  </VirtualHost>
```
6. Edit ./nextcloud/Dockerfile
```
  # Change the Time Zone 
  ENV TZ=Europe/Amsterdam 
``` 
7. Start services
```
  docker-compose up
```

### Preserve Data
In the above <b>docker-compose.yaml</b>, we have
```
services:
  db: 
    volumes:
      - db_vol:/var/lib/mysql  
```
*  If mount host directory to container in volume, then the data of each user will retain at <i>/var/www/nextcloud</i> of host machine.
``` 
    volumes:
      - /var/lib/mysql:/var/lib/mysql
```
* If name a volume and the data will stay at <i>/var/lib/docker/volumes/</i>
``` 
    volumes:
      - db_vol:/var/lib/mysql
``` 
### Refresh Nextcloud and a fresh Nextcloud is born
Remove containers and volumes
```
$ docker-compose rm -v -s -f
$ docker volume ls
$ docker volume prune -f
```
### Nextcloud Console [manual](https://docs.nextcloud.com/server/18/admin_manual/configuration_server/occ_command.html)
```
$ docker-compose exec --user www-data nextcloud_fpm_version php occ
$ docker-compose exec --user www-data nextcloud_fpm_version php occ user:lastseen <username>
$ docker-compose exec --user www-data nextcloud_fpm_version php occ user:add --display-name="ABC" abc 
```

