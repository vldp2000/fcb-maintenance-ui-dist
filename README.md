# FCB Maintenance UI Dist

Built static files for the VGMates FCB1010 maintenance UI.

## Deploy On Raspberry Pi

Clone once:

```bash
cd /home/pi
git clone https://github.com/vldp2000/fcb-maintenance-ui-dist.git
```

Deploy or update:

```bash
cd /home/pi/fcb-maintenance-ui-dist
./deploy-to-rpi.sh
```

The script pulls the latest `main`, deploys the static files to `/var/www/html`,
sets ownership to `www-data:www-data`, and reloads `lighttpd`.

Override defaults if needed:

```bash
WEB_ROOT=/var/www/html SERVICE_NAME=lighttpd ./deploy-to-rpi.sh
```
