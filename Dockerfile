FROM sanfun/nginx-php71-v8js:2.5
MAINTAINER dhole <dhole.me@gmail.com>

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
            imagemagick vim rsync telnet net-tools

RUN apt-get remove -y make g++ chrpath && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/*

RUN rm -rf /etc/php/7.1/cli/conf.d/50-setting.ini /etc/php/7.1/fpm/conf.d/50-setting.ini
ADD ./boot.py /bin/boot.py

ADD ./docker-entrypoint.sh /bin/docker-entrypoint.sh

USER root

RUN chmod +x /bin/boot.py /bin/docker-entrypoint.sh && rm -rf /home/www && groupadd nobody

COPY image/config /