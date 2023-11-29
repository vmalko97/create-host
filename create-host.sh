#!/bin/bash

if [ $1 ]
then
    :
else
    echo "First parameter (virtual host name) is required"
    exit 1
fi

user=$SUDO_USER
vhosts_dir="/var/www/$1"
echo "Creating Virtual Host"
cd /etc/apache2/sites-available
cat <<EOF >> "$1.conf"
<VirtualHost *:80>
  ServerAdmin webmaster@localhost
  ServerName $1
    ServerAlias www.$1
  DocumentRoot $vhosts_dir$2

  <Directory />
    Options All
    AllowOverride All
  </Directory>

  <Directory $vhosts_dir>
    Options All
    AllowOverride All
    Order allow,deny
    allow from all
    Require all granted
  </Directory>
  # Possible values include: debug, info, notice, warn, error, crit, alert, emerg.
  LogLevel warn
  ErrorLog $vhosts_dir/error.log
  CustomLog $vhosts_dir/access.log combined
  ServerSignature On
</VirtualHost>
EOF
mkdir $vhosts_dir
cd /etc/apache2/sites-enabled
ln -s "/etc/apache2/sites-available/$1.conf" "$1.conf"
echo "Editing /etc/hosts"
cat <<EOF >> "/etc/hosts"
127.0.0.1       $1
EOF
echo "Set permissions"
chmod 0777 -R $vhosts_dir
echo "Restarting Apache2"
/etc/init.d/apache2 restart
echo "Finished!"
echo "Local address: $vhosts_dir"
echo "Web address: http://$1"
