#!/bin/bash

# Move the file
sudo mv /var/www/html/wp-config-sample.php /var/www/html/wp-config.php

# Replace database_name_here with $database_name
sudo sed -i "s/database_name_here/${database_name}/" /var/www/html/wp-config.php

# Replace username_here with $database_username
sudo sed -i "s/username_here/${database_username}/" /var/www/html/wp-config.php

# Replace password_here with $database_password
sudo sed -i "s/password_here/${database_password}/" /var/www/html/wp-config.php

# Replace localhost with $database_host
sudo sed -i "s/localhost/${database_host}/" /var/www/html/wp-config.php



