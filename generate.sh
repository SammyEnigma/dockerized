#!/bin/bash

# This script uses lastversion
# To install lastversion:
# apt install python3-pip
# pip -q install --upgrade lastversion


set -x

export UBUNTU_ROLLING="jammy"

####
## SCRIPTS DEBIAN/UBUNTU BASE IMAGES
####

cp base/Dockerfile-template base/Dockerfile-devel
cp base/Dockerfile-template base/Dockerfile-rolling
cp base/Dockerfile-template base/Dockerfile-jammy
cp base/Dockerfile-template base/Dockerfile-focal
cp base/Dockerfile-template base/Dockerfile-bionic
cp base/Dockerfile-template base/Dockerfile-xenial
cp base/Dockerfile-template base/Dockerfile-trusty
cp base/Dockerfile-template base/Dockerfile-bookworm
cp base/Dockerfile-template base/Dockerfile-bullseye
cp base/Dockerfile-template base/Dockerfile-buster
cp base/Dockerfile-template base/Dockerfile-stretch
cp base/Dockerfile-template base/Dockerfile-jessie

sed -i s/#TEMPLATE1#/ubuntu:devel/   base/Dockerfile-devel
sed -i s/"#TEMPLATE1#"/"ubuntu:${UBUNTU_ROLLING}"/ base/Dockerfile-rolling
sed -i s/#TEMPLATE1#/ubuntu:jammy/   base/Dockerfile-jammy
sed -i s/#TEMPLATE1#/ubuntu:focal/   base/Dockerfile-focal
sed -i s/#TEMPLATE1#/ubuntu:bionic/  base/Dockerfile-bionic
sed -i s/#TEMPLATE1#/ubuntu:xenial/  base/Dockerfile-xenial
sed -i s/#TEMPLATE1#/ubuntu:trusty/  base/Dockerfile-trusty

sed -i s/#TEMPLATE1#/debian:bookworm-slim/ base/Dockerfile-bookworm
sed -i s/#TEMPLATE1#/debian:buster-slim/   base/Dockerfile-buster
sed -i s/#TEMPLATE1#/debian:bullseye-slim/ base/Dockerfile-bullseye
sed -i s/#TEMPLATE1#/debian:stretch-slim/  base/Dockerfile-stretch
sed -i s/#TEMPLATE1#/debian:jessie-slim/   base/Dockerfile-jessie

sed -i s/#TEMPLATE2#/"${UBUNTU_DEVEL}"/   base/Dockerfile-devel
sed -i s/#TEMPLATE2#/"${UBUNTU_ROLLING}"/  base/Dockerfile-rolling
sed -i s/#TEMPLATE2#/jammy/    base/Dockerfile-jammy
sed -i s/#TEMPLATE2#/focal/    base/Dockerfile-focal
sed -i s/#TEMPLATE2#/bionic/   base/Dockerfile-bionic
sed -i s/#TEMPLATE2#/xenial/   base/Dockerfile-xenial
sed -i s/#TEMPLATE2#/trusty/   base/Dockerfile-trusty
sed -i s/#TEMPLATE2#/bookworm/ base/Dockerfile-bookworm
sed -i s/#TEMPLATE2#/buster/   base/Dockerfile-buster
sed -i s/#TEMPLATE2#/bullseye/ base/Dockerfile-bullseye
sed -i s/#TEMPLATE2#/stretch/  base/Dockerfile-stretch
sed -i s/#TEMPLATE2#/jessie/   base/Dockerfile-jessie

#git add base/Dockerfile*
#git commit -m "autogenerated"

####
## SCRIPTS PHP-FPM
####

wget https://getcomposer.org/installer -O php-fpm/composer-setup.php
git add php-fpm/composer-setup.php
git commit -m "Changes from upstream"

cp php-fpm/Dockerfile-template.php php-fpm/Dockerfile-template.generated.php56
cp php-fpm/Dockerfile-template.php php-fpm/Dockerfile-template.generated.php72
cp php-fpm/Dockerfile-template.php php-fpm/Dockerfile-template.generated.php74
cp php-fpm/Dockerfile-template.php php-fpm/Dockerfile-template.generated.php80
cp php-fpm/Dockerfile-template.php php-fpm/Dockerfile-template.generated.php81
cp php-fpm/Dockerfile-template.php php-fpm/Dockerfile-template.generated.php82

sed -i 's/#PHPVERSION#/5.6/' php-fpm/Dockerfile-template.generated.php56
sed -i 's/#PHPVERSION#/7.2/' php-fpm/Dockerfile-template.generated.php72
sed -i 's/#PHPVERSION#/7.4/' php-fpm/Dockerfile-template.generated.php74
sed -i 's/#PHPVERSION#/8.0/' php-fpm/Dockerfile-template.generated.php80
sed -i 's/#PHPVERSION#/8.1/' php-fpm/Dockerfile-template.generated.php81
sed -i 's/#PHPVERSION#/8.2/' php-fpm/Dockerfile-template.generated.php82

sed -i 's/#removedinphp72#//' php-fpm/Dockerfile-template.generated.php56 #mcrypt
sed -i 's/#removedinphp74#//' php-fpm/Dockerfile-template.generated.php56 #recode
sed -i 's/#removedinphp80#//' php-fpm/Dockerfile-template.generated.php56 #json
sed -i 's/#removedinphp74#//' php-fpm/Dockerfile-template.generated.php72 #recode
sed -i 's/#removedinphp80#//' php-fpm/Dockerfile-template.generated.php72 #json
sed -i 's/#removedinphp80#//' php-fpm/Dockerfile-template.generated.php74 #json

sed -i '/#removedinphp/d' php-fpm/Dockerfile-template.generated.php56
sed -i '/#removedinphp/d' php-fpm/Dockerfile-template.generated.php72
sed -i '/#removedinphp/d' php-fpm/Dockerfile-template.generated.php74
sed -i '/#removedinphp/d' php-fpm/Dockerfile-template.generated.php80
sed -i '/#removedinphp/d' php-fpm/Dockerfile-template.generated.php81
sed -i '/#removedinphp/d' php-fpm/Dockerfile-template.generated.php82

cat php-fpm/Dockerfile-template.header \
    php-fpm/Dockerfile-template.generated.php56 \
    php-fpm/Dockerfile-template.footer > php-fpm/Dockerfile-5.6

cat php-fpm/Dockerfile-template.header \
    php-fpm/Dockerfile-template.generated.php72 \
    php-fpm/Dockerfile-template.footer > php-fpm/Dockerfile-7.2

cat php-fpm/Dockerfile-template.header \
    php-fpm/Dockerfile-template.generated.php74 \
    php-fpm/Dockerfile-template.footer > php-fpm/Dockerfile-7.4

cat php-fpm/Dockerfile-template.header \
    php-fpm/Dockerfile-template.generated.php80 \
    php-fpm/Dockerfile-template.footer > php-fpm/Dockerfile-8.0

cat php-fpm/Dockerfile-template.header \
    php-fpm/Dockerfile-template.generated.php81 \
    php-fpm/Dockerfile-template.footer > php-fpm/Dockerfile-8.1

cat php-fpm/Dockerfile-template.header \
    php-fpm/Dockerfile-template.generated.php82 \
    php-fpm/Dockerfile-template.footer > php-fpm/Dockerfile-8.2

cat php-fpm/Dockerfile-template.header \
    php-fpm/Dockerfile-template.generated.php56 \
    php-fpm/Dockerfile-template.generated.php72 \
    php-fpm/Dockerfile-template.generated.php74 \
    php-fpm/Dockerfile-template.generated.php80 \
    php-fpm/Dockerfile-template.generated.php81 \
    php-fpm/Dockerfile-template.generated.php82 \
    php-fpm/Dockerfile-template.footer > php-fpm/Dockerfile-multi

rm -f php-fpm/Dockerfile-template.generated.*

sed -i 's/#PHPVERSION#/5.6/' php-fpm/Dockerfile-5.6
sed -i 's/#PHPVERSION#/7.2/' php-fpm/Dockerfile-7.2
sed -i 's/#PHPVERSION#/7.4/' php-fpm/Dockerfile-7.4
sed -i 's/#PHPVERSION#/8.0/' php-fpm/Dockerfile-8.0
sed -i 's/#PHPVERSION#/8.1/' php-fpm/Dockerfile-8.1
sed -i 's/#PHPVERSION#/8.2/' php-fpm/Dockerfile-8.2

sed -i 's/#PHPVERSION#/MULTI/' php-fpm/Dockerfile-multi
sed -i 's/MODE=FPM/MODE=MULTI/' php-fpm/Dockerfile-multi

sed -i 's/rm -rf \/etc\/php\/5.6/#rm -rf \/etc\/php\/5.6/' php-fpm/Dockerfile-5.6
sed -i 's/rm -rf \/etc\/php\/7.2/#rm -rf \/etc\/php\/7.2/' php-fpm/Dockerfile-7.2
sed -i 's/rm -rf \/etc\/php\/7.4/#rm -rf \/etc\/php\/7.4/' php-fpm/Dockerfile-7.4
sed -i 's/rm -rf \/etc\/php\/8.0/#rm -rf \/etc\/php\/8.0/' php-fpm/Dockerfile-8.0
sed -i 's/rm -rf \/etc\/php\/8.1/#rm -rf \/etc\/php\/8.1/' php-fpm/Dockerfile-8.1
sed -i 's/rm -rf \/etc\/php\/8.2/#rm -rf \/etc\/php\/8.2/' php-fpm/Dockerfile-8.2
sed -i 's/rm -rf \/etc\/php/#rm -rf \/etc\/php/' php-fpm/Dockerfile-multi

cp php-fpm/Dockerfile-5.6 php-fpm/Dockerfile-5.6debian
cp php-fpm/Dockerfile-7.2 php-fpm/Dockerfile-7.2debian
cp php-fpm/Dockerfile-7.4 php-fpm/Dockerfile-7.4debian
cp php-fpm/Dockerfile-8.0 php-fpm/Dockerfile-8.0debian
cp php-fpm/Dockerfile-8.1 php-fpm/Dockerfile-8.1debian
cp php-fpm/Dockerfile-8.2 php-fpm/Dockerfile-8.2debian
cp php-fpm/Dockerfile-multi php-fpm/Dockerfile-multidebian

sed -i s/"eilandert\/ubuntu-base:rolling"/"eilandert\/debian-base:stable"/ php-fpm/*debian

sed -i s/"\#TEMPLATE3\#"/"echo \"deb \[trusted=yes\] http:\/\/packages.sury.org\/php\/ \${DIST} main\" > \/etc\/apt\/sources.list.d\/ondrej-ppa.list"/ php-fpm/Dockerfile-*debian
sed -i s/"\#TEMPLATE3\#"/"echo \"deb \[trusted=yes\] http:\/\/ppa.launchpad.net\/ondrej\/php\/ubuntu\/ \${DIST} main\" > \/etc\/apt\/sources.list.d\/ondrej-ppa.list"/ php-fpm/Dockerfile-{5.6,7.2,7.4,8.0,8.1,8.2,multi}



####
## SCRIPTS Apache PHP-FPM
####
cp apache-phpfpm/Dockerfile-template apache-phpfpm/Dockerfile-5.6
cp apache-phpfpm/Dockerfile-template apache-phpfpm/Dockerfile-7.2
cp apache-phpfpm/Dockerfile-template apache-phpfpm/Dockerfile-7.4
cp apache-phpfpm/Dockerfile-template apache-phpfpm/Dockerfile-8.0
cp apache-phpfpm/Dockerfile-template apache-phpfpm/Dockerfile-8.1
cp apache-phpfpm/Dockerfile-template apache-phpfpm/Dockerfile-8.2
cp apache-phpfpm/Dockerfile-template apache-phpfpm/Dockerfile-multi

sed -i 's/#PHPVERSION#/5.6/' apache-phpfpm/Dockerfile-5.6
sed -i 's/#PHPVERSION#/7.2/' apache-phpfpm/Dockerfile-7.2
sed -i 's/#PHPVERSION#/7.4/' apache-phpfpm/Dockerfile-7.4
sed -i 's/#PHPVERSION#/8.0/' apache-phpfpm/Dockerfile-8.0
sed -i 's/#PHPVERSION#/8.1/' apache-phpfpm/Dockerfile-8.1
sed -i 's/#PHPVERSION#/8.2/' apache-phpfpm/Dockerfile-8.2

sed -i 's/#PHPVERSION#/multi/' apache-phpfpm/Dockerfile-multi

sed -i '/libapache2-mod-php/d'   apache-phpfpm/Dockerfile-multi
sed -i '/a2enconf php/d'         apache-phpfpm/Dockerfile-multi
sed -i '/a2dismod php/d'         apache-phpfpm/Dockerfile-multi

cp apache-phpfpm/Dockerfile-5.6 apache-phpfpm/Dockerfile-5.6debian
cp apache-phpfpm/Dockerfile-7.2 apache-phpfpm/Dockerfile-7.2debian
cp apache-phpfpm/Dockerfile-7.4 apache-phpfpm/Dockerfile-7.4debian
cp apache-phpfpm/Dockerfile-8.0 apache-phpfpm/Dockerfile-8.0debian
cp apache-phpfpm/Dockerfile-8.1 apache-phpfpm/Dockerfile-8.1debian
cp apache-phpfpm/Dockerfile-8.2 apache-phpfpm/Dockerfile-8.2debian
cp apache-phpfpm/Dockerfile-multi apache-phpfpm/Dockerfile-multidebian
sed -i s/"eilandert\/php-fpm:"/"eilandert\/php-fpm:deb-"/ apache-phpfpm/*debian

####
## SCRIPT NGINX PROXY
###

cp nginx-proxy-modsecurity-pagespeed/Dockerfile-template nginx-proxy-modsecurity-pagespeed/Dockerfile
cp nginx-proxy-modsecurity-pagespeed/Dockerfile-template nginx-proxy-modsecurity-pagespeed/Dockerfile-php56
cp nginx-proxy-modsecurity-pagespeed/Dockerfile-template nginx-proxy-modsecurity-pagespeed/Dockerfile-php72
cp nginx-proxy-modsecurity-pagespeed/Dockerfile-template nginx-proxy-modsecurity-pagespeed/Dockerfile-php74
cp nginx-proxy-modsecurity-pagespeed/Dockerfile-template nginx-proxy-modsecurity-pagespeed/Dockerfile-php80
cp nginx-proxy-modsecurity-pagespeed/Dockerfile-template nginx-proxy-modsecurity-pagespeed/Dockerfile-php81
cp nginx-proxy-modsecurity-pagespeed/Dockerfile-template nginx-proxy-modsecurity-pagespeed/Dockerfile-php82

cp nginx-proxy-modsecurity-pagespeed/Dockerfile-template nginx-proxy-modsecurity-pagespeed/Dockerfile-multi

cp nginx-proxy-modsecurity-pagespeed/Dockerfile-template nginx-proxy-modsecurity-pagespeed/Dockerfile-debian
cp nginx-proxy-modsecurity-pagespeed/Dockerfile-template nginx-proxy-modsecurity-pagespeed/Dockerfile-php56debian
cp nginx-proxy-modsecurity-pagespeed/Dockerfile-template nginx-proxy-modsecurity-pagespeed/Dockerfile-php72debian
cp nginx-proxy-modsecurity-pagespeed/Dockerfile-template nginx-proxy-modsecurity-pagespeed/Dockerfile-php74debian
cp nginx-proxy-modsecurity-pagespeed/Dockerfile-template nginx-proxy-modsecurity-pagespeed/Dockerfile-php80debian
cp nginx-proxy-modsecurity-pagespeed/Dockerfile-template nginx-proxy-modsecurity-pagespeed/Dockerfile-php81debian
cp nginx-proxy-modsecurity-pagespeed/Dockerfile-template nginx-proxy-modsecurity-pagespeed/Dockerfile-php82debian
cp nginx-proxy-modsecurity-pagespeed/Dockerfile-template nginx-proxy-modsecurity-pagespeed/Dockerfile-multidebian

sed -i 's/#FROM#/eilandert\/ubuntu-base:rolling/' nginx-proxy-modsecurity-pagespeed/Dockerfile
sed -i 's/#FROM#/eilandert\/php-fpm:multi/' nginx-proxy-modsecurity-pagespeed/Dockerfile-multi
sed -i 's/#FROM#/eilandert\/php-fpm:5.6/' nginx-proxy-modsecurity-pagespeed/Dockerfile-php56
sed -i 's/#FROM#/eilandert\/php-fpm:7.2/' nginx-proxy-modsecurity-pagespeed/Dockerfile-php72
sed -i 's/#FROM#/eilandert\/php-fpm:7.4/' nginx-proxy-modsecurity-pagespeed/Dockerfile-php74
sed -i 's/#FROM#/eilandert\/php-fpm:8.0/' nginx-proxy-modsecurity-pagespeed/Dockerfile-php80
sed -i 's/#FROM#/eilandert\/php-fpm:8.1/' nginx-proxy-modsecurity-pagespeed/Dockerfile-php81
sed -i 's/#FROM#/eilandert\/php-fpm:8.2/' nginx-proxy-modsecurity-pagespeed/Dockerfile-php82

sed -i 's/#FROM#/eilandert\/debian-base:stable/' nginx-proxy-modsecurity-pagespeed/Dockerfile-debian
sed -i 's/#FROM#/eilandert\/php-fpm:deb-multi/' nginx-proxy-modsecurity-pagespeed/Dockerfile-multidebian
sed -i 's/#FROM#/eilandert\/php-fpm:deb-5.6/' nginx-proxy-modsecurity-pagespeed/Dockerfile-php56debian
sed -i 's/#FROM#/eilandert\/php-fpm:deb-7.2/' nginx-proxy-modsecurity-pagespeed/Dockerfile-php72debian
sed -i 's/#FROM#/eilandert\/php-fpm:deb-7.4/' nginx-proxy-modsecurity-pagespeed/Dockerfile-php74debian
sed -i 's/#FROM#/eilandert\/php-fpm:deb-8.0/' nginx-proxy-modsecurity-pagespeed/Dockerfile-php80debian
sed -i 's/#FROM#/eilandert\/php-fpm:deb-8.1/' nginx-proxy-modsecurity-pagespeed/Dockerfile-php81debian
sed -i 's/#FROM#/eilandert\/php-fpm:deb-8.2/' nginx-proxy-modsecurity-pagespeed/Dockerfile-php82debian

rm -rf nginx-quic/*
cp -rp nginx-proxy-modsecurity-pagespeed/* nginx-quic
sed -i s/"\#TEMPLATE4\#"/"echo \"deb \[trusted=yes\] http:\/\/deb.myguard.nl\/quic\/ \${DIST} main\" > \/etc\/apt\/sources.list.d\/quic.list"/ nginx-quic/Dockerfile*
sed -i s/"\#TEMPLATE5\#"/"echo \"deb \[trusted=yes\] http:\/\/edge.deb.myguard.nl:8888\/quic\/ \${DIST} main\" >> \/etc\/apt\/sources.list.d\/quic.list"/ nginx-quic/Dockerfile*

export UBUNTU_ROLLING="jammy"

#SCRIPTS MARIADB
curl https://raw.githubusercontent.com/MariaDB/mariadb-docker/master/10.6/Dockerfile -o mariadb/Dockerfile.ubuntu
curl https://raw.githubusercontent.com/MariaDB/mariadb-docker/master/10.6/docker-entrypoint.sh -o mariadb/docker-entrypoint.sh
curl https://raw.githubusercontent.com/MariaDB/mariadb-docker/master/10.6/healthcheck.sh -o mariadb/healthcheck.sh
cp mariadb/Dockerfile.ubuntu mariadb/Dockerfile.debian
chmod +x mariadb/docker-entrypoint.sh
sed -i s/"FROM\ ubuntu:focal"/"FROM\ eilandert\/ubuntu-base:rolling\nCOPY bootstrap.sh \/"/ mariadb/Dockerfile.ubuntu
sed -i s/"FROM\ ubuntu:focal"/"FROM\ eilandert\/debian-base:stable\nCOPY bootstrap.sh \/"/ mariadb/Dockerfile.debian
sed -i s/"focal"/"${UBUNTU_ROLLING}"/g mariadb/Dockerfile.ubuntu
sed -i s/"focal"/"bullseye"/g mariadb/Dockerfile.debian
sed -i s/"repo\/ubuntu"/"repo\/debian"/g mariadb/Dockerfile.debian
sed -i s/"ENTRYPOINT \[\"docker-entrypoint.sh\"\]"/"ENTRYPOINT \[\"\/usr\/local\/bin\/docker-entrypoint.sh\"\]"/ mariadb/Dockerfile.*
sed -i s/"bin\/bash"/"bin\/bash\nbash \/bootstrap.sh"/ mariadb/docker-entrypoint.sh

sed -i s/"ubu2004"/"ubu2204"/g  mariadb/Dockerfile.ubuntu
sed -i s/"ubu2004"/"deb11"/g  mariadb/Dockerfile.debian

#commit upstream changes
git add mariadb/Dockerfile.debian
git add mariadb/Dockerfile.ubuntu
git add mariadb/docker-entrypoint.sh
git add mariadb/healthcheck.sh
git commit -m "Changes from upstream"
git push

#roundcube
cp roundcube/Dockerfile-template roundcube/Dockerfile-debian
cp roundcube/Dockerfile-template roundcube/Dockerfile-ubuntu
sed -i s/"#TEMPLATE1#"/"eilandert\/apache-phpfpm:8\.0/"     roundcube/Dockerfile-ubuntu
sed -i s/"#TEMPLATE1#"/"eilandert\/apache-phpfpm:deb-8\.0"/ roundcube/Dockerfile-debian

#LASTVERSION=$(lastversion -b 1.5 roundcube https://github.com/roundcube/roundcubemail/)
#if [ "${LASTVERSION}" == "" ]; then
#   echo "LASTVERSION EMPTY"
#else
#   echo ${LASTVERSION} > roundcube/.lastversion
#fi


