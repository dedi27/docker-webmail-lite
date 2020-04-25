FROM ubuntu:bionic
MAINTAINER AfterLogic Support <support@afterlogic.com>

#Afterlogic docker image without internal MySQL Database

# installing packages and dependencies
ENV DEBIAN_FRONTEND noninteractive
ARG VERSION=8
RUN apt-get update && apt-get install -y php7.2 php7.2-cli php7.2-curl php7.2-gd php7.2-json php7.2-ldap php7.2-mysql \
    php7.2-pgsql php7.2-readline php7.2-xml php7.2-xmlrpc php7.2-bcmath php7.2-bz2 php7.2-dba php7.2-imap php7.2-intl php7.2-mbstring php7.2-zip php7.2-fpm && \
    apt-get -y install vim net-tools wget unzip supervisor apache2 libapache2-mod-php7.2 && \
    apt-get clean && echo "ServerName localhost" >> /etc/apache2/apache2.conf

# adding configuration files and scripts
ADD start-apache2.sh /start-apache2.sh
ADD run.sh /run.sh
ADD supervisord-apache2.conf /etc/supervisor/conf.d/supervisord-apache2.conf
RUN chmod 755 /*.sh

# setting up default apache config
ADD apache.conf /etc/apache2/sites-available/000-default.conf
RUN a2enmod rewrite

# downloading and setting up webmail
RUN rm -rf /tmp/alwm && mkdir -p /tmp/alwm && wget -P /tmp/alwm https://afterlogic.com/download/webmail-pro-php-${VERSION}.zip && \
    unzip -q /tmp/alwm/webmail-pro-php-${VERSION}.zip -d /tmp/alwm/ && rm -rf /tmp/alwm/webmail-lite-php-${VERSION}.zip && rm -rf /var/www/html && \
    mkdir -p /var/www/html && cp -r /tmp/alwm/* /var/www/html && rm -rf /var/www/html/install && chown www-data.www-data -R /var/www/html && \
    chmod 0777 -R /var/www/html/data && rm -f /var/www/html/afterlogic.php && rm -rf /tmp/alwm
COPY afterlogic.php /var/www/html/afterlogic.php

# setting php configuration values
ENV PHP_UPLOAD_MAX_FILESIZE 20M
ENV PHP_POST_MAX_SIZE 40M

# adding afterlogic data volumes
VOLUME "/var/www/html/data"

EXPOSE 80
CMD ["/run.sh"]
