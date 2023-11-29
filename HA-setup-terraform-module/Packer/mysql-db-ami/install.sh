#!/bin/bash

sudo apt update
sudo apt install -y mysql-server
sudo systemctl start mysql.service
sudo systemctl enable mysql.service
echo -e "\n\n\n\n\n" | sudo mysql_secure_installation
sudo sed -i 's/127.0.0.1/0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf 
echo "CREATE DATABASE wordpressdb;" > db.sql
echo "CREATE USER 'wpuser'@'%' IDENTIFIED BY 'Deepu@123#';" >> db.sql
echo "GRANT ALL PRIVILEGES on wordpressdb.* to 'wpuser'@'%';" >> db.sql
echo "FLUSH PRIVILEGES;" >> db.sql
sudo mysql -u root < db.sql
