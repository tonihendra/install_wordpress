#!/bin/bash

# Update system
sudo apt update -y && sudo apt upgrade -y

# Install Apache
sudo apt install apache2 -y

# Install MySQL
sudo apt install mysql-server -y
sudo mysql_secure_installation

# Install PHP and required extensions
sudo apt install php libapache2-mod-php php-mysql php-cli php-curl php-zip php-gd php-mbstring php-xml php-soap php-intl -y

# Restart Apache to apply PHP installation
sudo systemctl restart apache2

# Download and configure WordPress
cd /var/www/html
sudo wget https://wordpress.org/latest.tar.gz
sudo tar -xvzf latest.tar.gz
sudo mv wordpress/* .
sudo rm -rf wordpress latest.tar.gz

# Set ownership and permissions
sudo chown -R www-data:www-data /var/www/html/
sudo chmod -R 755 /var/www/html/

# Create WordPress database
DBNAME=wordpress_db
DBUSER=wordpress_user
DBPASS=your_password_here

sudo mysql -e "CREATE DATABASE ${DBNAME};"
sudo mysql -e "CREATE USER '${DBUSER}'@'localhost' IDENTIFIED BY '${DBPASS}';"
sudo mysql -e "GRANT ALL PRIVILEGES ON ${DBNAME}.* TO '${DBUSER}'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

# Configure Apache for WordPress
sudo bash -c 'cat << EOF > /etc/apache2/sites-available/wordpress.conf
<VirtualHost *:80>
    ServerAdmin admin@example.com
    DocumentRoot /var/www/html
    ServerName example.com
    ServerAlias www.example.com

    <Directory /var/www/html/>
        AllowOverride All
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF'

sudo a2ensite wordpress.conf
sudo a2enmod rewrite
sudo systemctl restart apache2

# Final message
echo "Installation and configuration complete. Please finish the WordPress setup through your web browser."