# Docker PHP Apache2

Simple Docker PHP 5.6 + Apache/2.4.25 container.

## Inside Container

* php5.6
* Apache/2.4.25
* Git
* bash
* nano


## PHP Modules

* php5.6-gd
* php5.6-mcrypt
* php5.6-mbstring
* php5.6-intl
* php5.6-mysql
* php5.6-zip
* php5.6-json
* php5.6-soap
* php5.6-xml
* php5.6-bcmath
* php5.6-mysqli

## Build Container

```bash
docker build --tag odenktools/php5.6-apache2:1.0.0 .

docker tag odenktools/php5.6-apache2:1.0.0 odenktools/php5.6-apache2:latest

docker push odenktools/php5.6-apache2:1.0.0

docker push odenktools/php5.6-apache2:latest
```

## How to use

```bash
docker network create odenktools-net
```

Simple running.

```bash
docker run -d --name php_sample \
--net=odenktools-net \
--publish 80:80 \
-d odenktools/php5.6-apache2:latest
```

Linking with another container.

```bash
docker run -d --name php_sample \
--net=odenktools-net \
--publish 80:80 \
--link mysql:mysql \
-d odenktools/php5.6-apache2:latest
```

Linking with another container + mount existing code.

For Windows OS

```bash
docker run -d --name php_sample \
--net=odenktools-net \
--publish 80:80 \
--link mysql:mysql \
--mount type=bind,source=/d/git/php-script,target=/var/www \
-d odenktools/php5.6-apache2:latest
```

```bash
docker run -d --name php_sample \
--net=odenktools-net \
--publish 80:80 \
--link mysql:mysql \
--mount type=bind,source=/var/www/php-script,target=/var/www \
-d odenktools/php5.6-apache2:latest
```

## Running Laravel 5.2 Inside Container

```bash
cat <<EOF > $(pwd)/config/000-default.conf
<VirtualHost *:80>
    ServerAdmin odenktools@gmail.com
    DocumentRoot /var/www/html/public
    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF
```

```
docker run -d --name laravel \
--net=odenktools-net \
--link mysql:mysql \
--publish 80:80 \
--mount type=bind,source=/var/www/laravel.5-2,target=/var/www/html \
-v ./config:/etc/apache2/sites-available \
odenktools/docker-php-apache2:latest
```