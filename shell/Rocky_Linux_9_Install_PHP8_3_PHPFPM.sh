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





















# 安装libzip
mkdir -p $PHP_software
cd $PHP_software
log "Installing libzip..."
wget https://libzip.org/download/libzip-1.9.2.tar.gz
tar -xzvf libzip-1.9.2.tar.gz
cd libzip-1.9.2
mkdir build && cd build
cmake ..
make && make install
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig/

echo '/usr/local/lib64 /usr/local/lib /usr/lib /usr/lib64' >> /etc/ld.so.conf
ldconfig -v
export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

# 安装 openssl-3.x (PHP 8.3 支持 OpenSSL 3.x)
log "Installing OpenSSL 3.x..."
dnf install -y perl
cd $PHP_software
wget https://www.openssl.org/source/openssl-3.0.8.tar.gz
tar -xvzf openssl-3.0.8.tar.gz
cd openssl-3.0.8
./config --prefix=/usr/local/openssl3 --openssldir=/usr/local/openssl3
make -j"$(nproc)"
make install
/usr/local/openssl3/bin/openssl version

echo 'export PATH=/usr/local/openssl3/bin:$PATH' | sudo tee -a /etc/profile
echo 'export LD_LIBRARY_PATH=/usr/local/openssl3/lib:$LD_LIBRARY_PATH' | sudo tee -a /etc/profile
source /etc/profile
ln -sf /usr/local/openssl3/bin/openssl /usr/bin/openssl
ln -sf /usr/local/openssl3/lib64/libssl.so.3 /usr/lib64/libssl.so.3
ln -sf /usr/local/openssl3/lib64/libcrypto.so.3 /usr/lib64/libcrypto.so.3

# 检查关键依赖是否已安装
log "Verifying critical dependencies..."
for pkg in gcc make autoconf wget; do
    if ! command -v $pkg &> /dev/null; then
        log "Error: Required dependency '$pkg' is not installed or not in PATH."
        exit 1
    fi
done

# 创建配置目录
mkdir -p ${INSTALL_DIR}/etc/php.d
mkdir -p ${INSTALL_DIR}/var/run
mkdir -p ${INSTALL_DIR}/var/log

# 下载PHP源码
cd $PHP_software
log "Downloading PHP ${PHP_VERSION}..."
wget https://www.php.net/distributions/php-${PHP_VERSION}.tar.gz
tar xf php-${PHP_VERSION}.tar.gz
cd php-${PHP_VERSION}

# 配置PHP
log "Configuring PHP ${PHP_VERSION}..."
./configure \
    --prefix=${INSTALL_DIR} \
    --with-config-file-path=${INSTALL_DIR}/etc \
    --with-fpm-user=${PHP_USER} \
    --with-fpm-group=${PHP_GROUP} \
    --with-openssl=/usr/local/openssl3 \
    --enable-fpm \
    --enable-opcache \
    --enable-pcntl \
    --enable-mbstring \
    --enable-soap \
    --enable-calendar \
    --enable-exif \
    --enable-ftp \
    --enable-sockets \
    --enable-bcmath \
    --with-curl \
    --with-zlib \
    --with-zip \
    --with-pdo-mysql \
    --with-mysqli \
    --enable-gd \
    --with-webp \
    --with-jpeg \
    --with-freetype \
    --with-gettext \
    --with-xsl \
    --with-sodium \
    --enable-intl

# 编译和安装
log "Compiling PHP ${PHP_VERSION}. This may take a while..."
make -j $(nproc) || {
    log "Error: Compilation failed. Check the output above for errors."
    exit 1
}

log "Installing PHP ${PHP_VERSION}..."
make install || {
    log "Error: Installation failed. Check the output above for errors."
    exit 1
}

log "PHP ${PHP_VERSION} compiled and installed successfully."

# 配置PHP和PHP-FPM
log "Configuring PHP and PHP-FPM..."
cp php.ini-production ${INSTALL_DIR}/etc/php.ini
cp ${INSTALL_DIR}/etc/php-fpm.conf.default ${INSTALL_DIR}/etc/php-fpm.conf
cp ${INSTALL_DIR}/etc/php-fpm.d/www.conf.default ${INSTALL_DIR}/etc/php-fpm.d/www.conf



# 安装扩展
log "Installing PHP extensions..."

# 安装 libmemcached
log "Installing libmemcached..."
cd $PHP_software
dnf install -y libmemcached libmemcached-devel
wget https://github.com/php-memcached-dev/php-memcached/archive/refs/tags/v3.2.0.tar.gz -O php-memcached-3.2.0.tar.gz
tar -xzf php-memcached-3.2.0.tar.gz
cd php-memcached-3.2.0
${INSTALL_DIR}/bin/phpize
./configure --with-php-config=${INSTALL_DIR}/bin/php-config
make && make install
echo "extension=memcached.so" > ${INSTALL_DIR}/etc/conf.d/memcached.ini

# 安装 phpredis
log "Installing phpredis..."
cd $PHP_software
wget https://github.com/phpredis/phpredis/archive/refs/tags/5.3.7.tar.gz -O phpredis-5.3.7.tar.gz
tar -xzf phpredis-5.3.7.tar.gz
cd phpredis-5.3.7
${INSTALL_DIR}/bin/phpize
./configure --with-php-config=${INSTALL_DIR}/bin/php-config
make && make install
echo "extension=redis.so" > ${INSTALL_DIR}/etc/conf.d/redis.ini

# 安装 pcntl (已在编译时启用)
log "PCNTL extension was enabled during compilation."
echo "extension=pcntl.so" > ${INSTALL_DIR}/etc/conf.d/pcntl.ini

# 安装 amqp 扩展
log "Installing amqp extension..."
cd $PHP_software
# 安装 rabbitmq-c 依赖
dnf install -y cmake
wget https://github.com/alanxz/rabbitmq-c/archive/refs/tags/v0.13.0.tar.gz -O rabbitmq-c-0.13.0.tar.gz
tar -xzf rabbitmq-c-0.13.0.tar.gz
cd rabbitmq-c-0.13.0
mkdir build && cd build
cmake -DCMAKE_INSTALL_PREFIX=/usr/local ..
cmake --build . --target install

# 安装 amqp 扩展
cd $PHP_software
wget https://pecl.php.net/get/amqp-1.11.0.tgz
tar -xzf amqp-1.11.0.tgz
cd amqp-1.11.0
${INSTALL_DIR}/bin/phpize
./configure --with-php-config=${INSTALL_DIR}/bin/php-config
make && make install
echo "extension=amqp.so" > ${INSTALL_DIR}/etc/conf.d/amqp.ini

# 安装 swoole 扩展
log "Installing swoole extension..."
cd $PHP_software
wget https://github.com/swoole/swoole-src/archive/refs/tags/v5.0.3.tar.gz -O swoole-src-5.0.3.tar.gz
tar -xzf swoole-src-5.0.3.tar.gz
cd swoole-src-5.0.3
${INSTALL_DIR}/bin/phpize
./configure --with-php-config=${INSTALL_DIR}/bin/php-config --enable-openssl --enable-http2 --enable-sockets --enable-mysqlnd
make && make install
echo "extension=swoole.so" > ${INSTALL_DIR}/etc/conf.d/swoole.ini

# 配置 PHP 加载扩展配置目录
log "Configuring PHP to load extensions from conf.d directory..."
echo "include_path = \".:${INSTALL_DIR}/lib/php\"" >> ${INSTALL_DIR}/etc/php.ini
echo "; Load extensions from conf.d directory" >> ${INSTALL_DIR}/etc/php.ini
echo "scan_dir = \"${INSTALL_DIR}/etc/conf.d\"" >> ${INSTALL_DIR}/etc/php.ini

# 设置环境变量
log "Setting up environment variables..."
echo "export PATH=\$PATH:${INSTALL_DIR}/bin:${INSTALL_DIR}/sbin" > /etc/profile.d/php8.3.sh
source /etc/profile.d/php8.3.sh

# 创建符号链接
ln -sf ${INSTALL_DIR}/bin/php /usr/bin/php8.3
ln -sf ${INSTALL_DIR}/bin/phpize /usr/bin/phpize8.3
ln -sf ${INSTALL_DIR}/bin/php-config /usr/bin/php-config8.3

# 设置权限
chown -R ${PHP_USER}:${PHP_GROUP} ${INSTALL_DIR}
chmod -R 755 ${INSTALL_DIR}

# 启动 PHP-FPM
log "Starting PHP-FPM service..."
systemctl start php8.3-fpm.service

# 检查 PHP-FPM 是否成功启动
if systemctl is-active --quiet php8.3-fpm.service; then
    log "PHP-FPM service started successfully."
else
    log "Warning: PHP-FPM service failed to start. Check logs for details."
    log "You can manually start it with: systemctl start php8.3-fpm.service"
fi

# 检查 PHP 版本和已安装扩展
log "Verifying PHP installation..."
${INSTALL_DIR}/bin/php -v
log "Installed PHP extensions:"
${INSTALL_DIR}/bin/php -m

# 添加防火墙规则
log "Adding firewall rule for PHP-FPM port ${PHP_FPM_PORT}..."
if command -v firewall-cmd &> /dev/null; then
    firewall-cmd --permanent --add-port=${PHP_FPM_PORT}/tcp
    firewall-cmd --reload
    log "Firewall rule added successfully."
else
    log "Warning: firewall-cmd not found. Please manually configure your firewall to allow port ${PHP_FPM_PORT}."
fi

log "PHP ${PHP_VERSION} installation completed successfully!"
log "PHP-FPM is listening on port ${PHP_FPM_PORT}"
log "PHP configuration file: ${INSTALL_DIR}/etc/php.ini"
log "PHP-FPM configuration file: ${INSTALL_DIR}/etc/php-fpm.conf"
log "PHP-FPM pool configuration: ${INSTALL_DIR}/etc/php-fpm.d/www.conf"
log "PHP extensions directory: ${INSTALL_DIR}/lib/php/extensions"
log "PHP extensions configuration: ${INSTALL_DIR}/etc/conf.d/"

log "To test PHP, create a test file and access it through your web server."
log "Example test file content:"
log "<?php phpinfo(); ?>"

log "Installation log saved to: ${PHP_LOG}"