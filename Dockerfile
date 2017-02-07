FROM lorello/docker-ubuntu

ENV DEBIAN_FRONTEND noninteractive
RUN add-apt-repository -y ppa:nginx/stable
RUN add-apt-repository -y ppa:ondrej/php7 && apt-get update
RUN apt-add-repository -y ppa:ansible/ansible
RUN apt-get update -qqy && apt-get -qqy install nginx-extras mysql-client php7 php7-fpm php-apc php7-imagick php7-imap php7-mcrypt php7-curl php7-gd php7-pgsql php7-sqlite php7-common php-pear php7-json php7-redis php7-memcache php7-mongo php7-mysqlnd php7-mysqlnd-ms php7-sqlite sqlite3 python-softlayer ansible


# Setup Nginx
ADD nginx.conf /etc/nginx/nginx.conf
ADD fastcgi_drupal.conf /etc/nginx/fastcgi_drupal.conf
ADD fastcgi_drupal.conf /etc/nginx/fastcgi_no_args_drupal.conf
ADD default /etc/nginx/sites-available/default

RUN mkdir /srv/www
RUN echo "Nginx is up and running" > /srv/www/index.html

# Add dockerize binary
# http://jasonwilder.com/blog/2014/10/13/a-simple-way-to-dockerize-applications/
RUN wget -q https://github.com/jwilder/dockerize/releases/download/v0.0.2/dockerize-linux-amd64-v0.0.2.tar.gz
RUN tar -C /usr/local/bin -xvzf dockerize-linux-amd64-v0.0.2.tar.gz

# Setup composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin/
RUN mv /usr/bin/composer.phar /usr/bin/composer
RUN composer diagnose

RUN composer global require drush/drush:7.*
RUN ln -s /root/.composer/vendor/drush/drush/drush /usr/bin/drush

RUN echo '<?php phpinfo(); ?>' > /srv/www/index.php

# Setup Nginx
ADD ./nginx.conf /etc/nginx/nginx.conf
ADD ./fastcgi_drupal.conf /etc/nginx/fastcgi_drupal.conf
ADD ./fastcgi_drupal.conf /etc/nginx/fastcgi_no_args_drupal.conf
ADD ./default /etc/nginx/sites-available/default

# Setup PHP-FPM
#RUN sed -i '/daemonize /c \
#daemonize = no' /etc/php7/fpm/php-fpm.conf
ADD ./php-fpm-pool.conf /etc/php7/fpm/pool.d/www.conf

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE 80

CMD service php7-fpm start && dockerize -stdout /var/log/nginx/access.log -stderr /var/log/nginx/error.log nginx
