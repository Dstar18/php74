FROM ubuntu:20.04

MAINTAINER hisam

ENV DEBIAN_FRONTEND noninteractive

# update ubuntu repository
RUN apt-get clean && apt-get update && \
    apt-get update && \
    # date time config
    apt-get -y install tzdata && \
    ln -sf /usr/share/zoneinfo/Asia/Jakarta /etc/localtime && \
    # install nginx, php-fpm and php modules
    apt-get -y install nginx php7.4 php7.4-fpm php7.4-mysql && \
    apt-get -y install php7.4-curl php7.4-xml php7.4-xmlrpc php-mongodb && \
    apt-get -y install php7.4-bz2 php7.4-zip php7.4-pgsql php7.4-gd && \
    apt-get -y install supervisor && \
    apt-get -y install phpunit

# disable default site
RUN rm -f /etc/nginx/sites-enabled/default
# enable site's vhost
COPY nginx-conf/clientsite.conf /etc/nginx/sites-enabled/default.conf
# disable default fpm pool
RUN rm -f /etc/php/7.4/fpm/pool.d/www.conf
# fpm pool for site
COPY nginx-conf/clientsite-fpm.conf /etc/php/7.4/fpm/pool.d/clientsite-fpm.conf

# php ini
COPY php/php.ini /etc/php/7.4/fpm/php.ini


# create dir for php-fpm socket
RUN mkdir -p /var/run/php/

#create user & group
ARG user=clientsite
ARG group=clientsite
ARG uid=1000
ARG gid=1001

RUN groupadd ${group} --gid ${gid}
RUN useradd ${user} -u ${uid} -m -g ${group}

#run as user
USER ${user}
RUN mkdir /home/${user}/public_html
RUN mkdir /home/${user}/log

#run as root
USER root
COPY supervisord-conf/supervisord.conf /etc/supervisor/supervisord.conf
#CMD ["/usr/bin/supervisord"]

CMD ["supervisord","--nodaemon","-c", "/etc/supervisor/supervisord.conf"]

EXPOSE 80