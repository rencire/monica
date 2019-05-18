#!/bin/bash
# Checks if there's a composer.json, and if so, installs/runs composer.

set -euo pipefail

cd /opt/app

if [ -f /opt/app/composer.json ] ; then
    if [ ! -f composer.phar ] ; then
        curl -sS https://getcomposer.org/installer | php
    fi
    php composer.phar install --no-interaction --no-suggest --no-dev
fi

# link storage folder
rm -rf /opt/app/storage/logs/
mkdir -p /var/storage/logs/
ln -s /var/storage/logs /opt/app/storage/logs

