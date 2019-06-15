# Docker PHP Apache2

Simple Docker PHP 7.2 + Apache/2.4.25 container.

## Inside Container

* php7.2
* Apache/2.4.25
* Git
* bash
* nano
* curl
* unzip
* mysql-client
* build-essential
* g++
* composer 1.7.3



## PHP Modules

* php7.2-gd
* php7.2-mcrypt
* php7.2-mbstring
* php7.2-intl
* php7.2-mysql
* php7.2-zip
* php7.2-json
* php7.2-soap
* php7.2-xml
* php7.2-bcmath
* php7.2-mysqli

## Build Container

```bash
docker build --tag odenktools/php7.2-apache2:1.0.0 .

docker tag odenktools/php7.2-apache2:1.0.0 odenktools/php7.2-apache2:latest

docker push odenktools/php7.2-apache2:1.0.0

docker push odenktools/php7.2-apache2:latest
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
-d odenktools/php7.2-apache2:latest
```

Linking with another container.

```bash
docker run -d --name php_sample \
--net=odenktools-net \
--publish 80:80 \
--link mysql:mysql \
-d odenktools/php7.2-apache2:latest
```

Linking with another container + mount existing code.

For Windows OS

```bash
docker run -d --name php_sample \
--net=odenktools-net \
--publish 80:80 \
--link mysql:mysql \
--mount type=bind,source=/d/git/php-script,target=/var/www \
-d odenktools/php7.2-apache2:latest
```

```bash
docker run -d --name php_sample \
--net=odenktools-net \
--publish 80:80 \
--link mysql:mysql \
--mount type=bind,source=/var/www/php-script,target=/var/www \
-d odenktools/php7.2-apache2:latest
```

## Running Laravel 5.8 Inside Container

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
odenktools/php7.2-apache2:latest
```