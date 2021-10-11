FROM php:7.4-fpm-alpine

WORKDIR /app
COPY . ./


RUN apk add --no-cache --update ca-certificates dcron curl git supervisor tar unzip nginx libpng-dev libxml2-dev libzip-dev nodejs-current npm \
    && docker-php-ext-configure zip \
    && docker-php-ext-install bcmath gd pdo_mysql zip exif \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && mkdir -p bootstrap/cache/ storage/logs storage/framework/sessions storage/framework/views storage/framework/cache \
    && chmod 777 -R bootstrap storage \
    && composer install --no-dev --optimize-autoloader \
    && rm -rf .env bootstrap/cache/*.php \
    && chown -R nginx:nginx .



COPY ./docker/supervisord.conf /etc/supervisord.conf
COPY ./docker/default.conf /etc/nginx/http.d/default.conf
COPY ./docker/www.conf /usr/local/etc/php-fpm.conf

RUN echo "* * * * * /usr/local/bin/php /app/artisan schedule:run >> /dev/null 2>&1" >> /var/spool/cron/crontabs/root \
    && mkdir -p /var/run/php /var/run/nginx

EXPOSE 80 443


RUN npm install
RUN npm run production

COPY ./docker/entrypoint.sh /app/entrypoint.sh

ENTRYPOINT ["/bin/ash", "/app/entrypoint.sh"]

CMD [ "supervisord", "-n", "-c", "/etc/supervisord.conf" ]
