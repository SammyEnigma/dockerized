#!/bin/sh

chmod 777 /dev/stdout

echo "[NGINX] This docker image can be found on https://hub.docker.com/u/eilandert or https://github.com/eilandert/dockerized"
echo "[NGINX] The NGINX packages (and detailed description of this NGINX stack) can be found on https://deb.paranoid.nl"

if [ -n "${TZ}" ]; then
    rm -f /etc/timezone /etc/localtime
    echo "${TZ}" > /etc/timezone
    ln -s /usr/share/zoneinfo/${TZ} /etc/localtime
fi

# If there are no configfiles, copy them
FIRSTRUN="/etc/nginx/nginx.conf"
if [ ! -f ${FIRSTRUN} ]; then
    echo "[NGINX] no configs found, populating default configs to /etc/nginx and /etc/modsecurity"
    cp -r /etc/nginx.orig/* /etc/nginx/
    cp -r /etc/modsecurity.orig/* /etc/modsecurity/
fi

# Make sure all available modules are available outside of docker and remove modules which aren't there (anymore)
mkdir -p /etc/nginx/modules-available && \
    rm -f /etc/nginx/modules-available/* && \
    cp -rp /usr/share/nginx/modules-available/* /etc/nginx/modules-available

# If exists, enable modules in NGX_MODULE environment variable and remove others.
if [ -n "${NGX_MODULES}" ]; then
    NGX_MODULES=`echo "${NGX_MODULES}" | sed -e s/"[, ]"/" "/g`
    mkdir -p /etc/nginx/modules-enabled && \
        rm -f /etc/nginx/modules-enabled/* && \
        cd /etc/nginx/modules-enabled

    for MODULE in $NGX_MODULES
    do
	# Make priorities as needed
	PRIO="50-"
        case ${MODULE} in
            mod-http-ndk) echo PRIO="10-" ;;
            mod-stream)   echo PRIO="10-" ;;
            mod-stream-*) ln -sf ../modules-available/mod-stream.conf 10-mod-stream.conf; PRIO="50-" ;;
        esac
        ln -sf ../modules-available/${MODULE}.conf ${PRIO}${MODULE}.conf
    done
fi

# Setup the MALLOC of choise, with JEMALLOC as default
case ${MALLOC} in
    *|jemalloc)
        export LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libjemalloc.so.2
        ;;
    mimalloc)
        export LD_PRELOAD=/usr/lib/mimalloc-2.0/libmimalloc-secure.so
        ;;
    none)
        unset LD_PRELOAD
        ;;
esac

#check if PHP is installed, else skip the whole block
# PHPBLOCK
if [ -n "${PHPVERSION}" ]; then

    startphp()
    {
        # set PHPVERSION for MULTI mode
        PHPVERSION="$1"
        FIRSTRUN="/etc/php/${PHPVERSION}/fpm/php-fpm.conf"
        if [ ! -f ${FIRSTRUN} ]; then
            echo "[NGINX] no configs found, populating default configs to /etc/php/${PHPVERSION}"
            mkdir -p /etc/php/${PHPVERSION}
            cp -r /etc/php.orig/${PHPVERSION}/* /etc/php/${PHPVERSION}
        fi
        php-fpm${PHPVERSION} -v
        php-fpm${PHPVERSION} -t
        service php${PHPVERSION}-fpm restart 1>/dev/null 2>&1
    }

    FIRSTRUN="/etc/nullmailer/defaultdomain"
    if [ ! -f ${FIRSTRUN} ]; then
        echo "[NGINX] no configs found, populating default configs to /etc/nullmailer"
        cp -r /etc/nullmailer.orig/* /etc/nullmailer
    fi

    #fix some weird issue with nullmailer
    rm -f /var/spool/nullmailer/trigger
    /usr/bin/mkfifo /var/spool/nullmailer/trigger
    /bin/chmod 0622 /var/spool/nullmailer/trigger
    /bin/chown -R mail:mail /var/spool/nullmailer/ /etc/nullmailer
    runuser -u mail /usr/sbin/nullmailer-send 1>/var/log/nullmailer.log 2>&1 &

    if [ ! -x /run/php ]; then
        mkdir -p /run/php
        chown www-data:www-data /run/php
        chmod 755 /run/php
    fi

    COMPOSERPATH="/usr/bin/composer"
    if [ ! -f ${COMPOSERPATH} ]; then
        cd /tmp
        php composer-setup.php --quiet
        mv composer.phar ${COMPOSERPATH}
    fi

    SETPHP=0
    if [ "${MODE}" = "FPM" ] && [ ! "${MODE}" = "MULTI" ]; then
        startphp "${PHPVERSION}"
        SETPHP=1
    fi
    if [ "${MODE}" = "MULTI" ] && [ "${PHP56}" = "YES" ]; then
        startphp "5.6"
        SETPHP=1
    fi
    if [ "${MODE}" = "MULTI" ] && [ "${PHP72}" = "YES" ]; then
        startphp "7.2"
        SETPHP=1
    fi
    if [ "${MODE}" = "MULTI" ] && [ "${PHP74}" = "YES" ]; then
        startphp "7.4"
        SETPHP=1
    fi
    if [ "${MODE}" = "MULTI" ] && [ "${PHP80}" = "YES" ]; then
        startphp "8.0"
        SETPHP=1
    fi
    if [ "${MODE}" = "MULTI" ] && [ "${PHP81}" = "YES" ]; then
        startphp "8.1"
        SETPHP=1
    fi

    if [ "${PHPVERSION}" = "MULTI" ] && [ "${SETPHP}" = 0 ]; then
        echo "[NGINX] You downloaded the MULTI-PHP edition of the docker but...."
        echo "[NGINX] There is no PHP56 PHP72 PHP74 PHP80 or PHP81 environment variable specified"
        echo "[NGINX] Don't know what to do now, exiting...."
        exit
    fi

fi
# /PHPBLOCK

#download new pagespeed libraries on docker startup
chmod +x /etc/nginx/scripts/pagespeed_libraries_generator.sh 1>/dev/null 2>&1
/etc/nginx/scripts/pagespeed_libraries_generator.sh > /etc/nginx/snippets/pagespeed_libraries.conf 1>/dev/null 2>/dev/null &

nginx -V 2>&1 | grep -v configure
nginx -t

#echo "Automaticly reloading configs everyday to pick up new ssl certificates"
while [ 1 ]; do sleep 1d; nginx -s reload; done &

exec nginx -g 'daemon off;'
