#!/bin/bash

# install certbot and nginx plugin directly from the AL2023 package repo
# https://docs.aws.amazon.com/linux/al2023/release-notes/all-packages-AL2023.4.html
dnf -y --refresh install certbot
dnf -y install python3-certbot-nginx
certbot --version

# create certificate
# (certificate files end up in /etc/letsencrypt/live/<your domain>)
# also see additional configuration in:
#   - .ebextensions/https.conf
#   - .platform/nginx/conf.d/https.conf
certbot certonly --nginx -d "<your-domain>" -m "<your-email>" --non-interactive --agree-tos
