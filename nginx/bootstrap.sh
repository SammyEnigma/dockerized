#!/bin/sh

chmod 777 /dev/stdout

echo "[NGINX] Find documentation for this Docker image at https://deb.myguard.nl/nginx-dockerized/"
echo "[NGINX] For information about the NGINX packages, please visit https://deb.myguard.nl/nginx-modules/"

# Set timezone
if [ -n "${TZ}" ]; then
    rm -f /etc/timezone /etc/localtime
    echo "${TZ}" > /etc/timezone
    ln -s /usr/share/zoneinfo/${TZ} /etc/localtime
fi

# If there are no configfiles, copy them
FIRSTRUN="/etc/nginx/nginx.conf"
if [ ! -f ${FIRSTRUN} ]; then
    echo "[NGINX] Default configurations are being copied to /etc/nginx and /etc/modsecurity as no existing configs were found."
    cp -r /etc/nginx.orig/* /etc/nginx/
    cp -r /etc/modsecurity.orig/* /etc/modsecurity/
fi

#check if PHP is installed, else skip the whole block
if [ -n "${PHPVERSION}" ]; then

    FIRSTRUN="/etc/nullmailer/defaultdomain"
    if [ ! -f ${FIRSTRUN} ]; then
    echo "[NGINX] Default configurations are being copied to /etc/nullmailer as no existing configs were found."
        cp -r /etc/nullmailer.orig/* /etc/nullmailer
    fi

    #fix some weird issue with nullmailer
    find /var/spool/nullmailer -type f -name "core" -delete
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
fi

cp -p /etc/nginx.orig/mime.types /etc/nginx/mime.types
cp -p /etc/nginx.orig/nginx.conf-packaged /etc/nginx/nginx.conf-packaged
cp -p /etc/nginx.orig/nginx.conf-original /etc/nginx/nginx.conf-original
cp -p /etc/nginx.orig/scripts/* /etc/nginx/scripts
cp -p /etc/nginx.orig/snippets/* /etc/nginx/snippets

# Make sure all available modules are available outside of docker and remove modules which aren't there (anymore)
mkdir -p /etc/nginx/modules-available
rm -f /etc/nginx/modules-available/*
cp -rp /usr/share/nginx/modules-available/* /etc/nginx/modules-available

#reorder modules and symlink them to /usr/share/nginx/modules-enabled
chmod +x /etc/nginx/scripts/reorder-modules.sh
/etc/nginx/scripts/reorder-modules.sh

#check if PHP is installed, else skip the whole block
# PHPBLOCK
if [ -n "${PHPVERSION}" ]; then

    SETPHP=0
    startphp()
    {
        # set PHPVERSION for MULTI mode
        PHPVERSION="$1"
        FIRSTRUN="/etc/php/${PHPVERSION}/fpm/php-fpm.conf"
        if [ ! -f ${FIRSTRUN} ]; then
            echo "[NGINX] Default PHP configurations are being copied to /etc/php/${PHPVERSION} as no existing PHP configs were found."
            mkdir -p /etc/php/${PHPVERSION}
            cp -r /etc/php.orig/${PHPVERSION}/* /etc/php/${PHPVERSION}
        fi
        php-fpm${PHPVERSION} -v 2>&1 | grep -v Zend | grep -v Copy
        php-fpm${PHPVERSION} -t
        service php${PHPVERSION}-fpm restart 1>/dev/null 2>&1 &
        SETPHP=1
    }

    cp -rn /etc/php.orig/* /etc/php

    #SINGLE PHP IMAGES
    if [ "${MODE}" = "FPM" ] && [ ! "${MODE}" = "MULTI" ]; then
        startphp "${PHPVERSION}"
    fi
    #MULTI PHP IMAGES
    if [ "${MODE}" = "MULTI" ] && [ "${PHP56}" = "YES" ]; then
        startphp "5.6"
    fi
    if [ "${MODE}" = "MULTI" ] && [ "${PHP72}" = "YES" ]; then
        startphp "7.2"
    fi
    if [ "${MODE}" = "MULTI" ] && [ "${PHP74}" = "YES" ]; then
        startphp "7.4"
    fi
    if [ "${MODE}" = "MULTI" ] && [ "${PHP80}" = "YES" ]; then
        startphp "8.0"
    fi
    if [ "${MODE}" = "MULTI" ] && [ "${PHP81}" = "YES" ]; then
        startphp "8.1"
    fi
    if [ "${MODE}" = "MULTI" ] && [ "${PHP82}" = "YES" ]; then
        startphp "8.2"
    fi
    if [ "${MODE}" = "MULTI" ] && [ "${PHP83}" = "YES" ]; then
        startphp "8.3"
    fi
    if [ "${PHPVERSION}" = "MULTI" ] && [ "${SETPHP}" = 0 ]; then
        echo "[NGINX] --->"
        echo "[NGINX] ---> You have obtained the MULTI-PHP version of the Docker, however..."
        echo "[NGINX] ---> No environment variable for PHP56, PHP74, PHP80, PHP81, PHP82, or PHP83 has been set"
        echo "[NGINX] ---> Uncertain of the next steps, the process will now exit..."
	echo "[NGINX] --->"
        exit
    fi
fi
# /PHPBLOCK

if [ -n "${MODULES}" ]; then
    $NGX_MODULES = ${MODULES};
fi

if [ ! -n "${NGX_MODULES}" ]; then
    if [ ! -e "/etc/nginx/modules/enabled/.quiet" ]; then
        echo "[NGINX] --->"
	echo "[NGINX] ---> Without NGX_MODULES defined in the environment, all modules will be initialized"
        echo "[NGINX] ---> This may lead to issues, reduced performance, or failure to start"
        echo "[NGINX] ---> It's advised to define NGX_MODULES or manually remove entries from /etc/nginx/modules-enabled"
	echo "[NGINX] ---> Removing mod-http-lua.conf and mod-stream-lua.conf, as those requires additional configuration to start"
        echo "[NGINX] ---> To suppress this message and behaviour please touch /etc/nginx/modules-enabled/.quiet"
        echo "[NGINX] --->"
        rm /etc/nginx/modules-enabled/50-mod-http-lua.conf
        rm /etc/nginx/modules-enabled/50-mod-stream-lua.conf
    fi
fi

nginx -V 2>&1 | grep -v configure | grep -v SNI
echo "[NGINX] Verifying configurations using the command nginx -t"
nginx -t

echo "[NGINX] This docker is set to reload every 24 hours to pick up new SSL certificates."
while [ 1 ]; do sleep 1d; /usr/sbin/nginx -s reload; done &

# Setup the MALLOC of choice.
case ${MALLOC} in
    *|jemalloc)
        export LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libjemalloc.so.2
        ;;
    mimalloc)
        export LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libmimalloc-secure.so
        ;;
    none)
        unset LD_PRELOAD
        ;;
esac

exec /usr/sbin/nginx -g 'daemon off;'
