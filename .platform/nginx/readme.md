Here's a simplified version of the *default* Elastic Beanstalk nginx configuration on Amazon Linux 2023, i.e. `/etc/nginx/nginx.conf`:

```
...
http {
    server_tokens off;  
    ...
    include conf.d/*.conf;
    ...
    server {
        listen 80 default_server;        
        ...
        include conf.d/elasticbeanstalk/*.conf;
    }
}
``` 
This implies:

- `*.conf` files from `nginx/conf.d` are loaded into the `http` context
- `*.conf` files from `nginx/conf.d/elasticbeanstalk` are loaded into the main `server` context
