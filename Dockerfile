FROM sanfun/nginx-php71-v8js:2.5
MAINTAINER dhole <dhole.me@gmail.com>

RUN rm -rf /etc/php/7.1/cli/conf.d/50-setting.ini /etc/php/7.1/fpm/conf.d/50-setting.ini
ADD ./boot.py /bin/boot.py

ADD ./docker-entrypoint.sh /bin/docker-entrypoint.sh

RUN chmod +x /bin/boot.py /bin/docker-entrypoint.sh && chown -R www:www /home/www/

COPY image/config /