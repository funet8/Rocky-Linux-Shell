#!/bin/bash

# Filename:    Rocky_Linux_9_Install_PHP7_4_PHPFPM.sh
# Revision:    1.0
# Date:        2025/06/25
# Author:      star
# Email:       star@xgss.net
# 功能: Rocky Linux 9系统中源码包安装php7.4.33 phpfpm，shell脚本
# 安装目录为：/data/app/php7.4
# 用户为： www 
# 端口为：7300
# 需要安装PHP扩展：
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
# wget https://gitee.com/funet8/Rocky-Linux-Shell/raw/main/shell/Rocky_Linux_9_Install_PHP7_4_PHPFPM.sh
# sh Rocky_Linux_9_Install_PHP7_4_PHPFPM.sh
# github:
# wget https://raw.githubusercontent.com/funet8/Rocky-Linux-Shell/refs/heads/main/shell/Rocky_Linux_9_Install_PHP7_4_PHPFPM.sh
# sh Rocky_Linux_9_Install_PHP7_4_PHPFPM.sh
# -------------------------------------------------------------------------------

# 设置变量
PHP_VERSION="7.4.33"
INSTALL_DIR="/data/app/php7.4"
PHP_software="/data/software"
PHP_FPM_PORT="7300"
PHP_USER="www"
PHP_GROUP="www"
PHP_LOG="/data/app/php7.4-install.log"

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

# 创建安装目录和用户
mkdir -p ${INSTALL_DIR}

#新建用户和用户组
groupadd $PHP_USER
useradd -g $PHP_GROUP $PHP_GROUP

# 检查是否已安装PHP 7.4.7
if [ -f "${INSTALL_DIR}/bin/php" ] && ${INSTALL_DIR}/bin/php -v | grep -q "PHP ${PHP_VERSION}"; then
    log "PHP ${PHP_VERSION} is already installed at ${INSTALL_DIR}."
    read -p "Do you want to reinstall? (y/n): " choice
    case "$choice" in 
        y|Y ) log "Proceeding with reinstallation...";;
        * ) log "Installation aborted."; exit 0;;
    esac
fi

# 更新系统包
log "Updating system packages..."
dnf update -y || {
    log "Warning: System update failed. Continuing with installation..."
}

# 安装EPEL仓库
log "Installing EPEL repository..."
dnf install -y epel-release || {
    log "Warning: Failed to install EPEL repository. Some packages may not be available."
}

# 安装依赖包
log "Installing development tools and dependencies..."
dnf groupinstall "Development Tools" -y || {
    log "Warning: Failed to install Development Tools group. Will try to install individual packages."
}
log "Installing required dependencies..."
dnf install -y \
    autoconf \
    automake \
    bzip2-devel \
    libxml2-devel \
    libcurl-devel \
    libjpeg-devel \
    libpng-devel \
    openssl-devel \
    libicu-devel \
    sqlite-devel \
    readline-devel \
    systemd-devel \
    gcc \
    make \
	cmake \
	glibc-devel kernel-headers kernel-devel \
    libtool \
    freetype-devel \
    gd-devel \
    libxslt-devel \
    re2c \
    krb5-devel \
    libwebp-devel \
	gmp-devel \
    net-tools \
    wget || {
    log "Error: Failed to install required dependencies."
    exit 1
}
# 报错： Error: Unable to find a match: libzip-devel oniguruma-devel

#安装libzip
mkdir -p $PHP_software
cd $PHP_software
# wget https://libzip.org/download/libzip-1.8.0.tar.gz
wget http://js.funet8.com/rocky-linux/php/libzip-1.8.0.tar.gz
tar -xzvf libzip-1.8.0.tar.gz
cd libzip-1.8.0
mkdir build && cd build
cmake ..
make && make install
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig/

echo '/usr/local/lib64 /usr/local/lib /usr/lib /usr/lib64' >> /etc/ld.so.conf
ldconfig -v
export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH


#安装 oniguruma
# wget https://github.com/kkos/oniguruma/archive/v6.9.4.tar.gz
cd $PHP_software
wget http://js.funet8.com/rocky-linux/php/oniguruma-6.9.4.tar.gz
tar -zxf oniguruma-6.9.4.tar.gz
cd oniguruma-6.9.4
./autogen.sh && ./configure --prefix=/usr
make && make install


# 安装 openssl-1.1.x

dnf install -y perl
#wget https://www.openssl.org/source/openssl-1.1.1m.tar.gz
cd $PHP_software
wget http://js.funet8.com/rocky-linux/php/openssl-1.1.1m.tar.gz
tar -xvzf openssl-1.1.1m.tar.gz
cd openssl-1.1.1m
./config --prefix=/usr/local/openssl --openssldir=/usr/local/openssl
make -j"$(nproc)"
make install
/usr/local/openssl/bin/openssl version

echo 'export PATH=/usr/local/openssl/bin:$PATH' | sudo tee -a /etc/profile
echo 'export LD_LIBRARY_PATH=/usr/local/openssl/lib:$LD_LIBRARY_PATH' | sudo tee -a /etc/profile
source /etc/profile
ln -sf /usr/local/openssl/bin/openssl /usr/bin/openssl
ln -sf /usr/local/openssl/lib/libssl.so.1.1 /usr/lib64/libssl.so.1.1
ln -sf /usr/local/openssl/lib/libcrypto.so.1.1 /usr/lib64/libcrypto.so.1.1


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
# wget https://www.php.net/distributions/php-7.4.33.tar.gz
wget http://js.funet8.com/rocky-linux/php/php-7.4.33.tar.gz
tar xf php-7.4.33.tar.gz
cd php-7.4.33

./configure \
    --prefix=/data/app/php7.4 \
    --with-config-file-path=/data/app/php7.4/etc \
    --with-fpm-user=www \
    --with-fpm-group=www \
	--with-openssl=/usr/local/openssl \
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
    --with-pcre-jit \
    --with-pdo-mysql \
    --with-mysqli \
    --with-webp \
    --with-jpeg \
    --with-freetype \
    --with-gettext \
    --with-xsl

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


configure_php_fpm() {
    show_progress "配置 PHP-FPM..."
    
    # 修改 PHP-FPM 配置
    sed -i "s|^listen = 127.0.0.1:9000|listen = 127.0.0.1:${PHP_FPM_PORT}|" "$INSTALL_DIR/etc/php-fpm.d/www.conf"
    sed -i "s|^;listen.allowed_clients|listen.allowed_clients|" "$INSTALL_DIR/etc/php-fpm.d/www.conf"
    sed -i "s|^;pid = run/php-fpm.pid|pid = run/php-fpm.pid|" "$INSTALL_DIR/etc/php-fpm.conf"
    
    # 修改 PHP 配置
    sed -i "s|^;date.timezone =|date.timezone = Asia/Shanghai|" "$INSTALL_DIR/etc/php.ini"
    sed -i "s|^memory_limit = 128M|memory_limit = 256M|" "$INSTALL_DIR/etc/php.ini"
    sed -i "s|^;cgi.fix_pathinfo=1|cgi.fix_pathinfo=0|" "$INSTALL_DIR/etc/php.ini"
    sed -i "s|^upload_max_filesize = 2M|upload_max_filesize = 32M|" "$INSTALL_DIR/etc/php.ini"
    sed -i "s|^post_max_size = 8M|post_max_size = 32M|" "$INSTALL_DIR/etc/php.ini"
    sed -i "s|^max_execution_time = 30|max_execution_time = 300|" "$INSTALL_DIR/etc/php.ini"
    
    # 创建 PHP 扩展配置目录
    mkdir -p "$INSTALL_DIR/etc/conf.d"
}