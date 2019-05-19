#!/bin/bash
# Checks if there's a composer.json, and if so, installs/runs composer.

set -euo pipefail

cd /opt/app

# if [ -f /opt/app/composer.json ] ; then
#     if [ ! -f composer.phar ] ; then
#         curl -sS https://getcomposer.org/installer | php
#     fi
#     php composer.phar install --no-interaction --no-suggest --no-dev
# fi

# link storage folder
sudo rm -rf /var/storage/logs
sudo mkdir -p /var/storage/logs
[ -e /opt/app/storage/logs ] && rm -r /opt/app/storage/logs
ln -s /var/storage/logs /opt/app/storage/logs

