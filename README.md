# Dockerize Nextcloud
## Highlights
* Apache + PHP + Nextcloud + MariaDB
* Maximum customization: public file sharing (https://my_domain_name/file) and private cloud (https://my_domain_name/cloud) at the same time.
* database is accessible from <i>intranet</i>
## Plan
1. Using official image of MariaDB
2. Build a personalized image, in which the apache2 and php are installed. 
3. In the same image, nextcloud is placed in /var/www/html/nextcloud while pulic files are in /var/www/html/file
## Procedure
1. [Install](https://github.com/xg590/tutorials/blob/master/docker/setup.md) docker-compose
2. [Get](https://github.com/xg590/tutorials/blob/master/LetsEncrypt.md) ssl certificate from <i>let's encrypt</i><br>
Now a public cert (<i>fullchain.pem</i>) and a private key (<i>privkey.pem</i>) appears in <i>/etc/letsencrypt/live/my_domain_name/</i>
3. Place this [repository](https://github.com/xg590/nextcloud/archive/master.zip) on server
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
7. Edit ./nextcloud/autoconfig.php (You need the following account info to manage the nextcloud)
```
  "adminlogin"    => "admin_name",                
  "adminpass"     => "admin_passwd", 
```
Without a correct autoconfig.php, this would be the page saw at first login<br>
![alt text](https://raw.githubusercontent.com/xg590/nextcloud/master/nextcloud_admin.png "real rover")<br>
8. Start services
```
  docker-compose up
```
### Useful docker command
```
docker ps
docker exec container_name sh -c "ls -l /var/www/html"
```
### Administration with [Provisional API](https://docs.nextcloud.com/server/stable/admin_manual/configuration_user/user_provisioning_api.html)
#### Create User
```
import requests
url     = 'https://personal_domain/ocs/v1.php/cloud/users'
auth    = ('admin_name', 'admin_passwd')
headers = {"OCS-APIRequest": "true", "Content-Type": "application/x-www-form-urlencoded"}
data    = {'userid':'newuser_name', 'password':'newuser_password', 'displayName':'Hewlett'}

r = requests.post(url, auth=auth, headers=headers, data=data)
print(r.text)
```
Anticipated Outcome
```
<?xml version="1.0"?>
<ocs>
  <meta>
    <status>ok</status>
    <statuscode>100</statuscode>
    <message>OK</message>
    <totalitems></totalitems>
    <itemsperpage></itemsperpage>
  </meta>
  <data>
    <id>newuser_name</id>
  </data>
</ocs>
```
### Refresh Nextcloud and a fresh Nextcloud is born
Remove containers and volumes
```
$ docker-compose rm -v -s -f
$ docker volume ls
$ docker volume prune -f
```
