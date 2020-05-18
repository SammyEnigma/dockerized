#!/bin/sh

        echo "[BOOTSTRAP] This docker image can be found on https://hub.docker.com/u/eilandert or https://github.com/eilandert/dockerized"

        #set nameserver if variable is set
        if [ -n "${NAMESERVER}" ]; then
                echo "nameserver ${NAMESERVER}" > /etc/resolv.conf
        fi

	UNBOUNDCONF="/config/unbound.conf"
	if [ ! -f ${UNBOUNDCONF} ]; then
                echo "[BOOTSTRAP] unbound.conf not found, populating default configs to /config"
		mkdir -p /config
		cp -r config.orig/* /config/
	fi

        exec /usr/sbin/unbound -c /config/unbound.conf
