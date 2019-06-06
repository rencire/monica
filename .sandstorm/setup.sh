#!/bin/bash

# When you change this file, you must take manual action. Read this doc:
# - https://docs.sandstorm.io/en/latest/vagrant-spk/customizing/#setupsh

set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

# https
apt-get install -y apt-transport-https

# Add mysql repo
echo -e "deb http://repo.mysql.com/apt/debian/ stretch mysql-5.7\ndeb-src http://repo.mysql.com/apt/debian/ stretch mysql-5.7" > /etc/apt/sources.list.d/mysql.list
wget -O /tmp/RPM-GPG-KEY-mysql https://repo.mysql.com/RPM-GPG-KEY-mysql
apt-key add /tmp/RPM-GPG-KEY-mysql

# Add php repo
echo -e "deb https://packages.sury.org/php/ stretch main\ndeb-src https://packages.sury.org/php/ stretch main" > /etc/apt/sources.list.d/php.list
wget -O- https://packages.sury.org/php/apt.gpg | apt-key add -


# sudo apt install -y gnupg2 apt-transport-https apt-transport-https lsb-release ca-certificates
# sudo curl -s https://packages.sury.org/php/apt.gpg -o /etc/apt/trusted.gpg.d/php.gpg 
# echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/php.list

# install nginx, git, mysql
apt update
apt-get install -y nginx git mysql-server

echo 'installing php'
apt install -y php7.2 php7.2-cli php7.2-common php7.2-fpm \
    php7.2-json php7.2-opcache php7.2-mysql php7.2-mbstring php7.2-zip \
    php7.2-bcmath php7.2-intl php7.2-xml php7.2-curl php7.2-gd php7.2-gmp


# service nginx stop
# service php7.2-fpm stop
# service mysqld stop

# systemctl disable nginx
# systemctl disable php7.2-fpm
# systemctl disable mysqld
# patch /etc/php/7.2/fpm/pool.d/www.conf to not change uid/gid to www-data
sed --in-place='' \
        --expression='s/^listen.owner = www-data/;listen.owner = www-data/' \
        --expression='s/^listen.group = www-data/;listen.group = www-data/' \
        --expression='s/^user = www-data/;user = www-data/' \
        --expression='s/^group = www-data/;group = www-data/' \
        /etc/php/7.2/fpm/pool.d/www.conf
# patch /etc/php/7.2/fpm/php-fpm.conf to not have a pidfile
sed --in-place='' \
        --expression='s/^pid =/;pid =/' \
        /etc/php/7.2/fpm/php-fpm.conf
# patch /etc/php/7.2/fpm/php-fpm.conf to place the sock file in /var 
sed --in-place='' \
       --expression='s/^listen = \/run\/php\/php7.2-fpm.sock/listen = \/var\/run\/php\/php7.2-fpm.sock/' \
        /etc/php/7.2/fpm/pool.d/www.conf
# patch /etc/php/7.2/fpm/pool.d/www.conf to no clear environment variables
# so we can pass in SANDSTORM=1 to apps
sed --in-place='' \
        --expression='s/^;clear_env = no/clear_env=no/' \
        /etc/php/7.2/fpm/pool.d/www.conf
# patch mysql conf to not change uid, and to use /var/tmp over /tmp
# for secure-file-priv see https://github.com/sandstorm-io/vagrant-spk/issues/195
sed --in-place='' \
        --expression='s/^user\t\t= mysql/#user\t\t= mysql/' \
        --expression='s,^tmpdir\t\t= /tmp,tmpdir\t\t= /var/tmp,' \
        --expression='/\[mysqld]/ a\ secure-file-priv = ""\' \
        /etc/mysql/my.cnf
# patch mysql conf to use smaller transaction logs to save disk space
cat <<EOF > /etc/mysql/conf.d/sandstorm.cnf
[mysqld]
# Set the transaction log file to the minimum allowed size to save disk space.
innodb_log_file_size = 1048576
# Set the main data file to grow by 1MB at a time, rather than 8MB at a time.
innodb_autoextend_increment = 1
EOF

# change permissions (not possible)
# whoami
# chown -R vagrant:www-data /opt/app
# cd /opt/app
# chgrp -R www-data storage bootstrap/cache
# chmod -R ug+rwx storage bootstrap/cache

exit 0
