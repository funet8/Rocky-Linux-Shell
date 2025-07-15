#!/bin/bash

# Filename:    Rocky_Linux_9_Install_PHP8_3_PHPFPM.sh
# Revision:    1.0
# Date:        2023/06/01
# Author:      star
# Email:       star@xgss.net
# 功能: Rocky Linux 9系统中源码包安装php8.3 phpfpm，shell脚本
# 安装目录为：/data/app/php8.3
# 用户为 www 
# 端口自定义为 8300
# 需要PHP安装扩展
# zip
# openssl
# libmemcached
# phpredis
# pcntl
# amqp
# rabbitmq
# swoole

# 使用：
# gitee:
# wget https://gitee.com/funet8/Rocky-Linux-Shell/raw/main/shell/Rocky_Linux_9_Install_PHP8_3_PHPFPM.sh
# sh Rocky_Linux_9_Install_PHP8_3_PHPFPM.sh
# github:
# wget https://raw.githubusercontent.com/funet8/Rocky-Linux-Shell/refs/heads/main/shell/Rocky_Linux_9_Install_PHP8_3_PHPFPM.sh
# sh Rocky_Linux_9_Install_PHP8_3_PHPFPM.sh
# -------------------------------------------------------------------------------

# 设置变量
PHP_VERSION="8.3.3"
INSTALL_DIR="/data/app/php8.3"
PHP_software="/data/software"
SOFTWARE_PHP8="/data/software/php8.3"
PHP_FPM_PORT="8300"
PHP_USER="www"
PHP_GROUP="www"
PHP_LOG="/data/app/php8.3-install.log"

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


# 检查是否已安装PHP 8.3
if [ -f "${INSTALL_DIR}/bin/php" ] && ${INSTALL_DIR}/bin/php -v | grep -q "PHP ${PHP_VERSION}"; then
    log "PHP ${PHP_VERSION} is already installed at ${INSTALL_DIR}."
    read -p "Do you want to reinstall? (y/n): " choice
    case "$choice" in 
        y|Y ) log "Proceeding with reinstallation...";;
        * ) log "Installation aborted."; exit 0;;
    esac
fi

# 新建用户和用户组
groupadd $PHP_USER
useradd -g $PHP_GROUP $PHP_GROUP

# 安装EPEL仓库
log "安装EPEL仓库..."
dnf install -y epel-release || {
    log "Warning: Failed to install EPEL repository. Some packages may not be available."
}

# 安装依赖
log "......正在安装依赖......"
# 清理缓存并更新软件包列表
dnf clean all
dnf makecache
dnf install -y  wget libxml2-devel sqlite-devel bzip2-devel libcurl-devel libffi-devel libpng-devel libwebp-devel libjpeg-devel oniguruma libzip
dnf install -y gcc make autoconf automake libtool bison gcc  libicu-devel openssl-devel
dnf install -y gcc gcc-c++ make autoconf automake libtool bison re2c  openssl-devel libxml2-devel libpng-devel  libjpeg-devel  libicu-devel curl-devel   sqlite-devel libuuid-devel systemd-devel libxslt-devel readline-devel

#dnf install -y libzip-devel oniguruma-devel

#wget https://dl.rockylinux.org/pub/rocky/9/devel/x86_64/os/Packages/o/oniguruma-devel-6.9.6-1.el9.6.x86_64.rpm
wget http://js.funet8.com/rocky-linux/php/oniguruma-devel-6.9.6-1.el9.6.x86_64.rpm
dnf -y install oniguruma-devel-6.9.6-1.el9.6.x86_64.rpm

#wget https://dl.rockylinux.org/pub/rocky/9/devel/x86_64/os/Packages/l/libzip-devel-1.7.3-8.el9.x86_64.rpm
wget http://js.funet8.com/rocky-linux/php/libzip-devel-1.7.3-8.el9.x86_64.rpm
dnf -y install libzip-devel-1.7.3-8.el9.x86_64.rpm
log "......依赖安装完成......"


# 安装依赖包
log "安装开发工具和依赖项..."
dnf groupinstall "Development Tools" -y || {
    log "Warning: Failed to install Development Tools group. Will try to install individual packages."
}

#下载tar包-解压######################################################################
mkdir -p ${INSTALL_DIR} ${SOFTWARE_PHP8}
mkdir -p ${PHP_software} && cd ${PHP_software}

# 安装PHP8.3.3
function install_php8 {
	cd ${PHP_software}
    #wget https://www.php.net/distributions/php-8.3.3.tar.gz
	wget http://js.funet8.com/centos_software/php8/php-8.3.3.tar.gz
	tar -zxf php-8.3.3.tar.gz
	cd ${PHP_software}/php-8.3.3
	
    ./configure \
    --with-fpm-user=${PHP_USER} \
    --with-fpm-group=${PHP_GROUP} \
    --prefix=${INSTALL_DIR} \
    --with-config-file-path=${INSTALL_DIR}/etc \
    --with-openssl \
    --with-zlib \
    --with-bz2 \
    --with-curl \
    --enable-bcmath \
    --enable-gd \
    --with-webp \
    --with-jpeg \
    --with-mhash \
    --enable-mbstring \
    --with-imap-ssl \
    --with-mysqli \
    --enable-exif \
    --with-ffi \
    --with-zip \
    --enable-sockets \
    --with-pcre-jit \
    --enable-fpm \
    --with-pdo-mysql \
    --enable-pcntl

    make && make install
}

# 安装php扩展 ######################################################################
function install_kuozhan {
	cd ${SOFTWARE_PHP8}
	########################################
	# 安装phpredis扩展
	# wget  http://js.funet8.com/centos_software/php8/redis-5.3.2.tgz
	# https://github.com/phpredis/phpredis/releases
	########################################
	wget  http://js.funet8.com/centos_software/php8/phpredis-6.0.2.tar.gz
	tar xzf phpredis-6.0.2.tar.gz
	cd ${SOFTWARE_PHP8}/phpredis-6.0.2
	${INSTALL_DIR}/bin/phpize
	./configure --with-php-config=${INSTALL_DIR}/bin/php-config
	make && make install
	
	########################################
	# 安装zip扩展
	# https://learnku.com/articles/82609
	########################################
	cd ${SOFTWARE_PHP8}
	#wget https://pecl.php.net/get/zip-1.22.1.tgz
	wget  http://js.funet8.com/centos_software/php8/zip-1.22.1.tgz
	tar zxf zip-1.22.1.tgz
	cd ${SOFTWARE_PHP8}/zip-1.22.1
	${INSTALL_DIR}/bin/phpize
	./configure --with-php-config=${INSTALL_DIR}/bin/php-config
	make && make install
	
	########################################
	# 安装swoole扩展
	# https://github.com/swoole/swoole-src
	# wget https://github.com/swoole/swoole-src/archive/refs/tags/v5.1.2.tar.gz
	########################################
	cd ${SOFTWARE_PHP8}
	wget  http://js.funet8.com/centos_software/php8/swoole-src-5.1.2.tar.gz
	tar -zxf swoole-src-5.1.2.tar.gz
	cd ${SOFTWARE_PHP8}/swoole-src-5.1.2
	${INSTALL_DIR}/bin/phpize
	./configure --with-php-config=${INSTALL_DIR}/bin/php-config
	make && make install
	
}

# php安装amqp扩展 ######################################################################
function install_amqp {
		########################################
		# 安装rabbitmq
		# https://github.com/alanxz/rabbitmq-c
		# wget -c https://github.com/alanxz/rabbitmq-c/releases/download/v0.8.0/rabbitmq-c-0.8.0.tar.gz
		########################################	
		cd ${SOFTWARE_PHP8}
		wget -c http://js.funet8.com/centos_software/rabbitmq-php/rabbitmq-c-0.8.0.tar.gz
		tar zxf rabbitmq-c-0.8.0.tar.gz
		cd rabbitmq-c-0.8.0
		./configure --prefix=/usr/local/rabbitmq-c-0.8.0
		make && make install

		########################################
		# 安装amqp扩展
		# http://pecl.php.net/package/amqp
		# wget http://pecl.php.net/get/amqp-2.1.2.tgz
		########################################
		cd ${SOFTWARE_PHP8}
		wget  http://js.funet8.com/centos_software/php8/amqp-2.1.2.tgz
		tar -zxf amqp-2.1.2.tgz
		cd ${SOFTWARE_PHP8}/amqp-2.1.2
		${INSTALL_DIR}/bin/phpize
		./configure --with-php-config=${INSTALL_DIR}/bin/php-config --with-amqp --with-librabbitmq-dir=/usr/local/rabbitmq-c-0.8.0
		make && make install
		
}
#配置php配置######################################################################
function config_php {

	cp ${PHP_software}/php-8.3.3/php.ini-production ${INSTALL_DIR}/etc/php.ini
	cp ${PHP_software}/php-8.3.3/sapi/fpm/php-fpm.conf ${INSTALL_DIR}/etc/php-fpm.conf
	cp ${INSTALL_DIR}/etc/php-fpm.d/www.conf.default ${INSTALL_DIR}/etc/php-fpm.d/www.conf

    # 修改 PHP-FPM 配置
    sed -i "s|^listen = 127.0.0.1:9000|listen = 127.0.0.1:${PHP_FPM_PORT}|" "${INSTALL_DIR}/etc/php-fpm.d/www.conf"
    sed -i "s|^;listen.allowed_clients|listen.allowed_clients|" "${INSTALL_DIR}/etc/php-fpm.d/www.conf"
    sed -i "s|^;pid = run/php-fpm.pid|pid = run/php-fpm.pid|" "${INSTALL_DIR}/etc/php-fpm.conf"
    # 修改php进程数
	sed -i "s/pm\.max\_children \= 5/pm\.max\_children \= 20/g" ${INSTALL_DIR}/etc/php-fpm.d/www.conf
    # 修改 request_terminate_timeout = 30 （请求终止超时）
	sed -i "s/\;request\_terminate\_timeout \= 0/request\_terminate\_timeout \= 30/g" ${INSTALL_DIR}/etc/php-fpm.d/www.conf


    # 修改 PHP.ini 配置
    sed -i "s|^;date.timezone =|date.timezone = Asia/Shanghai|" "${INSTALL_DIR}/etc/php.ini"
    sed -i "s|^memory_limit = 128M|memory_limit = 256M|" "${INSTALL_DIR}/etc/php.ini"
    sed -i "s|^;cgi.fix_pathinfo=1|cgi.fix_pathinfo=0|" "${INSTALL_DIR}/etc/php.ini"
    sed -i "s|^upload_max_filesize = 2M|upload_max_filesize = 32M|" "${INSTALL_DIR}/etc/php.ini"
    sed -i "s|^post_max_size = 8M|post_max_size = 32M|" "${INSTALL_DIR}/etc/php.ini"
    #sed -i "s|^max_execution_time = 30|max_execution_time = 300|" "${INSTALL_DIR}/etc/php.ini"


    #添加扩展
	echo 'extension=redis.so'>> ${INSTALL_DIR}/etc/php.ini
	#echo 'extension=zip.so'>> ${INSTALL_DIR}/etc/php.ini
	echo 'extension=swoole.so'>> ${INSTALL_DIR}/etc/php.ini
	echo 'extension=amqp.so'>> ${INSTALL_DIR}/etc/php.ini
	# 显示扩展
	${INSTALL_DIR}/bin/php -m|grep redis
	${INSTALL_DIR}/bin/php -m|grep zip
	${INSTALL_DIR}/bin/php -m|grep swoole
	${INSTALL_DIR}/bin/php -m|grep amqp


		
}

#配置环境变量######################################################################
function config_profile {
	cp -a ${INSTALL_DIR}/bin/php ${INSTALL_DIR}/bin/php8.3
	echo "export PATH=$PATH:${INSTALL_DIR}/bin">>/etc/profile
	source /etc/profile
	php8.3 -v
}
# 开机启动脚本配置
config_start(){
# 创建启动脚本
log "Creating startup script..."
cat > /etc/systemd/system/php8.3-fpm.service << EOF
[Unit]
Description=PHP 8.3 FastCGI Process Manager
After=network.target

[Service]
Type=simple
PIDFile=${INSTALL_DIR}/var/run/php-fpm.pid
ExecStart=${INSTALL_DIR}/sbin/php-fpm --nodaemonize --fpm-config ${INSTALL_DIR}/etc/php-fpm.conf
ExecReload=/bin/kill -USR2 \$MAINPID
ExecStop=/bin/kill -SIGINT \$MAINPID
PrivateTmp=true
RestartSec=5s
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable php8.3-fpm.service
systemctl start php8.3-fpm.service

}
config_firewall(){
    # 配置防火墙
    firewall-cmd --permanent --add-port=${PHP_FPM_PORT}/tcp
    firewall-cmd --reload
}


# 安装PHP8.3.3
install_php8

# 安装php扩展
install_kuozhan

# 安装php扩展amqp
install_amqp
# 配置PHP和PHP-FPM
config_php
# 配置PHP环境变量
config_profile
# 配置开机启动脚本
config_start

config_firewall