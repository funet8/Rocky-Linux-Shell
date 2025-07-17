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
# phpredis
# pcntl
# amqp
# rabbitmq
# swoole
# 开机启动配置文件： /etc/systemd/system/php7.3-fpm.service
# 启动命令： systemctl start php7.3-fpm.service
# 停止命令： systemctl stop php7.3-fpm.service
# 重启命令： systemctl restart php7.3-fpm.service

# 使用：
# gitee:
# wget https://gitee.com/funet8/Rocky-Linux-Shell/raw/main/shell/Rocky_Linux_9_Install_PHP7_3_PHPFPM.sh
# sh Rocky_Linux_9_Install_PHP7_3_PHPFPM.sh
# github:
# wget https://raw.githubusercontent.com/funet8/Rocky-Linux-Shell/refs/heads/main/shell/Rocky_Linux_9_Install_PHP7_3_PHPFPM.sh
# sh Rocky_Linux_9_Install_PHP7_3_PHPFPM.sh
# -------------------------------------------------------------------------------

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
function install_yinai(){
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
	dnf install -y perl perl-core perl-FindBin
	dnf install -y c-ares-devel
	dnf install -y compat-openssl11

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
	export LD_LIBRARY_PATH=/usr/local/openssl-1.1.1/lib:$LD_LIBRARY_PATH
	# 验证
	/usr/local/openssl-1.1.1/bin/openssl version
	# 系统永久生效
	echo 'export LD_LIBRARY_PATH=/usr/local/openssl-1.1.1/lib:$LD_LIBRARY_PATH' > /etc/profile.d/openssl1.1.sh
	chmod +x /etc/profile.d/openssl1.1.sh
	source /etc/profile.d/openssl1.1.sh
	log "......安装依赖完成......"
}


#下载tar包-解压######################################################################
mkdir -p ${PHP_DIR}
mkdir -p ${SOFTWARE_PHP7} && cd ${SOFTWARE_PHP7}

#编译安装php7.3######################################################################
function install_php7 {
		# wget https://www.php.net/distributions/php-7.3.7.tar.gz
		wget http://js.funet8.com/rocky-linux/php/php-7.3.7.tar.gz
		tar -zxf php-7.3.7.tar.gz
		cd php-7.3.7
		export PKG_CONFIG_PATH=/usr/local/openssl-1.1.1/lib/pkgconfig
		export CFLAGS="-I/usr/local/openssl-1.1.1/include"
		export LDFLAGS="-L/usr/local/openssl-1.1.1/lib"		
		
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
		--with-openssl=/usr/local/openssl-1.1.1 \
		--with-openssl-dir \
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
			log 'php安装错误！'
			exit 1
	fi
	log 'php7.3安装完成！'
}

#配置环境变量######################################################################
function config_profile {
	cp -a ${PHP_DIR}/bin/php ${PHP_DIR}/bin/php7.3
	echo "export PATH=$PATH:${PHP_DIR}/bin">>/etc/profile	
	source /etc/profile
	php7.3 -v
}

#修改php7.3配置文件######################################################################
function config_php {

	cp ${SOFTWARE_PHP7}/php-7.3.7/php.ini-production ${PHP_DIR}/etc/php.ini
	cp ${SOFTWARE_PHP7}/php-7.3.7/sapi/fpm/php-fpm.conf ${PHP_DIR}/etc/php-fpm.conf
	cp ${PHP_DIR}/etc/php-fpm.d/www.conf.default ${PHP_DIR}/etc/php-fpm.d/www.conf

	# 修改 PHP-FPM 配置
    sed -i "s|^listen = 127.0.0.1:9000|listen = 127.0.0.1:${PHP_PORT}|" "${PHP_DIR}/etc/php-fpm.d/www.conf"
    sed -i "s|^;listen.allowed_clients|listen.allowed_clients|" "${PHP_DIR}/etc/php-fpm.d/www.conf"
    sed -i "s|^;pid = run/php-fpm.pid|pid = run/php-fpm.pid|" "${PHP_DIR}/etc/php-fpm.conf"
	
    # 修改php进程数
	sed -i "s/pm\.max\_children \= 5/pm\.max\_children \= 20/g" "${PHP_DIR}/etc/php-fpm.d/www.conf"
	
    # 修改 request_terminate_timeout = 30 （请求终止超时）
	sed -i "s/\;request\_terminate\_timeout \= 0/request\_terminate\_timeout \= 30/g" "${PHP_DIR}/etc/php-fpm.d/www.conf"


    # 修改 PHP.ini 配置
    sed -i "s|^;date.timezone =|date.timezone = Asia/Shanghai|" "${PHP_DIR}/etc/php.ini"
    sed -i "s|^memory_limit = 128M|memory_limit = 256M|" "${PHP_DIR}/etc/php.ini"
    sed -i "s|^;cgi.fix_pathinfo=1|cgi.fix_pathinfo=0|" "${PHP_DIR}/etc/php.ini"
    sed -i "s|^upload_max_filesize = 2M|upload_max_filesize = 32M|" "${PHP_DIR}/etc/php.ini"
    sed -i "s|^post_max_size = 8M|post_max_size = 32M|" "${PHP_DIR}/etc/php.ini"


}

#安装php扩展######################################################################
function install_kuozhan {
	#安装phpredis扩展
	
	cd ${SOFTWARE_PHP7}
	wget http://js.funet8.com/rocky-linux/php/phpredis.tar.gz
	tar -zxvf phpredis.tar.gz
	cd phpredis
	${PHP_DIR}/bin/phpize
	./configure --with-php-config=${PHP_DIR}/bin/php-config
	make && make install
	echo "extension=${PHP_DIR}/lib/php/extensions/no-debug-non-zts-20180731/redis.so" >> ${PHP_DIR}/etc/php.ini 
	${PHP_DIR}/bin/php -m|grep redis
	
	cd ${SOFTWARE_PHP7}/php-7.3.7/ext/pcntl
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

function config_start(){
# 创建启动脚本
log "Creating startup script..."
cat > /etc/systemd/system/php7.3-fpm.service << EOF
[Unit]
Description=PHP 7.3 FastCGI Process Manager
After=network.target

[Service]
Type=simple
PIDFile=${PHP_DIR}/var/run/php-fpm.pid
ExecStart=${PHP_DIR}/sbin/php-fpm --nodaemonize --fpm-config ${PHP_DIR}/etc/php-fpm.conf
ExecReload=/bin/kill -USR2 \$MAINPID
ExecStop=/bin/kill -SIGINT \$MAINPID
PrivateTmp=true
RestartSec=5s
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable php7.3-fpm.service
systemctl start php7.3-fpm.service
echo "systemctl restart php7.3-fpm.service" > /root/restart_php7.3.sh

}

function config_firewall(){
    # 配置防火墙
    firewall-cmd --zone=public --add-port=${PHP_PORT}/tcp --permanent
    firewall-cmd --reload
    firewall-cmd --zone=public --list-ports
}

# 安装依耐
install_yinai
# 编译安装php7
install_php7
# 配置环境变量
config_profile
# 修改php7.3配置文件
config_php
# 安装php扩展
install_kuozhan
install_amqp
install_swoole

# 开机启动
config_start
# 防火墙
config_firewall






