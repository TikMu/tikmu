# The TikMu server setup

## Installing a new server

Dependencies:

 - Image: Ubuntu 15.10 64-bits
 - ./install-deps ADDRESS

Robrt:

 - ./deploy-robrt LOCAL-ROBRT-DIR SERVER-ADDRESS

Settings:

 - ./deploy-settings LOCAL-ROBRT-DIR SERVER-ADDRESS

Final steps:

 - systemctl enable docker
 - systemctl enable mongodb
 - systemctl enable nginx
 - systemctl enable tora
 - systemctl enable robrt
 - ln -sf /etc/nginx/sites-available/* /etc/nginx/sites-enabled/
 - reboot

