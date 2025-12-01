#!/bin/bash
set -e
echo "BeforeInstall: stopping workers (if any) and preparing directories"

# Stop services if you want to ensure a clean deploy (uncomment if needed)
# systemctl stop supervisor || true
# systemctl stop php8.3-fpm || true

# prepare releases dir & shared storage dir
mkdir -p /var/www/releases
mkdir -p /var/www/shared/storage
# Ensure shared .env location exists (you should place production .env here manually or via Secrets Manager)
mkdir -p /var/www/shared

# ensure ownership for shared
chown -R root:www-data /var/www/shared || true
chmod 750 /var/www/shared || true

echo "BeforeInstall done"
