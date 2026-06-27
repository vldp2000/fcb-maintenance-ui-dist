#!/bin/sh
set -eu

WEB_ROOT="${WEB_ROOT:-/var/www/html}"
SERVICE_NAME="${SERVICE_NAME:-lighttpd}"
REPO_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"

echo "Updating UI dist repository..."
cd "$REPO_DIR"
git pull --ff-only

if [ -z "$WEB_ROOT" ] || [ "$WEB_ROOT" = "/" ]; then
  echo "Refusing to deploy to unsafe WEB_ROOT: $WEB_ROOT" >&2
  exit 1
fi

echo "Deploying UI files to $WEB_ROOT..."
sudo mkdir -p "$WEB_ROOT"

if command -v rsync >/dev/null 2>&1; then
  sudo rsync -a --delete \
    --exclude ".git" \
    --exclude "deploy-to-rpi.sh" \
    --exclude "README.md" \
    "$REPO_DIR"/ "$WEB_ROOT"/
else
  tmp_dir="$(mktemp -d)"
  trap 'rm -rf "$tmp_dir"' EXIT

  cp -a "$REPO_DIR"/. "$tmp_dir"/
  rm -rf "$tmp_dir/.git" "$tmp_dir/deploy-to-rpi.sh" "$tmp_dir/README.md"

  sudo find "$WEB_ROOT" -mindepth 1 -maxdepth 1 -exec rm -rf {} +
  sudo cp -a "$tmp_dir"/. "$WEB_ROOT"/
fi

sudo chown -R www-data:www-data "$WEB_ROOT"

if systemctl list-unit-files "$SERVICE_NAME.service" >/dev/null 2>&1; then
  sudo systemctl reload "$SERVICE_NAME" || sudo systemctl restart "$SERVICE_NAME"
fi

echo "UI deployed."
if [ -f "$WEB_ROOT/version.json" ]; then
  cat "$WEB_ROOT/version.json"
fi
