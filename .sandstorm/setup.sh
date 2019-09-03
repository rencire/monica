#!/bin/bash

# When you change this file, you must take manual action. Read this doc:
# - https://docs.sandstorm.io/en/latest/vagrant-spk/customizing/#setupsh

set -euo pipefail
apt update

# This is the ideal place to do things like:
#
#    export DEBIAN_FRONTEND=noninteractive
#    apt-get update
#    apt-get install -y nginx nodejs nodejs-legacy python2.7 mysql-server
#
# If the packages you're installing here need some configuration adjustments,
# this is also a good place to do that:
#
#    sed --in-place='' \
#            --expression 's/^user www-data/#user www-data/' \
#            --expression 's#^pid /run/nginx.pid#pid /var/run/nginx.pid#' \
#            --expression 's/^\s*error_log.*/error_log stderr;/' \
#            --expression 's/^\s*access_log.*/access_log off;/' \
#            /etc/nginx/nginx.conf

# By default, this script does nothing.  You'll have to modify it as
# appropriate for your application.

# Install dependencies
apt install -y rsync curl unzip apache2 git
apt install -y gnupg2 apt-transport-https apt-transport-https lsb-release ca-certificates
curl -s https://packages.sury.org/php/apt.gpg -o /etc/apt/trusted.gpg.d/php.gpg 
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list

# Need to reload the package repo? vagrant-spk vm up for first time failed.
# 2nd run w/ vagrant-spk vm provision, still fails, but less php package errors.
apt install -y php7.2 php7.2-cli php7.2-common php7.2-fpm \
    php7.2-json php7.2-opcache php7.2-mysql php7.2-mbstring php7.2-zip \
    php7.2-bcmath php7.2-intl php7.2-xml php7.2-curl php7.2-gd php7.2-gmp

cd /tmp
curl -s https://getcomposer.org/installer -o composer-setup.php
php composer-setup.php --install-dir=/usr/local/bin/ --filename=composer
rm -f composer-setup.php

cd

apt install -y mariadb-server


# Note: whoami is not available. but must be root user, since able to run previous commands w/o sudo?
#echo 'whomai'
#echo `whomai`
# Copy over mounted folder to /var/www/monica
rsync -rv --exclude=.git /opt/app/ /var/www/monica/

exit 0
