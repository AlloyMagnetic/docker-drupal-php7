FROM lorello/octohost-nginx

MAINTAINER lorello <lorenzo.salvadorini@softecspa.it>

ENV DEBIAN_FRONTEND noninteractive

RUN add-apt-repository -y ppa:ondrej/php5 && apt-get update
RUN apt-get update -qqy && apt-get -y install php5 php5-fpm php-apc php5-imagick php5-imap php5-mcrypt php5-curl php5-gd php5-pgsql php5-sqlite php5-common php-pear php5-json php5-redis php5-memcache php5-mongo php5-mysqlnd php5-mysqlnd-ms

# Setup PHP-FPM
RUN sed -i '/daemonize /c \
daemonize = no' /etc/php5/fpm/php-fpm.conf

ADD ./php-fpm-pool.conf /etc/php5/fpm/pool.d/www.conf

# Setup composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin/
RUN mv /usr/bin/composer.phar /usr/bin/composer
RUN composer diagnose

RUN echo "<?php phpinfo(); ?>" > /srv/www/phpinfo.php

ADD ./default /etc/nginx/sites-available/default

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

CMD ["php5-fpm"]
