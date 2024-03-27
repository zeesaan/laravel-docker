FROM ubuntu:20.04

ENV DEBIAN_FRONTEND noninteractive

# Install dependencies
RUN apt update
RUN apt install -y software-properties-common
RUN add-apt-repository -y ppa:ondrej/php
RUN apt update
RUN apt install -y php8.1\
    php8.1-cli\
    php8.1-common\
    php8.1-fpm\
    php8.1-mysql\
    php8.1-zip\
    php8.1-gd\
    php8.1-mbstring\
    php8.1-curl\
    php8.1-xml\
    php8.1-bcmath\
    php8.1-pdo\
    php8.1-imagick


# Install php-fpm
RUN apt install -y php8.1-fpm php8.1-cli
# Install NFS
RUN apt-get install -y nfs-common

# Copy the startup script into the container

COPY startup.sh /usr/local/bin/startup.sh
RUN chmod +x /usr/local/bin/startup.sh

#php fpm tuning
RUN sed -E -i   's/upload_max_filesize = 2M/upload_max_filesize = 3G/g' /etc/php/8.1/fpm/php.ini && \
    sed -E -i   's/post_max_size = 8M/post_max_size = 1G/g' /etc/php/8.1/fpm/php.ini && \
    sed -E -i   's/memory_limit = 128M/memory_limit = 4G/g' /etc/php/8.1/fpm/php.ini && \
    sed -E -i   's/max_input_time = 60/max_input_time = 120/g' /etc/php/8.1/fpm/php.ini    


# Install composer
RUN apt install -y curl
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install nginx
RUN apt install -y nginx
RUN echo "\
    server {\n\
        listen 80;\n\
        listen [::]:80;\n\
        root /var/www/html/public;\n\
        add_header X-Frame-Options \"SAMEORIGIN\";\n\
        add_header X-Content-Type-Options \"nosniff\";\n\
        index index.php;\n\
        charset utf-8;\n\
        location / {\n\
            try_files \$uri \$uri/ /index.php?\$query_string;\n\
        }\n\
        location = /favicon.ico { access_log off; log_not_found off; }\n\
        location = /robots.txt  { access_log off; log_not_found off; }\n\
        error_page 404 /index.php;\n\
        location ~ \.php$ {\n\
            fastcgi_pass unix:/run/php/php8.1-fpm.sock;\n\
            fastcgi_param SCRIPT_FILENAME \$realpath_root\$fastcgi_script_name;\n\
            include fastcgi_params;\n\
        }\n\
        location ~ /\.(?!well-known).* {\n\
            deny all;\n\
        }\n\
    }\n" > /etc/nginx/sites-available/default

RUN echo "\
    #!/bin/sh\n\
    echo \"Starting services...\"\n\
    service php8.1-fpm start\n\
    nginx -g \"daemon off;\" &\n\
    echo \"Ready.\"\n\
    tail -s 1 /var/log/nginx/*.log -f\n\
    " > /start.sh

COPY startup.sh /var/www/html/
COPY fstab /etc/fstab
WORKDIR /var/www/html/

RUN chown -R www-data:www-data /var/www/html/


#RUN composer install --no-interaction --optimize-autoloader --no-dev
#Optimizing Configuration loading
#RUN php artisan config:cache
# RUN php artisan route:cache

#Optimizing View loading
#RUN php artisan view:cache
EXPOSE 80

#CMD ["sh", "/start.sh"]
CMD ["/start.sh && /usr/local/bin/startup.sh"]

