### Let's deploy a Nextcloud in an Amazon Lightsail Instance 
1. [Create AWS Account and Access Keys](https://docs.aws.amazon.com/powershell/latest/userguide/pstools-appendix-sign-up.html)
2. Bought a domain from [Google Domain](https://domains.google/)
3. Run [Jupyter_notebook](https://github.com/xg590/nextcloud/blob/master/Create_LightSail_Instance.ipynb) to create Amazon Lightsail Instance
4. [Manage google domain name servers](https://support.google.com/domains/answer/3290309) 
5. Login the Instance and run the automatic installation script
```shell
wget https://raw.githubusercontent.com/xg590/nextcloud/master/Lightsail.sh 
sudo bash Lightsail.sh www.yourdomain.com youremail@gmail.com
```
6. Enable the <i>Nextcloud Talk</i>
7. From the Nextcloud console main page, click the Settings icon on the upper-right side of the navigation bar. Choose + Apps then find talk and enable it. 
  
  
