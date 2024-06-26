## Single-instance HTTPS using certbot

Minimal example of HTTPS (TLS) setup using `certbot`, for an application running in a *single-instance* Elastic Beanstalk environment on AWS.

### Features

- specifically for ***single-instance*** environments (i.e. ***without*** load balancer)
- [Amazon Linux 2023][4]
- [nginx][5]
- uses [`certbot`][1] to obtain free certificates automatically from [Let's Encrypt][2]
- redirects from HTTP to HTTPS
- mostly [`.platform`][3] and minimal `.ebextensions`

### Notes

- If you are using a load balanced environment, it is much simpler to [terminate https at the application load balancer][6], with the help of AWS Certificate Manager.
- This example uses Python, but the configuration should work for other platforms as well.

### Getting started

1. Spin up a default Elastic Beanstalk web server environment with a single instance running Python on Amazon Linux 2023 (use e.g. the default example app).
   For convenience, a CloudFormation [template]][7] can be found in the `.cloudformation` folder.
2. Copy the instance's `domain`, e.g. from the Elastic Beanstalk console
3. Clone this repo
4. Make the following replacements:
   - In `.platform/hooks/prebuild/00_https_certbot.sh` replace `<your-domain>` by the instance domain, and replace `<your-email>` by a valid email address.
   - In `.platform/nginx/conf.d/https.conf` replace `<your-domain>` by the instance domain
5. Commit changes and deploy to Elastic Beanstalk.
6. Visit your site to see the result.

[1]: https://certbot.eff.org/
[2]: https://letsencrypt.org/
[3]: https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/platforms-linux-extend.html
[4]: https://docs.aws.amazon.com/linux/al2023/ug/what-is-amazon-linux.html
[5]: https://nginx.org/en/docs/
[6]: https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/configuring-https-elb.html
[7]: .cloudformation/elastic-beanstalk.yml
