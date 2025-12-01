#!/bin/bash
set -e
ARTIFACT_DIR="/tmp/code_deploy_artifact"
RELEASE_DIR="/var/www/releases/$(date +%Y%m%d%H%M%S)"
CURRENT_SYMLINK="/var/www/current"

echo "AfterInstall: Unpacking artifact to ${RELEASE_DIR}"
mkdir -p "${RELEASE_DIR}"
unzip -o "${ARTIFACT_DIR}/laravel-deploy.zip" -d "${RELEASE_DIR}"

# copy shared .env if present on server (recommended)
if [ -f /var/www/shared/.env ]; then
  echo "Copying shared .env into release"
  cp /var/www/shared/.env "${RELEASE_DIR}/.env"
fi

# prepare shared storage and symlink
mkdir -p /var/www/shared/storage
if [ -d "${RELEASE_DIR}/storage" ]; then
  rm -rf "${RELEASE_DIR}/storage"
fi
ln -s /var/www/shared/storage "${RELEASE_DIR}/storage" || true

# ensure bootstrap cache directory exists
mkdir -p "${RELEASE_DIR}/bootstrap/cache"

# set permissions (www-data group)
chown -R www-data:www-data "${RELEASE_DIR}"
chmod -R 775 "${RELEASE_DIR}/storage" "${RELEASE_DIR}/bootstrap/cache" || true

# run composer install on target (production)
if command -v composer >/dev/null 2>&1; then
  echo "Running composer install in ${RELEASE_DIR}"
  cd "${RELEASE_DIR}"
  composer install --no-dev --prefer-dist --optimize-autoloader --no-interaction || true
fi

# optionally create storage symlink inside public if public/storage needed
if [ -d "${RELEASE_DIR}/storage/app/public" ]; then
  ln -sfn "${RELEASE_DIR}/storage/app/public" "${RELEASE_DIR}/public/storage" || true
fi

echo "AfterInstall complete"
