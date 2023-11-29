#!/bin/bash

# Update package information
sudo apt update

# Install Apache2
sudo apt install -y apache2

# Start Apache2 service
sudo systemctl start apache2.service

# Enable Apache2 service to start on boot
sudo systemctl enable apache2.service

# Install PHP and related packages
sudo apt install -y php php-mysql php-cgi php-cli php-gd

# Restart Apache2 after installing PHP
sudo systemctl restart apache2

# Download WordPress
wget https://wordpress.org/latest.zip

# Install unzip
sudo apt install -y unzip

# Unzip WordPress
unzip latest.zip

# Move WordPress files to /var/www/html/
cd wordpress
sudo cp -r * /var/www/html/

# Change ownership to www-data
cd /var/www/html/
sudo chown -R www-data:www-data /var/www/html/

# Set permissions
sudo chmod -R 755 /var/www/html/

# Remove default index.html
sudo rm -rf index.html

sudo mkdir /var/www/html/wp-content/uploads
if [ ! -d "/etc/smbcredentials" ]; then
sudo mkdir /etc/smbcredentials
fi
if [ ! -f "/etc/smbcredentials/tfstate214154.cred" ]; then
    sudo bash -c 'echo "username=tfstate214154" >> /etc/smbcredentials/tfstate214154.cred'
    sudo bash -c 'echo "password=8Nig7uMKdWEm0nkGMFmqh94FS0nORmn/RKcUHUwq3dVY0RLZx1448OiiFutD4A8bl0mnuhc9umYG+AStzfuPqQ==" >> /etc/smbcredentials/tfstate214154.cred'
fi
sudo chmod 600 /etc/smbcredentials/tfstate214154.cred

sudo bash -c 'echo "//tfstate214154.file.core.windows.net/terraformwordpressfileshare /var/www/html/wp-content/uploads cifs nofail,credentials=/etc/smbcredentials/tfstate214154.cred,dir_mode=0777,file_mode=0777,serverino,nosharesock,actimeo=30" >> /etc/fstab'
sudo mount -t cifs //tfstate214154.file.core.windows.net/terraformwordpressfileshare /var/www/html/wp-content/uploads -o credentials=/etc/smbcredentials/tfstate214154.cred,dir_mode=0777,file_mode=0777,serverino,nosharesock,actimeo=30
