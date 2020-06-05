# Dockerize/容器化 Nextcloud
## Chinese Summary/中文概述
* Nextcloud是一个文件云，但通过安装插件[talk](https://github.com/xg590/nextcloud/blob/master/README.md#install-talk)可以进行视频通话和文字聊天。 
* Nextcloud强制要求使用SSL加密链接，因此<h3>要求参与部署的服务器本身必须拥有域名。</h3> 
* 容器技术(containerization)为程序提供了标准、一致、孤立的运行环境，确保软件运行依赖的全部资源都在容器中。
* 此例中，仅需运行命令并根据提示输入信息，Nextcloud就会部署于服务器上。  
## Prerequisite获得SSL证书是先决条件: 
* [Get a SSL certificate](https://github.com/xg590/tutorials/blob/master/LetsEncrypt.md) from <i>Let's Encrypt</i> 拿一个免费SSL证书: <br> A public cert (<i>fullchain.pem</i>) and a private key (<i>privkey.pem</i>) could be found in <i>/etc/letsencrypt/live/my_domain_name/</i> 在前述目录里可以找到证书和密钥至关重要。
* [Docker-compose](https://github.com/xg590/tutorials/blob/master/docker/setup.md) is also required.
## Automatic installation of nextcloud自动安装
```
    sudo su
    # Uncomment this if you are going to use privileged port (port_num < 1024) during test
    # /sbin/sysctl -w net.ipv4.ip_unprivileged_port_start=443 # One-time test
    # echo 'net.ipv4.ip_unprivileged_port_start=0' > /etc/sysctl.d/50-unprivileged-ports.conf && sysctl --system # permanent setting
    username=ceshifornc
    adduser $username
    usermod -aG docker $username
    usermod -aG sudo $username
    su - $username
    wget https://raw.githubusercontent.com/xg590/tutorials/master/docker/automatic_installation_of_nextcloud.sh
    bash automatic_installation_of_nextcloud.sh
```
   * Clean after 
```
   sudo su
   deluser --remove-home ceshifornc 
``` 
## Useful docker command
```
docker ps
docker exec container_name sh -c "ls -l /var/www/html"
docker-compose down
docker container ls -f 'status=exited'
docker container prune -f
docker image rm nextcloud-master_nextcloud
docker image prune -f 
docker volume prune -f
```
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
docker exec --user www-data nextcloud sh -c "php /var/www/html/nextcloud/occ user:lastseen <username>" 
```
#### Add new user/新增用户 
```
docker exec --user www-data nextcloud sh -c "export OC_PASS=newpassword; php /var/www/html/nextcloud/occ user:add --password-from-env  --display-name=\"Fred Jones\" --group=\"users\" fred"
``` 
#### Install talk
The app is called Talk in Nextcloud GUI but Spreed in OCC<br>
安装talk插件，应用商店里下载nextcloud talk进行聊天
```
docker exec --user www-data nextcloud sh -c "php /var/www/html/nextcloud/occ app:install spreed"
docker exec --user www-data nextcloud sh -c "php /var/www/html/nextcloud/occ app:enable spreed"
```
Dismiss this warning "PHP Fatal error: Cannot declare class OCA\Talk\Migration\Version2000Date20170707093535, ... ..."
#### Transfer Ownership of Files/Folder
```
docker exec --user www-data nextcloud sh -c 'php /var/www/html/nextcloud/occ files:transfer-ownership --path="Video" old_owner new_owner'
```
