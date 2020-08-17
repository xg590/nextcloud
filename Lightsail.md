### Let's deploy a Nextcloud in an Amazon Lightsail Instance
Summary: Buy computational power (<i>Lightsail Instance</i>) from Amazon --> Attach a static IP to the instance --> Buy domain and manage the DNS records --> Add a new firewall rule --> Run the automatic installation script --> Enable the <i>Nextcloud Talk</i>.
1. [Create](https://lightsail.aws.amazon.com/ls/docs/en_us/articles/how-to-create-amazon-lightsail-instance-virtual-private-server-vps) an Amazon Lightsail instance (1GB memory at least)
2. [Create](https://lightsail.aws.amazon.com/ls/docs/en_us/articles/lightsail-create-static-ip) a static IP and attach it to an instance in Amazon Lightsail
3. I bought a domain from [Google Domain](https://domains.google/) but decide to [transfer](https://lightsail.aws.amazon.com/ls/docs/en_us/articles/lightsail-how-to-create-dns-entry) (see Step 2) the management of its DNS records to Lightsail (, then Amazon will provide DNS service). You should buy a domain form Google/Amazon/Godaddy or ... if you have none.
4. [Add](https://lightsail.aws.amazon.com/ls/docs/en_us/articles/understanding-firewall-and-port-mappings-in-amazon-lightsail) a new firewall rule "<b>Application HTTPS</b>" to allow the access of Nextcloud service.  
5. Automatic Installation
* Connect securely using your browser -- Click the orange button "Connect using SSH"  
* CUSTOM www.yourdomain.com youremail@gmail.com accordingly!!!
```shell
wget https://raw.githubusercontent.com/xg590/nextcloud/master/Lightsail.sh && sudo bash Lightsail.sh www.yourdomain.com youremail@gmail.com
```
6. Enable the <i>Nextcloud Talk<i>
* From the Nextcloud console main page, click the Settings icon on the upper-right side of the navigation bar. Choose + Apps and then find talk and enable it. 
  
  
