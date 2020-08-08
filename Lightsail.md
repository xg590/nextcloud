### Let's deploy a Nextcloud in an Amazon Lightsail Instance
Summary: Buy computational power (<i>Lightsail Instance</i>) from Amazon --> Attach a static IP to the instance --> Buy domain and manage the DNS records --> Get a free SSL certificate --> Install docker --> Run Nextcloud Installation Script --> Install the <i>Nextcloud Talk</i> since it is no longer pre-installed.
1. [Create](https://lightsail.aws.amazon.com/ls/docs/en_us/articles/how-to-create-amazon-lightsail-instance-virtual-private-server-vps) an Amazon Lightsail instance (1GB memory at least)
2. [Create](https://lightsail.aws.amazon.com/ls/docs/en_us/articles/lightsail-create-static-ip) a static IP and attach it to an instance in Amazon Lightsail
3. I bought a domain from [Google Domain](https://domains.google/) but decide to [transfer](https://lightsail.aws.amazon.com/ls/docs/en_us/articles/lightsail-how-to-create-dns-entry) (see Step 2) the management of its DNS records to Lightsail (, then Amazon will provide DNS service). You should buy a domain form Google/Amazon/Godaddy or ... if you have none.
4. [Get](https://github.com/xg590/tutorials/blob/master/LetsEncrypt.md) a free <i>Let's Encrypt</i> SSL certificate
5. [Install](https://github.com/xg590/tutorials/blob/master/docker/setup.md) the docker-compose 
6. Automatic Installation of Nextcloud -- Be careful with the prompt.
```shell
sudo su
wget https://raw.githubusercontent.com/xg590/nextcloud/master/automatic_installation_of_nextcloud.sh
bash automatic_installation_of_nextcloud.sh
```
* Better stop httpd and free https/443 port.
* Follow the prompt, create a port forwarding rule in <i>iptable</i> if you chose a non-443 port for Nextcloud. 
* Must [create](https://lightsail.aws.amazon.com/ls/docs/en_us/articles/amazon-lightsail-editing-firewall-rules#firewall-adding-rules) a new firewall rule for Nextcloud on the Lightsail instance.
7. [Install](https://github.com/xg590/nextcloud#install-talk) a Nextcloud application <i>talk<i>
