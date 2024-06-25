## Single-instance HTTPS using certbot

Minimal example of https (tls) setup for an application running in a *single-instance* Elastic Beanstalk environment on AWS.

### Highlights

- Specifically for ***single-instance*** environments (i.e. *without* load balancer)
- Uses [Amazon Linux 2023][4]
- Uses [Nginx][5]
- Uses a combination of [`.platform`][3] and `.ebextensions` for configuration
- Uses [`certbot`][1] to obtain certificates automatically from [Let's Encrypt][2]
- Includes redirect from HTTP to HTTPS

### Notes

- If you are using a load balanced environment, it is much simpler to [terminate https at the application load balancer][6], with the help of AWS Certificate Manager.
- This example uses Python, but the config should work for other platforms as well.

### Getting started

1. Spin up a default Elastic Beanstalk environment using a single instance running Python on Amazon Linux 2023 (use e.g. the default example app).
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
