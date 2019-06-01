FROM sanfun/nginx-php71-v8js:2.5
MAINTAINER dhole <dhole.me@gmail.com>

RUN rm -rf /etc/php/7.1/cli/conf.d/50-setting.ini /etc/php/7.1/fpm/conf.d/50-setting.ini
COPY image/config /