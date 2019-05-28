FROM stesie/v8js
MAINTAINER dhole <dhole.me@gmail.com>

# docker build -t php-v8js:latest .

RUN DEBIAN_FRONTEND=noninteractive \
	apt-get update && apt-get install make g++ python2.7 curl chrpath wget bzip2 --no-install-recommends -qy \
    php7.0 \
    php7.0-bcmath \
    php7.0-common \
    php7.0-curl \
    php7.0-dom \
    php7.0-fpm \
    php7.0-gd \
    php7.0-iconv \
    php7.0-intl \
    php7.0-json \
    php7.0-mbstring \
    php7.0-mcrypt \
    php7.0-mysql \
    php7.0-pdo \
    php7.0-phar \
    php7.0-sqlite \
    php7.0-xml \
    php7.0-zip \
    php7.0-dev \
    php7.0-xml

RUN apt-get install -y php-pear

RUN pecl install mongodb redis xdebug && \
	echo extension=redis.so > /etc/php/7.0/mods-available/redis.ini && \
	echo extension=mongodb.so > /etc/php/7.0/mods-available/mongodb.ini && \
	echo zend_extension=/usr/lib/php/20151012/xdebug.so > /etc/php/7.0/mods-available/xdebug.ini

RUN phpenmod mongodb redis

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

WORKDIR /code
USER www

RUN chmod 600 /home/www/.ssh/authorized_keys \
    && chmod 700 /home/www/.ssh

RUN apt-get remove -y subversion make g++ chrpath && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/*



