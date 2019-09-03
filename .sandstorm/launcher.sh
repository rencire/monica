#!/bin/bash
set -euo pipefail
# This script is run every time an instance of our app - aka grain - starts up.
# This is the entry point for your application both when a grain is first launched
# and when a grain resumes after being previously shut down.
#
# This script is responsible for launching everything your app needs to run.  The
# thing it should do *last* is:
#
#   * Start a process in the foreground listening on port 8000 for HTTP requests.
#
# This is how you indicate to the platform that your application is up and
# ready to receive requests.  Often, this will be something like nginx serving
# static files and reverse proxying for some other dynamic backend service.
#
# Other things you probably want to do in this script include:
#
#   * Building folder structures in /var.  /var is the only non-tmpfs folder
#     mounted read-write in the sandbox, and when a grain is first launched, it
#     will start out empty.  It will persist between runs of the same grain, but
#     be unique per app instance.  That is, two instances of the same app have
#     separate instances of /var.
#   * Preparing a database and running migrations.  As your package changes
#     over time and you release updates, you will need to deal with migrating
#     data from previous schema versions to new ones, since users should not have
#     to think about such things.
#   * Launching other daemons your app needs (e.g. mysqld, redis-server, etc.)

# By default, this script does nothing.  You'll have to modify it as
# appropriate for your application.

cd /var/www/monica

## DB

# Secure db
# https://stackoverflow.com/questions/24270733/automate-mysql-secure-installation-with-echo-command-via-a-shell-script#27759061
mysql -u root < "mysql_secure_installation.sql"

# Setup db
mysql -u root < "setup_db.sql"
# Setup app key
php artisan key:generate

# Run migrations, seed db, symlink folders
php artisan setup:production -v

## WebServer

# Configure apache webserver
chown -R www-data:www-data /var/www/monica
chmod -R 775 /var/www/monica/storage

# Enable apache webserver rewrite module
a2enmod rewrite

# Copy over `monica.conf` to
cp monica.conf /etc/apache2/sites-available/monica.conf

# Apply new .conf
a2dissite 000-default.conf
a2ensite monica.conf

# Enable php7.2 fpm, and restart apache
a2enmod proxy_fcgi setenvif
a2enconf php7.2-fpm
service php7.2-fpm restart
service apache2 restart

exit 0
