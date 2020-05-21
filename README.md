# Dockerize/容器化 Nextcloud
## 中文概述
* Nextcloud是一个云应用平台，本身具有文件共享功能，同时可以通过插件进行视频，语音，文字交流，因此可以将之变为社交工具。 
* Nextcloud强制要求使用SSL加密消息，因此要求<b>参与部署的服务器本身必须拥有域名</b>。
* 本文描述将Nextcloud容器化的过程。
* 容器技术(containerization)为程序提供了标准、一致、孤立的运行环境，确保软件运行依赖的全部资源都在容器中。
* 此例中，仅需改动几个相关的配置文件，容器就能产生于服务器上，提供给用户Nextcloud这个社交工具。
## Highlights 
* Few steps and deploy in minutes
* Maximum customization: public file sharing (https://my_domain_name/file) and private cloud (https://my_domain_name/cloud) at the same time. 
## Plan
1. Using official image of MariaDB
2. Build a personalized image, in which the apache2 and php are installed. 
3. In the same image, nextcloud is placed in /var/www/html/nextcloud while pulic files are in /var/www/html/file
## Prerequisite: 
* [Get](https://github.com/xg590/tutorials/blob/master/LetsEncrypt.md) a ssl certificate from <i>Let's Encrypt</i> 拿一个免费SSL证书<br>
* A public cert (<i>fullchain.pem</i>) and a private key (<i>privkey.pem</i>) could be found in <i>/etc/letsencrypt/live/my_domain_name/</i> 在前述目录里可以找到证书和密钥至关重要。
## Test this repository 
Run following commands and the Nextcloud would be online. The only caveat is about <i>sed</i>. 运行下面几行命令，Nextcloud就能使用了。 
```
sudo su
apt update && apt install -y docker.io 
wget https://github.com/docker/compose/releases/download/1.25.5/docker-compose-Linux-x86_64 -O docker-compose
chmod 555 docker-compose
mv docker-compose /usr/local/bin
wget https://github.com/xg590/nextcloud/archive/master.zip
unzip master.zip
cd nextcloud-master/
sed -i 's/placeholder_domain_name/Here_is_your_domain_name/g' docker-compose.yml nextcloud/000-default.conf
docker-compose up
```
## Clean above test
During the test, username and passwd are default values. Now they should be personalized and a new 
## Procedure
总的来说，安装docker，从letsencrypt处拿到免费的SSL证书，修改容器的配置文件，启动容器，voila。
1. [Install](https://github.com/xg590/tutorials/blob/master/docker/setup.md) docker-compose 此处我们安装docker-compose

3. Place this [repository](https://github.com/xg590/nextcloud/archive/master.zip) on server 把这个项目复制到本地
4. Edit ./docker-compose.yml 修改环境变量，修改证书和密钥路径，把想分享的文件夹添上，把自动配置文件放进容器
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
      - /root/file:/var/www/html/file:ro
      - /etc/letsencrypt/live/my_domain_name/privkey.pem:/ssl/privkey.pem:ro  
      - /etc/letsencrypt/live/my_domain_name/fullchain.pem:/ssl/fullchain.pem:ro
      - /root/nextcloud-master/autoconfig.php:/var/www/html/nextcloud/config/autoconfig.php:ro
```
5. Edit ./nextcloud/000-default.conf 把服务器域名在文件里指出来
```
  <VirtualHost *:443>
  	ServerName my_domain_name
  </VirtualHost>
```
6. Edit ./nextcloud/Dockerfile 依据服务器地址，改变时区设置
```
  # Change the Time Zone 
  ENV TZ=Europe/Amsterdam 
``` 
7. Edit ./autoconfig.php (You need the following account info to manage the nextcloud) 自动部署文件，有了它，我们就能跳过nextcloud提示我们设置管理员密码的[页面](https://github.com/xg590/miscellaneous/blob/master/nextcloud_admin.png)
```
  "dbname"        => "dbname",
  "dbuser"        => "username",
  "dbpass"        => "passwd",
  "adminlogin"    => "admin_name",                
  "adminpass"     => "admin_passwd", 
``` 
8. Start services (It may take mins) 启动社交平台
```
  docker-compose up
```
9. Comment out (using #) one line in ./docker-compose.yml<br>
```
  services: 
    nextcloud:
      volumes: 
#      - /root/nextcloud-master/autoconfig.php:/var/www/html/nextcloud/config/autoconfig.php:ro
```
<b>There will be a serious security problem without deleting autoconfig.php.</b> See the explanation below.[*]
### Useful docker command
```
docker ps
docker exec container_name sh -c "ls -l /var/www/html"
```
### Administration with [Provisional API](https://docs.nextcloud.com/server/stable/admin_manual/configuration_user/user_provisioning_api.html)
#### Create User 编程创建用户
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
### Security concerns

