Sin

Minimal example of https (tls) setup for an application running in a *single-instance* Elastic Beanstalk environment on AWS.

This example uses Python, but the config should work for other platforms as well.

Highlights:

- specifically for *single-instance* environments (i.e. without load balancer)
- for [Amazon Linux 2023][4]
- uses [Nginx][5]
- uses a combination of [`.platform`][3] and `.ebextensions` for configuration
- uses [`certbot`][1] to obtain certificates automatically from [Let's Encrypt][2]
- includes redirect from HTTP to HTTPS

Note: If you are using a load balanced environment, it is much simpler to use the application load balancer to configure https.

[1]: https://certbot.eff.org/
[2]: https://letsencrypt.org/
[3]: https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/platforms-linux-extend.html
[4]: https://docs.aws.amazon.com/linux/al2023/ug/what-is-amazon-linux.html
[5]: https://nginx.org/en/docs/
