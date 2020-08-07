# Dockerize/容器化 Nextcloud
## 中文概述
* Nextcloud是一个文件云，但通过安装插件[talk](https://github.com/xg590/nextcloud/blob/master/README.md#install-talk)可以进行视频通话和文字聊天。 
* Nextcloud强制要求使用SSL加密链接，因此<h3>要求参与部署的服务器本身必须拥有域名。</h3> 
* 容器技术(containerization)为程序提供了标准、一致、孤立的运行环境，确保软件运行依赖的全部资源都在容器中。
* 此例中，仅需运行命令并根据提示输入信息，Nextcloud就会部署于服务器上。
## Summary
* Nextcloud is basically a file-sharing platform, but it could be used to hold a video conferencing after enable a pre-installed app <i> [talk](https://github.com/xg590/nextcloud/blob/master/README.md#install-talk)</i>.
* SSL is compulsory for the public server. A domain name shoud be linked to the server.
* Containerization makes the installation hassle-free.
## Prerequisite/先决条件  
* [Get a free SSL certificate](https://github.com/xg590/tutorials/blob/master/LetsEncrypt.md) from <i>Let's Encrypt</i> 拿一个免费SSL证书: <br> A public cert (<i>fullchain.pem</i>) and a private key (<i>privkey.pem</i>) could be found in <i>/etc/letsencrypt/live/my_domain_name/</i> 在前述目录里可以找到证书和密钥至关重要。
* [Docker-compose](https://github.com/xg590/tutorials/blob/master/docker/setup.md) is also required.
## Lightsail/使用亚马逊云服务器
* Build from scratch.
* In the end, Nextcloud is deployed on an Amazon Lightsail Instance.
* [Here](https://github.com/xg590/nextcloud/blob/master/Lightsail.md) is the walk-through. 
## Automatic installation of nextcloud自动安装 
```
sudo su
wget https://raw.githubusercontent.com/xg590/nextcloud/master/automatic_installation_of_nextcloud.sh
bash automatic_installation_of_nextcloud.sh
``` 
Yes, that's it. Deployment is done.安装完成 
### Administration with [Provisional API](https://docs.nextcloud.com/server/stable/admin_manual/configuration_user/user_provisioning_api.html)
#### Create User/新增用户
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
### Administration with [Nextcloud Console](https://docs.nextcloud.com/server/18/admin_manual/configuration_server/occ_command.html)
#### Latest login timestamp
```
docker exec --user www-data nextcloud sh -c "php /var/www/nextcloud/occ user:lastseen <username>" 
```
#### Add new user/新增用户 
```
docker exec --user www-data nextcloud sh -c "export OC_PASS=newpassword; php /var/www/nextcloud/occ user:add --password-from-env  --display-name=\"Fred Jones\" --group=\"users\" fred"
``` 
#### Install talk
The app is called Talk in Nextcloud GUI but Spreed in OCC<br>
安装talk插件，应用商店里下载nextcloud talk进行聊天
```
docker exec --user www-data nextcloud sh -c "php /var/www/nextcloud/occ app:install spreed"
docker exec --user www-data nextcloud sh -c "php /var/www/nextcloud/occ app:enable spreed"
```
Dismiss this warning "PHP Fatal error: Cannot declare class OCA\Talk\Migration\Version2000Date20170707093535, ... ..."
#### Install talk for Nextcloud 19 @ Jun 06 2020
Since talk is not pre-installed with Nextcloud 19.0.0, we need download it from [app store](https://apps.nextcloud.com/apps/spreed) and install it manually.
```
wget -O /tmp/spreed.tgz https://github.com/nextcloud/spreed/releases/download/v9.0.3/spreed-9.0.3.tar.gz 
sudo -u www-data tar zxvf /tmp/spreed.tgz -C /tmp 
sudo mv /tmp/spreed /somewhere
```
Now mount spreed directory to container, just like what was done to data directory: Edit docker-compose.yml
```
services: 
  app: 
    volumes: 
      - /somewhere/spreed:/var/www/nextcloud/apps/spreed
```
Enable it
```
docker exec --user www-data nextcloud sh -c "php /var/www/nextcloud/occ app:enable spreed"
```
#### Transfer ownership of other's files/folder
```
docker exec --user www-data nextcloud sh -c 'php /var/www/nextcloud/occ files:transfer-ownership --path="Video" old_owner new_owner'
```
#### Copy files from host machine to Nextcloud user in container
Copy files 
```
docker cp /directory_on_host_machine/. nextcloud_container_id:/var/www/nextcloud/data/USERNAME/files/Video/
```
Scan files
```
docker exec --user www-data nextcloud_container_id sh -c 'php /var/www/nextcloud/occ files:scan USERNAME'
``` 
