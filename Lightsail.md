### Let's deploy the Nextcloud on a Amazon Lightsail Instance - A walk-through 
1. [Create](https://lightsail.aws.amazon.com/ls/docs/en_us/articles/how-to-create-amazon-lightsail-instance-virtual-private-server-vps) an Amazon Lightsail instance (768MB memory at least)
2. [Create](https://lightsail.aws.amazon.com/ls/docs/en_us/articles/lightsail-create-static-ip) a static IP and attach it to an instance in Amazon Lightsail
3. I bought a domain from [Google Domain](https://domains.google/) but decide to [transfer](https://lightsail.aws.amazon.com/ls/docs/en_us/articles/lightsail-how-to-create-dns-entry) (see Step 2) the management of its DNS records to Lightsail (, then Amazon will provide DNS service).
4. [Get](https://github.com/xg590/tutorials/blob/master/LetsEncrypt.md) a free <i>Let's Encrypt</i> SSL certificate
5. [Install](https://github.com/xg590/tutorials/blob/master/docker/setup.md) the docker-compose 
6. Automatic Installation of Nextcloud 
* Stop apache2 and free https/443 port.
* Follow admin.info, create a port forwarding in <i>iptable</i> 
* Must [create](https://lightsail.aws.amazon.com/ls/docs/en_us/articles/amazon-lightsail-editing-firewall-rules#firewall-adding-rules) a new firewall rule for Nextcloud on the Lightsail instance.
```shell
root@ip-172-26-0-102:~# wget https://raw.githubusercontent.com/xg590/nextcloud/master/automatic_installation_of_nextcloud.sh
root@ip-172-26-0-102:~# bash automatic_installation_of_nextcloud.sh
```
7. [Install](https://github.com/xg590/nextcloud#install-talk) a Nextcloud application <i>talk<i>
