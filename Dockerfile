FROM jerrytechtree/docker-laravel-base
MAINTAINER Jerry Zhang "jerry_techtree@126.com"
ENV REFRESHED_AT 2016-02-03

ENV PHP_VERSION 7.0.2
ENV PHP_TAR_FILENAME php-$PHP_VERSION.tar.gz
ENV PHP_DOWNLOAD_URL http://cn2.php.net/get/$PHP_TAR_FILENAME/from/this/mirror
ENV SOFTWARE_DIR /software
ENV PHP_TAR_FILE $SOFTWARE_DIR/$PHP_TAR_FILENAME
ENV PHP_SOURCE_DIR $SOFTWARE_DIR/php
ENV PHP_INSTALL_DIR /usr/local/php
ENV MYSQL_SOCK /var/run/mysqld/mysqld.sock
ENV PHP_USER php-fpm
ENV PHP_CONFIG $PHP_INSTALL_DIR/lib/php.ini
ENV PHP_FPM_CONFIG $PHP_INSTALL_DIR/etc/php-fpm.conf
ENV PHP_FPM_WWW_CONFIG $PHP_INSTALL_DIR/etc/php-fpm.d/www.conf


# install dependencies
RUN apt-get update && apt-get install -y \
	build-essential \
	gcc \
	make \
	curl \
	libfcgi-dev \
	libfcgi0ldbl \
	libjpeg-turbo8-dbg \
	libmcrypt-dev \
	libssl-dev \
	libc-client2007e \
	libc-client2007e-dev \
	libxml2-dev \
	libbz2-dev \
	libcurl4-openssl-dev \
	libjpeg-dev \
	libpng12-dev \
	libfreetype6-dev \
	libkrb5-dev \
	libpq-dev \
	libxml2-dev \
	libxslt1-dev

# download php source code
RUN curl $PHP_DOWNLOAD_URL -o $PHP_TAR_FILE && \
	tar -zxvf $PHP_TAR_FILE -C $SOFTWARE_DIR && \
	mv $SOFTWARE_DIR/php-$PHP_VERSION $PHP_SOURCE_DIR	

# add user & group
RUN groupadd -r $PHP_USER && \
	useradd -M -s /sbin/nologin -r -g $PHP_USER $PHP_USER

# install php
RUN cd $PHP_SOURCE_DIR && \
	./configure \
	--prefix=$PHP_INSTALL_DIR \
	--with-zlib-dir \
	--with-freetype-dir \
	--enable-mbstring \
	--with-libxml-dir=\usr \
	--enable-calendar \
	--with-curl \
	--with-mcrypt \
	--with-zlib \
	--with-gd \
	--with-bz2 \
	--with-zlib \
	--enable-sockets \
	--enable-sysvsem \
	--enable-sysvshm \
	--enable-pcntl \
	--enable-bcmath \
	--enable-zip \
	--with-pcre-regex \
	--with-pdo-mysql \
	--with-mysqli \
	--with-mysql-sock=$MYSQL_SOCK \
	--with-jpeg-dir=\usr \
	--with-png-dir=\usr \
	--enable-gd-native-ttf \
	--with-openssl \
	--with-fpm-user=$PHP_USER \
	--with-fpm-group=$PHP_USER \
	--with-libdir=\lib\x86_64-linux-gnu \
	--with-gettext \
	--with-xmlrpc \
	--with-xsl \
	--enable-fpm \
	&& make && make install

# install supervisor
RUN apt-get install -y supervisor

# make softlink
RUN ln -s $PHP_INSTALL_DIR/bin/php /usr/local/bin/php 
RUN ln -s $PHP_INSTALL_DIR/sbin/php-fpm /usr/local/bin/php-fpm 

# copy configure
COPY conf/php.ini $PHP_CONFIG
COPY conf/php-fpm.conf $PHP_FPM_CONFIG
COPY conf/php-fpm-www.conf $PHP_FPM_WWW_CONFIG

# install composer
RUN curl -sS http://install.phpcomposer.com/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer

# install phpunit

# copy other config
COPY conf/supervisor/ /etc/supervisor/conf.d/

# clean cache
RUN apt-get clean \
	&& apt-get autoclean \
	&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /software

EXPOSE 9000

COPY scripts/start.sh /scripts/start.sh
ENTRYPOINT [ "/scripts/start.sh" ]
#ENTRYPOINT [ "bin/bash" ]
