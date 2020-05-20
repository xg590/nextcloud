# Dockerize/容器化 Nextcloud
## 概述
Nextcloud是一个云应用平台，本身具有文件共享功能，同时可以通过插件进行视频，语音，文字交流。这里我们把它Nextcloud部署到自己的服务器上，形成一个社交平台。Nextcloud强制要求使用SSL加密消息，因此要求服务器本身拥有域名。本文试图将Nextcloud容器化，以便迁移和简化部署过程。容器container技术为程序提供了标准、一致、孤立的运行环境，确保软件运行依赖的全部资源都在容器中。用户拿到记录资源详情的配置文件，使用非常简单的命令，就能让程序运行起来。比如此例，仅需改动几个配置文件，然后运行，我们就能得到Nextcloud这个社交平台。
## Highlights 
* Apache + PHP + Nextcloud + MariaDB
* Maximum customization: public file sharing (https://my_domain_name/file) and private cloud (https://my_domain_name/cloud) at the same time.
* database is accessible from <i>intranet</i>
## Plan
1. Using official image of MariaDB
2. Build a personalized image, in which the apache2 and php are installed. 
3. In the same image, nextcloud is placed in /var/www/html/nextcloud while pulic files are in /var/www/html/file
## Procedure
1. [Install](https://github.com/xg590/tutorials/blob/master/docker/setup.md) docker-compose 此处我们安装docker-compose
2. [Get](https://github.com/xg590/tutorials/blob/master/LetsEncrypt.md) ssl certificate from <i>let's encrypt</i> 此处我们为服务器配置SSL证书<br>
Now a public cert (<i>fullchain.pem</i>) and a private key (<i>privkey.pem</i>) appears in <i>/etc/letsencrypt/live/my_domain_name/</i>现在我们可以在前述目录里找到证书和密钥。
3. Place this [repository](https://github.com/xg590/nextcloud/archive/master.zip) on server把这个项目的复制到本地
4. Edit ./docker-compose.yml 修改一下路径，保证指向证书和密钥，修改一下路径，把我们想分享的文件夹添上
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
7. Edit ./nextcloud/autoconfig.php (You need the following account info to manage the nextcloud) 自动部署文件，有了它，我们就能跳过nextcloud提示我们设置管理员密码的页面
```
  "adminlogin"    => "admin_name",                
  "adminpass"     => "admin_passwd", 
``` 
8. Start services (It may take mins) 启动社交平台
```
  docker-compose up
```
总的来说，安装docker，配置证书，复制项目，修改配置文件，启动。
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
