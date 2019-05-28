FROM studionone/nginx-php7-v8js
MAINTAINER dhole <dhole.me@gmail.com>

RUN apt-get update && apt-get update &&  \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
            sudo chrpath git subversion curl \
            php7.1-cli \
            php7.1-bcmath \
            php7.1-common \
            php7.1-curl \
            php7.1-dom \
            php7.1-fpm \
            php7.1-gd \
            php7.1-iconv \
            php7.1-intl \
            php7.1-json \
            php7.1-mbstring \
            php7.1-mcrypt \
            php7.1-mysql \
            php7.1-pdo \
            php7.1-phar \
            php7.1-sqlite \
            php7.1-xml \
            php7.1-zip \
            php7.1-xml \
            php7.1-dev && \

    && apt-get install -y php-pear \
    && pecl install mongodb redis xdebug \
    && echo extension=redis.so > /etc/php/7.1/mods-available/redis.ini \
    && echo extension=mongodb.so > /etc/php/7.1/mods-available/mongodb.ini \
    && rm -rf /etc/php/7.1/cli/conf.d/99-v8js.ini && echo extension=v8js.so > /etc/php/7.1/mods-available/v8js.ini \
    && echo zend_extension=/usr/lib/php/20151012/xdebug.so > /etc/php/7.1/mods-available/xdebug.ini s\
    && phpenmod mongodb redis v8js

COPY image/scripts /tmp/

RUN chmod +x /tmp/*.sh && \
    sh /tmp/env.sh

COPY image/config /

RUN chmod 600 /root/.ssh/authorized_keys \
    && chmod 700 /root/.ssh \
    && chmod +x /etc/update-motd.d/50-phpdocker

COPY image/scripts/bin /opt/scripts

RUN apt-get install -y openssh-server --no-install-recommends \
    && echo PasswordAuthentication no >> /etc/ssh/sshd_config \
    && echo PermitRootLogin no >> /etc/ssh/sshd_config

ADD ./boot.py /bin/boot.py

RUN chmod +x /bin/boot.py && chown -R www:www /home/www/

RUN chmod 600 /home/www/.ssh/authorized_keys \
    && chmod 700 /home/www/.ssh

RUN apt-get remove -y make g++ chrpath && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/*

WORKDIR /code

