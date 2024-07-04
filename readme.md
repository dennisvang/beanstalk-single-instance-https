## Single-instance HTTPS using certbot

Minimal example of HTTPS (TLS) setup using `certbot`, for an application running in a *single-instance* Elastic Beanstalk environment on AWS.

### Features

- specifically for ***single-instance*** environments (i.e. ***without*** load balancer)
- [Amazon Linux 2023][4]
- [nginx][5]
- uses [`certbot`][1] to obtain free certificates automatically from [Let's Encrypt][2]
- redirects from HTTP to HTTPS
- mostly [`.platform`][3] and minimal `.ebextensions`

### Getting started

1. Clone this repo
2. Create an application version from the repo, e.g. using the [eb cli][10]:
   ```bash
   eb appversion --create
   ```
3. Spin up a default Elastic Beanstalk web server environment with a single instance running Python on Amazon Linux 2023:
   - either do it manually, using the Elastic Beanstalk web console or eb cli (select your new application version from the list)
   - or use CloudFormation to create a stack using the [template][7] in the `.cloudformation` folder (specify the S3 key of your new application version, e.g. `temp/app-6fxb-215704_101115830772.zip`)
4. Visit your site to see the result

### Notes

- If you are using a load balanced environment, it is much simpler to [terminate https at the application load balancer][6], with the help of AWS Certificate Manager.
- This example uses Python, but the configuration should work for other platforms as well.
- Also see order of configuration steps in [instance deployment workflow][8].
- To debug certificate issues, you can use e.g. [Let's Debug][9]. 

[1]: https://certbot.eff.org/
[2]: https://letsencrypt.org/
[3]: https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/platforms-linux-extend.html
[4]: https://docs.aws.amazon.com/linux/al2023/ug/what-is-amazon-linux.html
[5]: https://nginx.org/en/docs/
[6]: https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/configuring-https-elb.html
[7]: .cloudformation/elastic-beanstalk.yml
[8]: https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/platforms-linux-extend.html#platforms-linux-extend.workflow
[9]: https://tools.letsdebug.net/cert-search
[10]: https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/eb-cli3.html
