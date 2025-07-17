#!/bin/bash

# Filename:    Rocky_Linux_9_Install_PHP7_3_PHPFPM.sh
# Revision:    1.0
# Date:        2025/06/25
# Author:      star
# Email:       star@xgss.net
# Description: Rocky Linux 9系统中源码包安装php7.3 phpfpm，shell脚本
# 安装目录为：/data/app/php7.3 、用户为 www 、端口自定义为 7300 。
# 安装扩展
# 需要安装：
# openssl
# memcached
# libmemcached
# phpredis
# pcntl
# amqp
# rabbitmq
# swoole

# 使用：
# gitee:
# wget https://gitee.com/funet8/Rocky-Linux-Shell/raw/main/shell/Rocky_Linux_9_Install_PHP7_3_PHPFPM.sh
# sh Rocky_Linux_9_Install_PHP7_3_PHPFPM.sh
# github:
# wget https://raw.githubusercontent.com/funet8/Rocky-Linux-Shell/refs/heads/main/shell/Rocky_Linux_9_Install_PHP7_3_PHPFPM.sh
# sh Rocky_Linux_9_Install_PHP7_3_PHPFPM.sh
# -------------------------------------------------------------------------------

###########################################################
# 1.下载PHP7.3.3源码包安装
# 2.安装 openssl 、memcache 、phpredis扩展
# 3.修改配端口7300，时区、PHP进程数等。
# 4.安装目录 ${PHP_DIR} ，用户 www。
###########################################################
#上传php7.3-software.tar.gz 到 /data/software


PHP_DIR=/data/app/php7.3		#php安装路径
SOFTWARE_PHP7="/data/software/php7.3"
USER=www						#用户
PHP_PORT='7300'					#php-fpm端口
PHP_LOG="/data/app/php7.3-install.log"


# 检查当前用户是否为 root
if [[ $EUID -ne 0 ]]; then
   echo "错误: 此脚本必须以 root 用户身份运行。"
   exit 1
fi

# 检查操作系统是否为 Rocky Linux 9 (或类似的 RHEL 9 系列)
if ! grep -q "Rocky Linux 9" /etc/os-release; then
    echo "警告: 此脚本设计用于 Rocky Linux 9。在其他系统上可能无法正常工作。"
    read -p "是否继续? (y/N): " choice
    if [[ ! "$choice" =~ ^[yY]$ ]]; then
        echo "安装已取消。"
        exit 1
    fi
fi
# 日志函数
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> $PHP_LOG
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}


#新建用户和用户组######################################################################
groupadd $USER
useradd -g $USER $USER


# 安装编译 PHP 所需的依赖包
# 注意: mysql-devel 或 mariadb-devel 用于 mysqli 和 pdo_mysql 扩展
# libzip-devel 用于 zip 扩展
# oniguruma-devel 用于 mbstring 扩展
# libicu-devel 用于 intl 扩展
# libwebp-devel 用于 webp 支持 (GD库)
# libtirpc-devel: mariadb-devel 的一个常见依赖

# 安装依赖
log "......正在安装依赖......"
# 清理缓存并更新软件包列表
dnf clean all
dnf makecache
dnf groupinstall "Development Tools" -y
dnf install -y wget gcc gcc-c++ make \
    autoconf automake libtool \
    bison re2c \
    libxml2-devel \
    sqlite-devel \
    bzip2-devel \
    libcurl-devel curl-devel \
    libffi-devel \
    libpng-devel \
    libwebp-devel \
    libjpeg-devel \
    oniguruma \
    libzip \
    libicu-devel \
    openssl-devel \
    libuuid-devel \
    systemd-devel \
    libxslt-devel \
    readline-devel
	
#报错：
#Unable to find a match: libzip-devel oniguruma-devel
#wget https://dl.rockylinux.org/pub/rocky/9/devel/x86_64/os/Packages/o/oniguruma-devel-6.9.6-1.el9.6.x86_64.rpm
wget http://js.funet8.com/rocky-linux/php/oniguruma-devel-6.9.6-1.el9.6.x86_64.rpm
dnf -y install oniguruma-devel-6.9.6-1.el9.6.x86_64.rpm

#wget https://dl.rockylinux.org/pub/rocky/9/devel/x86_64/os/Packages/l/libzip-devel-1.7.3-8.el9.x86_64.rpm
wget http://js.funet8.com/rocky-linux/php/libzip-devel-1.7.3-8.el9.x86_64.rpm
dnf -y install libzip-devel-1.7.3-8.el9.x86_64.rpm
log "......依赖安装完成......"

# 在 Rocky Linux 9 上安装 OpenSSL 1.1.x（用于编译 PHP 7.3.x）是可行的，不会影响系统自带的 OpenSSL 3.x，只需将其安装到指定路径并在 PHP 编译时引用。
cd /usr/local/src
wget http://js.funet8.com/rocky-linux/php/openssl-1.1.1u.tar.gz
tar -zxf openssl-1.1.1u.tar.gz
cd openssl-1.1.1u
./config --prefix=/usr/local/openssl-1.1.1 --openssldir=/usr/local/openssl-1.1.1 shared zlib
make -j$(nproc)
make install
# 验证
/usr/local/openssl-1.1.1/bin/openssl version




#下载tar包-解压######################################################################
mkdir -p $PHP_DIR
mkdir -p /data/software && cd /data/software
wget http://js.funet8.com/centos_software/php7.3-software.tar.gz
tar -zxf php7.3-software.tar.gz

#编译安装php7.3######################################################################
function install_php7 {
		cd /data/software/php7.3-software/php-7.3.7
		
		./configure \
		--prefix=${PHP_DIR} \
		--with-config-file-path=${PHP_DIR}/etc \
		--with-fpm-user=${USER} \
		--with-fpm-group=${USER} \
		--enable-fpm \
		--enable-inline-optimization \
		--disable-debug \
		--disable-rpath \
		--enable-shared \
		--enable-soap \
		--with-libxml-dir \
		--with-xmlrpc \
		--with-openssl \
		--with-mhash \
		--with-pcre-regex \
		--with-sqlite3 \
		--with-zlib \
		--enable-bcmath \
		--with-iconv \
		--with-bz2 \
		--enable-calendar \
		--with-curl \
		--with-cdb \
		--enable-dom \
		--enable-exif \
		--enable-fileinfo \
		--enable-filter \
		--with-pcre-dir \
		--enable-ftp \
		--with-gd \
		--with-openssl-dir \
		--with-jpeg-dir \
		--with-png-dir \
		--with-zlib-dir \
		--with-freetype-dir \
		--enable-gd-jis-conv \
		--with-gettext \
		--with-gmp \
		--with-mhash \
		--enable-json \
		--enable-mbstring \
		--enable-mbregex \
		--enable-mbregex-backtrack \
		--with-onig \
		--enable-pdo \
		--with-mysqli=mysqlnd \
		--with-pdo-mysql=mysqlnd \
		--with-zlib-dir \
		--with-pdo-sqlite \
		--with-readline \
		--enable-session \
		--enable-shmop \
		--enable-simplexml \
		--enable-sockets \
		--enable-sysvmsg \
		--enable-sysvsem \
		--enable-sysvshm \
		--enable-wddx \
		--with-libxml-dir \
		--with-xsl \
		--enable-zip \
		--enable-mysqlnd-compression-support \
		--with-pear \
		--enable-opcache
	if [ $? -eq 0 ];then
		make && make install
	
	else
			echo 'php安装错误！'
			exit 1
	fi
	}
#配置环境变量######################################################################
function config_profile {
	cp -a ${PHP_DIR}/bin/php ${PHP_DIR}/bin/php7.3
	echo "export PATH=$PATH:${PHP_DIR}/bin">>/etc/profile	
	source /etc/profile
	php7.3 -v
}

#安装php扩展######################################################################
function install_kuozhan {
	#安装SSL库
	cd /data/software/php7.3-software/openssl-1.0.1j/
	./config
	make && make install
	
	
	#安装memcache扩展
	yum install -y libmemcached libmemcached-devel
	cd /data/software/php7.3-software/libmemcached-1.0.16
	./configure
	make && make install
	
	cd /data/software/php7.3-software/php-memcached/
	${PHP_DIR}/bin/phpize
	./configure -with-php-config=${PHP_DIR}/bin/php-config
	make  -j4
	make install
	
	
	#安装phpredis扩展
	cd /data/software/php7.3-software/phpredis
	${PHP_DIR}/bin/phpize
	./configure --with-php-config=${PHP_DIR}/bin/php-config
	make && make install
	
	cd /data/software/php7.3-software/php-7.3.7/ext/pcntl
	${PHP_DIR}/bin/phpize
	./configure --with-php-config=${PHP_DIR}/bin/php-config
	make && make install

	
	#systemctl restart php-fpm
	#php -m|grep redis
	#php -m|grep memcache
}

#配置php7.3######################################################################
function config_php {

	cp /data/software/php7.3-software/php-7.3.7/php.ini-production ${PHP_DIR}/etc/php.ini
	cp /data/software/php7.3-software/php-7.3.7/sapi/fpm/php-fpm.conf ${PHP_DIR}/etc/php-fpm.conf
	cp ${PHP_DIR}/etc/php-fpm.d/www.conf.default ${PHP_DIR}/etc/php-fpm.d/www.conf
	cp /data/software/php7.3-software/php-7.3.7/sapi/fpm/init.d.php-fpm /etc/init.d/php7.3-fpm
	chmod 755 /etc/init.d/php7.3-fpm

	#修改phpfpm端口
	sed -i "s/listen \= 127\.0\.0\.1\:9000/listen \= 127\.0\.0\.1\:${PHP_PORT}/g" ${PHP_DIR}/etc/php-fpm.d/www.conf
	
	#修改php.ini时区
	sed -i "s/\;date\.timezone \=/date\.timezone \= \"Asia\/Shanghai\"/g" ${PHP_DIR}/etc/php.ini

	# 修改php进程数
	sed -i "s/pm\.max\_children \= 5/pm\.max\_children \= 20/g" ${PHP_DIR}/etc/php-fpm.d/www.conf
	
	# 修改 request_terminate_timeout = 60 （请求终止超时）
	sed -i "s/\;request\_terminate\_timeout \= 0/request\_terminate\_timeout \= 30/g" ${PHP_DIR}/etc/php-fpm.d/www.conf


	#添加redis、memcached扩展
	echo 'extension=${PHP_DIR}/lib/php/extensions/no-debug-non-zts-20180731/redis.so'>> ${PHP_DIR}/etc/php.ini
	echo 'extension=${PHP_DIR}/lib/php/extensions/no-debug-non-zts-20180731/memcached.so' >> ${PHP_DIR}/etc/php.ini
	echo 'extension=${PHP_DIR}/lib/php/extensions/no-debug-non-zts-20180731/pcntl.so' >> ${PHP_DIR}/etc/php.ini 
	
	/etc/init.d/php7.3-fpm restart

	#开机启动	
	echo '/etc/init.d/php7.3-fpm start' >> /etc/rc.local 

	#cd ${PHP_DIR}/etc/
	#wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/centos7_PHP7.3_PHPFPM/conf/php.ini
	#wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/centos7_PHP7.3_PHPFPM/conf/php-fpm.conf
	#cd /usr/lib/systemd/system/
	#wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/centos7_PHP7.3_PHPFPM/conf/php-fpm.service

	#加入白名单
	iptables -A INPUT -p tcp --dport ${PHP_PORT} -j ACCEPT
	service iptables save
	systemctl restart iptables
		
}

#配置install_php5_zip，如果系统安装了5.6######################################################################
function install_php5_zip {
	rm -rf /usr/lib64/php/modules/zip.so
	cd /data/software/
	wget http://js.funet8.com/centos_software/zip-1.13.5.tgz
	tar zxvf zip-1.13.5.tgz
	cd /data/software/zip-1.13.5
	/usr/bin/phpize
	./configure --with-php-config=/usr/bin/php-config
	make && make install


	make && make install
	#添加redis扩展配置
	echo "extension=${PHP_DIR}/lib/php/extensions/no-debug-non-zts-20180731/redis.so">> ${PHP_DIR}/etc/php.ini
	${PHP_DIR}/bin/php -m|grep redis

	cd /data/software/php7.3/php7.3-software/php-7.3.7/ext/pcntl
	${PHP_DIR}/bin/phpize
	./configure --with-php-config=${PHP_DIR}/bin/php-config
	make && make install
	echo "extension=${PHP_DIR}/lib/php/extensions/no-debug-non-zts-20180731/pcntl.so" >> ${PHP_DIR}/etc/php.ini 
	${PHP_DIR}/bin/php -m|grep pcntl
}
function install_amqp(){
	#安装 rabbitmq-c
	cd ${SOFTWARE_PHP7}
	# wget -c https://github.com/alanxz/rabbitmq-c/releases/download/v0.8.0/rabbitmq-c-0.8.0.tar.gz
	wget -c http://js.funet8.com/centos_software/rabbitmq-php/rabbitmq-c-0.8.0.tar.gz
	tar zxf rabbitmq-c-0.8.0.tar.gz
	cd rabbitmq-c-0.8.0
	./configure --prefix=/usr/local/rabbitmq-c-0.8.0-b
	make && make install

	# 安装 amqp-1.11.0 扩展
	cd ${SOFTWARE_PHP7}
	#wget -c http://pecl.php.net/get/amqp-1.11.0.tgz
	wget -c http://js.funet8.com/centos_software/rabbitmq-php/amqp-1.11.0.tgz
	tar -zxvf amqp-1.11.0.tgz 
	cd  amqp-1.11.0
	${PHP_DIR}/bin/phpize
	./configure --with-php-config=${PHP_DIR}/bin/php-config --with-amqp --with-librabbitmq-dir=/usr/local/rabbitmq-c-0.8.0-b
	make && make install
	echo '[amqp]'>> ${PHP_DIR}/etc/php.ini 
	echo "extension=${PHP_DIR}/lib/php/extensions/no-debug-non-zts-20180731/amqp.so" >> ${PHP_DIR}/etc/php.ini 
	${PHP_DIR}/bin/php -m|grep amqp
}
function install_swoole(){
	#安装 swoole 扩展
	dnf install -y c-ares-devel
	cd ${SOFTWARE_PHP7}
	wget http://js.funet8.com/centos_software/swoole-src-4.8.13.tar.gz
	tar -zxvf swoole-src-4.8.13.tar.gz
	cd swoole-src-4.8.13
	${PHP_DIR}/bin/phpize
	./configure --enable-openssl --enable-sockets --enable-mysqlnd --enable-swoole-curl --enable-cares  --with-php-config=${PHP_DIR}/bin/php-config
	make && make install
	echo "extension=${PHP_DIR}/lib/php/extensions/no-debug-non-zts-20180731/swoole.so" >> ${PHP_DIR}/etc/php.ini 
	echo 'swoole.use_shortname = off' >> ${PHP_DIR}/etc/php.ini 
	${PHP_DIR}/bin/php -m|grep swoole
}


install_php7
config_profile
install_kuozhan
config_php





