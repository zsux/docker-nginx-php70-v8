#!/bin/bash
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export LANGUAGE="en_US.UTF-8"
export DEBIAN_FRONTED="noninteractive"

mkdir -p /var/run/php
rm -rf /etc/supervisor/conf.d/*
rm -rf /etc/nginx/sites-enabled/default
rm -rf /var/www/html/index.nginx-debian.html
ln -s /usr/sbin/php-fpm7.1 /usr/local/sbin/php-fpm
mkdir -p /var/log/supervisor /var/run/sshd /etc/nginx/global /usr/local/etc/php/conf.d/ /usr/local/etc/ /usr/local/etc/php-fpm.d/

groupadd --gid 1001 www
useradd --uid 1001 --gid www --shell /bin/bash --create-home www

mkdir /code/
rm -rf /etc/motd
#chown -R www:www /code/
rm -f /usr/bin/python
ln -s /usr/bin/python3 /usr/bin/python
sed -i "s/python/python2/g" /usr/bin/supervisord
sed -i "s/python/python2/g" /usr/bin/supervisorctl
sed -i "s/alias php-xdebug/#alias php-xdebug/g" /etc/bash.bashrc
sed -i "s/\/etc\/motd/#\/etc\/motd/g" /etc/bash.bashrc

echo "alias ll='ls -al'" >> /etc/bash.bashrc
#echo "alias php-xdebug='/usr/bin/php -dzend_extension=xdebug.so -dxdebug.remote_enable=1'" >> /etc/bash.bashrc
