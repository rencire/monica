#!/bin/bash

# Create a bunch of folders under the clean /var that php, nginx, and mysql expect to exist
mkdir -p /var/lib/mysql
mkdir -p /var/lib/mysql-files
mkdir -p /var/lib/nginx
mkdir -p /var/lib/php/sessions
mkdir -p /var/log
mkdir -p /var/log/mysql
mkdir -p /var/log/nginx
# Wipe /var/run, since pidfiles and socket files from previous launches should go away
# TODO someday: I'd prefer a tmpfs for these.
rm -rf /var/run
mkdir -p /var/run/php
rm -rf /var/tmp
mkdir -p /var/tmp
mkdir -p /var/run/mysqld

# Ensure mysql tables created
HOME=/etc/mysql /usr/sbin/mysqld --initialize


# Symlink /opt/app/storage to /var/storage


# Spawn mysqld, php
HOME=/etc/mysql /usr/sbin/mysqld --skip-grant-tables &
/usr/sbin/php-fpm7.2 --nodaemonize --fpm-config /etc/php/7.2/fpm/php-fpm.conf &
# Wait until mysql and php have bound their sockets, indicating readiness
while [ ! -e /var/run/mysqld/mysqld.sock ] ; do
    echo "waiting for mysql to be available at /var/run/mysqld/mysqld.sock"
    sleep .2
done
while [ ! -e /var/run/php/php7.2-fpm.sock ] ; do
    echo "waiting for php-fpm7.2 to be available at /var/run/php/php7.2-fpm.sock"
    sleep .2
done


# Ensure db exists
#echo "CREATE DATABASE IF NOT EXISTS monica; CREATE USER IF NOT EXISTS 'homestead'@'localhost' IDENTIFIED BY 'secret'; GRANT ALL ON monica.* TO 'homestead'@'localhost'; FLUSH PRIVILEGES;" | mysql --user root --socket /var/run/mysqld/mysqld.sock

# run migrations
php /opt/app/artisan setup:production -v


# Start nginx.
/usr/sbin/nginx -c /opt/app/.sandstorm/service-config/nginx.conf -g "daemon off;"
