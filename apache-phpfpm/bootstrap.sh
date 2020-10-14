#!/bin/sh

        echo "[APACHE-PHPFM] This docker image can be found on https://hub.docker.com/u/eilandert or https://github.com/eilandert/dockerized"

        chmod 777 /dev/stdout

        if [ -n "${TZ}" ]; then
         rm /etc/timezone /etc/localtime
         echo "${TZ}" > /etc/timezone
         ln -s /usr/share/zoneinfo/${TZ} /etc/localtime
        fi

        # If there are no configfiles, copy them
        FIRSTRUN="/etc/apache2/apache2.conf"
        if [ ! -f ${FIRSTRUN} ]; then
          echo "[APACHE-PHPFM] no configs found, populating default configs to /etc/apache2"
          cp -r /etc/apache2.orig/* /etc/apache2/
        fi

        FIRSTRUN="/etc/php/${PHPVERSION}/fpm/php-fpm.conf"
        if [ ! -f ${FIRSTRUN} ]; then
          echo "[APACHE-PHPFM] no configs found, populating default configs to /etc/php"
          cp -r /etc/php.orig/* /etc/php/
        fi

        FIRSTRUN="/etc/nullmailer/defaultdomain"
        if [ ! -f ${FIRSTRUN} ]; then
          echo "[APACHE-PHPFM] no configs found, populating default configs to /etc/nullmailer"
          cp -r /etc/nullmailer.orig/* /etc/nullmailer
        fi

	if [ "${MODE}" = "fpm" ]; then
    	  #fix some weird issue with php-fpm
	  if [ ! -x /run/php ]; then
            mkdir -p /run/php
            chown www-data:www-data /run/php
            chmod 755 /run/php
          fi
	  a2dismod php${PHPVERSION} 1>/dev/null 2>&1
	  a2enconf php${PHPVERSION}-fpm 1>/dev/null 2>&1
	  a2dismod mpm_prefork 1>/dev/null 2>&1
	  a2enmod mpm_event 1>/dev/null 2>&1
          service php${PHPVERSION}-fpm restart 1>/dev/null 2>&1
	  php-fpm${PHPVERSION} -t
	  php-fpm${PHPVERSION} -v
	fi

        if [ "${MODE}" = "mod" ]; then
          service php${PHPVERSION}-fpm stop 1>/dev/null 2>&1
	  a2enmod php${PHPVERSION} 1>/dev/null 2>&1
	  a2disconf php${PHPVERSION}-fpm 1>/dev/null 2>&1
	  a2dismod mpm_event 1>/dev/null 2>&1
	  a2enmod mpm_prefork 1>/dev/null 2>&1
	  php${PHPVERSION} -v
	fi

	#fix some weird issue with nullmailer
	rm -f /var/spool/nullmailer/trigger
	/usr/bin/mkfifo /var/spool/nullmailer/trigger
	/bin/chmod 0622 /var/spool/nullmailer/trigger
	/bin/chown -R mail:mail /var/spool/nullmailer/ /etc/nullmailer 
        runuser -u mail /usr/sbin/nullmailer-send 1>/var/log/nullmailer.log 2>&1 &

        if [ "${CACHE}" = "yes" ]; then
          mkdir -p /var/cache/apache2/mod_cache_disk
          chmod 755 /var/cache/apache2/mod_cache_disk
          chown -R www-data:www-data /var/cache/apache2/mod_cache_disk
          a2enmod cache_disk 1>/dev/null 2>&1
          #htcacheclean -d${CACHE_INTERVAL} -l${CACHE_SIZE} -t -i -p /var/cache/apache2/mod_cache_disk
        else
          if [ -f /etc/apache2/mods-enabled/cache_disk.load ]; then
            a2dismod cache cache_disk 1>/dev/null 2>&1
          fi
        fi

	apachectl -v
	echo "Checking configs:"
	apachectl configtest

	if [ -f /etc/apache2/mods-enabled/ssl.load ]; then
	  echo "Automaticly reloading configs everyday to pick up new ssl certificates"
	  while [ 1 ]; do sleep 1d; apachectl graceful; done &
	fi

exec /usr/sbin/apache2ctl -DFOREGROUND

