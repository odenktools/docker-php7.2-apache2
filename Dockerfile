FROM php:7.2.18-apache

MAINTAINER Odenktools <odenktools86@gmail.com>

# https://github.com/docker-library/php/blob/master/7.2/stretch/apache/Dockerfile
# https://github.com/laradock/laradock/blob/master/php-fpm/Dockerfile

ENV TZ=Asia/Jakarta

RUN echo $TZ > /etc/timezone \
    && dpkg-reconfigure -f noninteractive tzdata \
    && echo date.timezone = $TZ > /usr/local/etc/php/conf.d/docker-php-ext-timezone.ini

RUN apt-get -y update \
    && apt-get install -y --no-install-recommends apt-utils && \
    pecl channel-update pecl.php.net

RUN apt-get -y update \
    && apt-get install -y --no-install-recommends \
    build-essential g++ \
    nano \
    curl \
    wget \
    unzip \
    pkg-config \
    libz-dev \
    libjpeg-dev \
    libpng-dev \
    libgmp-dev \
    libfreetype6-dev \
    libxml2-dev \
    zlib1g-dev libicu-dev \
    apache2-utils \
    libcurl4-openssl-dev \
    libssl-dev \
    libkrb5-dev \
    libxslt1-dev \
    libmcrypt-dev \
    unixodbc-dev \
    mysql-client \
    libpq-dev \
    git \
    && apt-get clean \
    && rm -r /var/lib/apt/lists/*

# Install the PHP gd library
RUN docker-php-ext-install gd && \
    docker-php-ext-configure gd \
        --enable-gd-native-ttf \
        --with-jpeg-dir=/usr/lib \
        --with-freetype-dir=/usr/include/freetype2 && \
    docker-php-ext-install gd

RUN docker-php-ext-install pdo pdo_mysql \
    && pecl install mcrypt-1.0.1 \
    && pecl install xdebug \
    && docker-php-ext-install mbstring \
    && docker-php-ext-configure intl \
    && docker-php-ext-install intl \
    && docker-php-ext-install mysqli \
    && docker-php-ext-install pdo_mysql \
    && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
    && docker-php-ext-install pdo_pgsql pgsql \
    && docker-php-ext-install zip \
    && docker-php-ext-install json \
    && docker-php-ext-install soap \
    && docker-php-ext-install xml \
    && docker-php-ext-install bcmath \
    && docker-php-ext-install xsl \
    && docker-php-ext-install gmp \
    && apt-get clean \
    && rm -r /var/lib/apt/lists/*

RUN { \
    echo 'always_populate_raw_post_data=-1'; \
    echo 'log_errors=on'; \
    echo 'display_errors=on'; \
    echo 'upload_max_filesize=1024M'; \
    echo 'post_max_size=1024M'; \
    echo 'memory_limit=-1'; \
    echo 'date.timezone=$TZ'; \
    echo 'xdebug.remote_enable=on'; \
    echo 'xdebug.remote_autostart=1'; \
    echo 'xdebug.remote_port=9001'; \
    echo 'xdebug.remote_handler=dbgp'; \
    echo 'xdebug.remote_connect_back=0'; \
  } > /usr/local/etc/php/php.ini

RUN docker-php-ext-enable intl \
    && docker-php-ext-enable pdo \
    && docker-php-ext-enable gd \
    && docker-php-ext-enable mcrypt \
    && docker-php-ext-enable mbstring \
    && docker-php-ext-enable mysqli \
    && docker-php-ext-enable pdo_mysql \
    && docker-php-ext-enable pdo_pgsql \
    && docker-php-ext-enable pgsql \
    && docker-php-ext-enable zip \
    && docker-php-ext-enable soap \
    && docker-php-ext-enable json \
    && docker-php-ext-enable xml \
    && docker-php-ext-enable xsl \
    && docker-php-ext-enable xdebug \
    && docker-php-ext-install sockets \
    && docker-php-ext-enable bcmath 

ARG INSTALL_AMQP=false

RUN if [ ${INSTALL_AMQP} = true ]; then \
    # download and install manually, to make sure it's compatible with ampq installed by pecl later
    # install cmake first
    apt-get update && \
    apt-get -y install cmake && \
    curl -L -o /tmp/rabbitmq-c.tar.gz https://github.com/alanxz/rabbitmq-c/archive/master.tar.gz && \
    mkdir -p rabbitmq-c && \
    tar -C rabbitmq-c -zxvf /tmp/rabbitmq-c.tar.gz --strip 1 && \
    cd rabbitmq-c/ && \
    mkdir _build && cd _build/ && \
    cmake .. && \
    cmake --build . --target install && \
    # Install the amqp extension
    pecl install amqp && \
    docker-php-ext-enable amqp \
;fi

RUN curl -sSL https://getcomposer.org/download/1.7.3/composer.phar -o /usr/bin/composer \
    && chmod +x /usr/bin/composer

# CLEAN PACKAGES
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    rm /var/log/lastlog /var/log/faillog

RUN mkdir -p /var/www/html && mkdir -p /etc/apache2/ssl

COPY index.html /var/www/html

COPY config/apache2/apache2.conf /etc/apache2/apache2.conf

RUN { \
    echo '<VirtualHost *:80>';\
        echo 'ServerAdmin odenktools@gmail.com';\
        echo 'DocumentRoot /var/www/html';\
        echo 'ErrorLog ${APACHE_LOG_DIR}/error.log';\
        echo 'CustomLog ${APACHE_LOG_DIR}/access.log combined';\
    echo '</VirtualHost>';\
} > /etc/apache2/sites-available/000-default.conf

#RUN sed -i "s/DocumentRoot \/var\/www\/html/DocumentRoot \/var\/www/html/" /etc/apache2/apache2.conf

RUN usermod -u 1000 www-data

RUN chown -R www-data:www-data /var/www/

RUN chmod -R 777 /var/www/

RUN a2enmod rewrite proxy expires headers && service apache2 restart

VOLUME ["/var/www/html", "/var/log/apache2", "/etc/apache2/sites-available"]

WORKDIR /var/www/html

EXPOSE 80 443 9001

CMD ["apache2-foreground"]

#eof