FROM alpine:edge
LABEL maintainer="Thijs Eilander <eilander@myguard.nl>"

ENV INSTALL_PATH=/opt/vimbadmin

RUN  apk update && apk upgrade \
  && apk add --no-cache php7-apache2 php7-phar php7-mbstring php7-mcrypt php7-json php7-pdo php-gettext php7-memcached php7-pdo_mysql php7-opcache php7-tokenizer php7-simplexml php7-ctype php7-iconv php7-openssl tzdata\
  && apk add --no-cache git curl apache2 dovecot \
  && curl -sS https://getcomposer.org/installer | php7 -- --filename=composer --install-dir=/usr/local/bin \
  && git clone --recursive https://github.com/opensolutions/ViMbAdmin.git ${INSTALL_PATH} \
  && cd ${INSTALL_PATH} \
  && composer config -g secure-http false \
  && composer install --prefer-dist --no-dev \
  && chown -R apache:apache ${INSTALL_PATH}/var \
  && cp -r ${INSTALL_PATH}/application/configs ${INSTALL_PATH}/application/configs.orig \	
  && echo "Include ${INSTALL_PATH}/application/configs/httpd.conf" >> /etc/apache2/httpd.conf \
  && rm ${INSTALL_PATH}/application/configs.orig/application.ini.vagrant \
  && apk del --no-cache git libcurl curl \
  && rm -rf ${INSTALL_PATH}/.git /root/.composer /usr/local/bin/composer \
  && rm -rf /var/cache/apk/* /usr/src/* /tmp ${INSTALL_PATH}/.git*

COPY bootstrap.sh /bootstrap.sh
COPY httpd.conf ${INSTALL_PATH}/application/configs.orig/

RUN chmod +x /bootstrap.sh

EXPOSE 9000/TCP

CMD "/bootstrap.sh"
