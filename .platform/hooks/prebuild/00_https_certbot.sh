#!/bin/bash

# get the current elastic beanstalk environment name
# https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/custom-platforms-scripts.html
BEANSTALK_ENV_NAME=$(/opt/elasticbeanstalk/bin/get-config container -k environment_name) \
&& echo "beanstalk env name is $BEANSTALK_ENV_NAME" || echo "failed to get beanstalk env name"

# get the CNAME for the elastic beanstalk environment
# https://awscli.amazonaws.com/v2/documentation/api/latest/reference/elasticbeanstalk/describe-environments.html#global-options
# - the beanstalk EC2 role needs the "elasticbeanstalk:DescribeEnvironments" permission, otherwise this command returns empty
# - we assume a single region here, but if that's an issue, we could specify `--region $REGION` in the command below, and obtain the value from an env property or from IMDSv2
BEANSTALK_CNAME=$(aws elasticbeanstalk describe-environments --environment-names $BEANSTALK_ENV_NAME --query "Environments[0].CNAME") \
&& echo "beanstalk CNAME is $BEANSTALK_CNAME" || echo "failed to get beanstalk CNAME"
# remove quotes
BEANSTALK_CNAME=${BEANSTALK_CNAME//\"/}

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
if [[ ! $CERTBOT_EMAIL ]]; then CERTBOT_EMAIL="me@example.org"; fi
# could just use ${CERTBOT_EMAIL:-me@example.org} inline...
certbot certonly --nginx -d $BEANSTALK_CNAME -m $CERTBOT_EMAIL --non-interactive --agree-tos

# write nginx https config file
# this is necessary because os environment variables are not available in nginx server blocks
# (https://stackoverflow.com/a/66013834)
config_file_path="/var/app/staging/.platform/nginx/conf.d/https.conf"
echo "writing nginx https config to $config_file_path"
cat > $config_file_path << HERE
# config adapted from https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/https-singleinstance-java.html
# http://nginx.org/en/docs/http/configuring_https_servers.html
server {
    listen              443 ssl;
    server_name  localhost;

    ssl_certificate      /etc/letsencrypt/live/$BEANSTALK_CNAME/fullchain.pem;
    ssl_certificate_key  /etc/letsencrypt/live/$BEANSTALK_CNAME/privkey.pem;

    ssl_session_timeout  5m;

    ssl_protocols  TLSv1 TLSv1.1 TLSv1.2;
    ssl_prefer_server_ciphers   on;

    location / {
        # may need to adapt port (see nginx config on instance)
        proxy_pass  http://localhost:8000;
        proxy_set_header   Connection "";
        proxy_http_version 1.1;
        proxy_set_header        Host            \$host;
        proxy_set_header        X-Real-IP       \$remote_addr;
        proxy_set_header        X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header        X-Forwarded-Proto https;
    }
}
HERE
if [ -s $config_file_path ]
then
  echo "https config created"
  cat $config_file_path
else echo "failed to create https config"
fi
