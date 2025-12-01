#!/bin/bash
set -e
RELEASE_DIR=$(ls -dt /var/www/releases/* | head -n1)
CURRENT_SYMLINK="/var/www/current"

if [ -z "$RELEASE_DIR" ]; then
  echo "No release found, aborting"
  exit 1
fi

echo "ApplicationStart: switching symlink to ${RELEASE_DIR}"
ln -sfn "${RELEASE_DIR}" "${CURRENT_SYMLINK}"

# ensure ownership/permissions
chown -R www-data:www-data "${RELEASE_DIR}"
chmod -R 775 "${RELEASE_DIR}/storage" "${RELEASE_DIR}/bootstrap/cache" || true

# restart PHP-FPM and Nginx to pick up new release
if systemctl is-enabled --quiet php8.3-fpm 2>/dev/null || systemctl is-active --quiet php8.3-fpm 2>/dev/null; then
  systemctl restart php8.3-fpm || true
fi

if systemctl is-enabled --quiet nginx 2>/dev/null || systemctl is-active --quiet nginx 2>/dev/null; then
  systemctl reload nginx || true
fi

# restart supervisor if present to restart workers
if systemctl is-enabled --quiet supervisor 2>/dev/null || systemctl is-active --quiet supervisor 2>/dev/null; then
  systemctl restart supervisor || true
fi

echo "Start complete. Current -> ${CURRENT_SYMLINK}"
