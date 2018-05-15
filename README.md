# nginx + php-fpm + oci + newrelic
This image is based on [wyveo/nginx-php-fpm] plus:

 - oci8 php extension: to connect with oracle databases
 - newrelic php extension: to grab metrics from application running on container and send to [newrelic], so you can mesure the performace of each endpoint
 ## Versioning

| App | Version |
|--|--|
| nginx | 1.13.12 |
| php-fpm | 7.2.5
| oci8 | 12.2.0.1.0 |
| newrelic | 8.1.0.209

## Running
To run the container:
```
$ sudo docker run -d adelinogaspar/nginx-fpm-oci-newrelic
```
Default web root:
```
/usr/share/nginx/html
```
### Configure Newrelic license on container


[newrelic]: https://newrelic.com/
[wyveo/nginx-php-fpm]: https://hub.docker.com/r/wyveo/nginx-php-fpm/
