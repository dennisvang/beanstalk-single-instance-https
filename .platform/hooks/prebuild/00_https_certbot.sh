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
# make lowercase
# https://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html
# this is necessary, because certbot converts the domain to lowercase for the file path ( although not mentioned in the docs)
# https://eff-certbot.readthedocs.io/en/latest/using.html#where-are-my-certificates
BEANSTALK_CNAME=${BEANSTALK_CNAME,,}

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
certbot certonly --nginx -d $BEANSTALK_CNAME -m $CERTBOT_EMAIL --non-interactive --agree-tos

# write nginx ssl_certificate directives to include in https_server.conf
# this is necessary because os environment variables are not available in nginx server blocks
# (https://stackoverflow.com/a/66013834)
file_path="/var/app/staging/.platform/nginx/certificate.paths"
echo "writing certificate paths to $file_path"
cat > $file_path << HERE
# https://eff-certbot.readthedocs.io/en/stable/using.html#where-are-my-certificates
ssl_certificate      /etc/letsencrypt/live/$BEANSTALK_CNAME/fullchain.pem;
ssl_certificate_key  /etc/letsencrypt/live/$BEANSTALK_CNAME/privkey.pem;
HERE
if [ -s $file_path ]
then
  echo "https config created"
  cat $file_path
else echo "failed to create https config"
fi
