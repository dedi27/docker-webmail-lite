FROM ubuntu:trusty
MAINTAINER AfterLogic Support <support@afterlogic.com>

#Afterlogic docker image without internal MySQL Database

# installing packages and dependencies
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get -y install wget unzip supervisor apache2 libapache2-mod-php5 php5 php5-common php5-curl php5-fpm php5-cli php5-mysqlnd php5-mcrypt && \
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
RUN rm -rf /tmp/alwm && mkdir -p /tmp/alwm && wget -P /tmp/alwm https://afterlogic.org/download/webmail-lite-php-7.zip && \
    unzip -q /tmp/alwm/webmail-lite-php-7.zip -d /tmp/alwm/ && rm -rf /var/www/html && mkdir -p /var/www/html && cp -r /tmp/alwm/webmail/* /var/www/html && \
    rm -rf /var/www/html/install && chown www-data.www-data -R /var/www/html && chmod 0777 -R /var/www/html/data && \
    rm -f /var/www/html/afterlogic.php && rm -rf /tmp/alwm
COPY afterlogic.php /var/www/html/afterlogic.php

# setting php configuration values
ENV PHP_UPLOAD_MAX_FILESIZE 20M
ENV PHP_POST_MAX_SIZE 40M

# adding afterlogic data volumes
VOLUME "/var/www/html/data"

EXPOSE 80
CMD ["/run.sh"]
