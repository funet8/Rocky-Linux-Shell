#!/bin/bash
# Filename:    Rocky_Linux_9_Install_MySQL8.sh
# Revision:    1.0
# Date:        2025/07/01
# Author:      star
# Email:       star@xgss.net
# Description: Rocky_Linux_9系统安装mysql8

# 使用：
# gitee:
# wget https://gitee.com/funet8/Rocky-Linux-Shell/raw/main/shell/Rocky_Linux_9_Install_MySQL8.sh
# sh Rocky_Linux_9_Install_MySQL8.sh
# github:
# wget https://raw.githubusercontent.com/funet8/Rocky-Linux-Shell/refs/heads/main/shell/Rocky_Linux_9_Install_MySQL8.sh
# sh Rocky_Linux_9_Install_MySQL8.sh
# -------------------------------------------------------------------------------


# 功能：Rocky Linux 9系统中源码包安装 mysql8，shell脚本
# mysql安装的目录：/data/app/mysql8/install
# mysql数据库目录:/data/app/mysql8/data
# mysql数据库配置目录:/data/app/mysql8/etc
# mysql数据库binlog目录:/data/app/mysql8/binlog
# mysql端口为： 61800
# mysql root密码为： CQ12345678


# --- 变量定义 ---
MYSQL_USER="mysql"
MYSQL_GROUP="mysql"
# 打开MySQL-Community-Server官方下载页面: https://downloads.mysql.com/archives/community/
# DOWNLOAD_URL="https://downloads.mysql.com/archives/get/p/23/file/mysql-boost-8.0.39.tar.gz"
DOWNLOAD_URL="http://js.funet8.com/rocky-linux/mysql/mysql-boost-8.0.39.tar.gz"

MYSQL_DIR="/data/software/"
Mysql_path='/data/app/mysql8'
#mysql安装的目录
Mysql_app='/data/app/mysql8/install'
#mysql数据库目录
Mysql_data='/data/app/mysql8/data'
#mysql数据库配置目录
Mysql_etc='/data/app/mysql8/etc'
#mysql数据库binlog目录
Mysql_binlog='/data/app/mysql8/binlog'

MYSQL_PORT="61800" # 自定义端口
# server_id来唯一的标识某个数据库实例，并在链式或双主复制结构中用它来避免sql语句的无限循环
Server_Id='1'
MYSQL_PassWord="CQ12345678"


# 检查是否为root用户
if [ "$(id -u)" != "0" ]; then
    error "This script must be run as root"
fi

# 检查系统是否是Rocky Linux 9
function check_os(){
	# 获取当前系统版本
	os_version=$(cat /etc/os-release)

	# 判断系统是否是 Rocky Linux 9
	if [[ "$os_version" =~ "Rocky Linux" ]] && [[ "$os_version" =~ "9" ]]; then
		echo "系统是 Rocky Linux 9，继续执行脚本..."
		# 在这里添加你脚本的其他内容
	else
		echo "当前系统不是 Rocky Linux 9，脚本退出！"
		exit 1
	fi
}
# 安装依赖包
function install_dependencies() {
    dnf install -y make cmake gcc gcc-c++ ncurses-devel  openssl-devel libtirpc wget
    mkdir $MYSQL_DIR
    cd $MYSQL_DIR
    # wget https://dl.rockylinux.org/pub/rocky/9/devel/x86_64/os/Packages/l/libtirpc-devel-1.3.3-9.el9.x86_64.rpm
    # wget https://dl.rockylinux.org/pub/rocky/9/AppStream/x86_64/os/Packages/r/rpcgen-1.4-9.el9.x86_64.rpm
    wget http://js.funet8.com/rocky-linux/mysql/libtirpc-devel-1.3.3-9.el9.x86_64.rpm
    wget http://js.funet8.com/rocky-linux/mysql/rpcgen-1.4-9.el9.x86_64.rpm
    # 安装依赖包
    rpm -ivh libtirpc-devel-1.3.3-9.el9.x86_64.rpm
    rpm -ivh rpcgen-1.4-9.el9.x86_64.rpm
    
    #然后再安装MySQL8.0.39需要的gcc工具集，安装前，需要升级软件包libsemanage为高版本，同样需要下载软件包到本地，然后rpm -Uvh更新
    #wget https://dl.rockylinux.org/pub/rocky/9/BaseOS/x86_64/os/Packages/l/libsemanage-3.6-5.el9_6.x86_64.rpm
    wget http://js.funet8.com/rocky-linux/mysql/libsemanage-3.6-5.el9_6.x86_64.rpm
    rpm -Uvh libsemanage-3.6-5.el9_6.x86_64.rpm

    yum install -y gcc-toolset-12-gcc gcc-toolset-12-gcc-c++ gcc-toolset-12-binutils gcc-toolset-12-annobin-annocheck gcc-toolset-12-annobin-plugin-gcc
}

function install_mysql(){

    mkdir -p  ${Mysql_path} ${Mysql_app} ${Mysql_data} ${Mysql_etc} ${Mysql_binlog}

    # 下载mysql并且解压安装
    cd $MYSQL_DIR
    wget ${DOWNLOAD_URL}
    tar -zxvf mysql-boost-8.0.39.tar.gz
    cd mysql-8.0.39


cmake \
-DCMAKE_INSTALL_PREFIX=${Mysql_app} \
-DINSTALL_DATADIR=${Mysql_data} \
-DMYSQL_USER=${MYSQL_USER} \
-DMYSQL_UNIX_ADDR=${Mysql_etc}/mysql.sock \
-DDEFAULT_CHARSET=utf8mb4 \
-DDEFAULT_COLLATION=utf8mb4_general_ci \
-DWITH_INNOBASE_STORAGE_ENGINE=1 \
-DWITH_EMBEDDED_SERVER=1 \
-DFORCE_INSOURCE_BUILD=1 \
-DWITH_MYISAM_STORAGE_ENGINE=1 \
-DENABLED_LOCAL_INFILE=1 \
-DEXTRA_CHARSETS=all \
-DWITH_BOOST=boost/boost_1_77_0/
# 编译（j1避免内存被杀）
make -j1 && make install
#make -j 2 && make install
if [ $? -ne 0 ]; then
        echo "MySQL installation failed."
        exit 1
    else
        echo "MySQL installed successfully."
    fi

}

function mysql_conf(){
cat > ${Mysql_etc}/my.cnf <<EOF
	[client]
	default-character-set = utf8mb4
	[mysqld]
	### 基本属性配置
	port = ${MYSQL_PORT}
	datadir=${Mysql_data}
	socket=${Mysql_etc}/mysql.sock
	# 禁用主机名解析
	skip-name-resolve
	# 默认的数据库引擎
	default-storage-engine = InnoDB
	### 字符集配置
	#character-set-client-handshake = FALSE（弃用）
	character-set-server = utf8mb4
	collation-server = utf8mb4_unicode_ci
	init_connect='SET NAMES utf8mb4'
	### GTID
	# server_id来唯一的标识某个数据库实例，并在链式或双主复制结构中用它来避免sql语句的无限循环
	server_id = ${Server_Id}

	# 开启 gtid 功能
	gtid_mode = on
	# 保障 GTID 事务安全
	# 当启用enforce_gtid_consistency功能的时候,
	# MySQL只允许能够保障事务安全, 并且能够被日志记录的SQL语句被执行,
	# 像create table ... select 和 create temporarytable语句,
	# 以及同时更新事务表和非事务表的SQL语句或事务都不允许执行
	enforce-gtid-consistency = true
	# 以下两条配置为主从切换, 数据库高可用的必须配置
	# 开启 binlog 日志功能
	log_bin = on
	binlog_format=ROW
	log-bin=${Mysql_binlog}/mysql-bin
	#10天
	binlog_expire_logs_seconds = 864000
	#expire_logs_days=10 （弃用）

	max_binlog_size=500m
	binlog_cache_size=4m
	max_binlog_cache_size=512m
	# 开启从库更新 binlog 日志
	#log-slave-updates = on
	### 慢查询日志
	# 打开慢查询日志功能
	slow_query_log = 1
	# 超过2秒的查询记录下来
	long_query_time = 2
	# 记录下没有使用索引的查询
	#log_queries_not_using_indexes = 1
	slow_query_log_file = ${Mysql_etc}/slow-${MYSQL_PORT}.log
	### 自动修复
	# 记录 relay.info 到数据表中
	relay_log_info_repository = TABLE
	# 记录 master.info 到数据表中
	master_info_repository = TABLE
	# 启用 relaylog 的自动修复功能
	relay_log_recovery = on
	# 在 SQL 线程执行完一个 relaylog 后自动删除
	relay_log_purge = 1
	### 数据安全性配置
	# 关闭 master 创建 function 的功能
	log_bin_trust_function_creators = off
	# 每执行一个事务都强制写入磁盘
	sync_binlog = 1
	# timestamp 列如果没有显式定义为 not null, 则支持null属性
	# 设置 timestamp 的列值为 null, 不会被设置为 current timestamp
	explicit_defaults_for_timestamp=true
	### 优化配置
	# 优化中文全文模糊索引
	ft_min_word_len = 1
	# 默认库名表名保存为小写, 不区分大小写
	lower_case_table_names = 1
	# 单条记录写入最大的大小限制
	# 过小可能会导致写入(导入)数据失败
	max_allowed_packet = 256M
	# 半同步复制开启
	#rpl_semi_sync_master_enabled = 1
	#rpl_semi_sync_slave_enabled = 1
	# 半同步复制超时时间设置
	#rpl_semi_sync_master_timeout = 1000
	# 复制模式(保持系统默认)
	#rpl_semi_sync_master_wait_point = AFTER_SYNC
	# 后端只要有一台收到日志并写入 relaylog 就算成功
	#rpl_semi_sync_master_wait_slave_count = 1
	# 多线程复制
	#slave_parallel_type = logical_clock
	#slave_parallel_workers = 4
	### 连接数限制
	max_connections = 3000
	# 验证密码超过20次拒绝连接
	max_connect_errors = 20
	# back_log值指出在mysql暂时停止回答新请求之前的短时间内多少个请求可以被存在堆栈中
	# 也就是说，如果MySql的连接数达到max_connections时，新来的请求将会被存在堆栈中
	# 以等待某一连接释放资源，该堆栈的数量即back_log，如果等待连接的数量超过back_log
	# 将不被授予连接资源
	back_log = 500
	open_files_limit = 65535
	# 服务器关闭交互式连接前等待活动的秒数
	interactive_timeout = 3600
	# 服务器关闭非交互连接之前等待活动的秒数
	wait_timeout = 3600
	### 内存分配
	# 指定表高速缓存的大小。每当MySQL访问一个表时，如果在表缓冲区中还有空间
	# 该表就被打开并放入其中，这样可以更快地访问表内容
	table_open_cache = 1024
	# 为每个session 分配的内存, 在事务过程中用来存储二进制日志的缓存
	binlog_cache_size = 2M
	# 在内存的临时表最大大小
	tmp_table_size = 128M
	# 创建内存表的最大大小(保持系统默认, 不允许创建过大的内存表)
	# 如果有需求当做缓存来用, 可以适当调大此值
	max_heap_table_size = 16M
	# 顺序读, 读入缓冲区大小设置
	# 全表扫描次数多的话, 可以调大此值
	read_buffer_size = 1M
	# 随机读, 读入缓冲区大小设置
	read_rnd_buffer_size = 8M
	# 高并发的情况下, 需要减小此值到64K-128K
	sort_buffer_size = 1M
	# 每个查询最大的缓存大小是1M, 最大缓存64M 数据
	#query_cache_size = 64M
	#query_cache_limit = 1M
	# 提到 join 的效率
	join_buffer_size = 16M
	# 线程连接重复利用
	thread_cache_size = 64
	### InnoDB 优化
	## 内存利用方面的设置
	# 数据缓冲区
	innodb_buffer_pool_size=2G
	## 日志方面设置
	# 事务日志大小
	#innodb_log_file_size = 256M
	# 日志缓冲区大小
	innodb_log_buffer_size = 4M
	# 事务在内存中的缓冲
	#innodb_log_buffer_size = 3M
	# 主库保持系统默认, 事务立即写入磁盘, 不会丢失任何一个事务
	innodb_flush_log_at_trx_commit = 1
	# mysql 的数据文件设置, 初始100, 以10M 自动扩展
	innodb_data_file_path = ibdata1:10M:autoextend
	# 为提高性能, MySQL可以以循环方式将日志文件写到多个文件
	#innodb_log_files_in_group = 3
	##其他设置
	# 如果库里的表特别多的情况，请增加此值
	innodb_open_files = 800
	# 为每个 InnoDB 表分配单独的表空间
	innodb_file_per_table = 1
	# InnoDB 使用后台线程处理数据页上写 I/O(输入)请求的数量
	innodb_write_io_threads = 8
	# InnoDB 使用后台线程处理数据页上读 I/O(输出)请求的数量
	innodb_read_io_threads = 8
	# 启用单独的线程来回收无用的数据
	innodb_purge_threads = 1
	# 脏数据刷入磁盘(先保持系统默认, swap 过多使用时, 调小此值, 调小后, 与磁盘交互增多, 性能降低)
	# innodb_max_dirty_pages_pct = 90
	# 事务等待获取资源等待的最长时间
	innodb_lock_wait_timeout = 120
	# 开启 InnoDB 严格检查模式, 不警告, 直接报错
	innodb_strict_mode=1
	# 允许列索引最大达到3072
	#innodb_large_prefix = on
	[mysqldump]
	# 开启快速导出
	quick
	default-character-set = utf8mb4
	max_allowed_packet = 256M
	[mysql]
	# 开启 tab 补全
	auto-rehash
	default-character-set = utf8mb4
EOF
}
# 初始化MySQL
function mysql_initialize {

    chown mysql.mysql -R ${Mysql_path}

    # 初始化数据库
    ${Mysql_app}/bin/mysqld --defaults-file=${Mysql_etc}/my.cnf  --initialize --user=mysql > ${Mysql_etc}/mysql_install.log 2>&1


    #查看初始密码
    mysql_passwd_init=`cat ${Mysql_etc}/mysql_install.log | grep  password |awk '{print $NF}'`

    # 启动mysql
    #${Mysql_app}/support-files/mysql.server start
	${Mysql_app}/bin/mysqld_safe   --defaults-file=${Mysql_etc}/my.cnf --user=mysql &

    ## 修改初始密码
	${Mysql_app}/bin/mysqladmin -u root -hlocalhost -P"${MYSQL_PORT}" -p"${mysql_passwd_init}" password "${MYSQL_PassWord}"
    # 关闭mysql
    #${Mysql_app}/support-files/mysql.server stop
	${Mysql_app}/bin/mysqladmin -uroot -p"${MYSQL_PassWord}" -S ${Mysql_etc}/mysql.sock shutdown


    #${Mysql_app}/support-files/mysql.server start
    #${Mysql_app}/support-files/mysql.server stop
    #${Mysql_app}/support-files/mysql.server restart
    # 登录mysql
    # ${Mysql_app}/bin/mysql -u root  -h localhost -P"${MYSQL_PORT}" -p"${MYSQL_PassWord}"
	# /data/app/mysql8/install/bin/mysql -u root -h localhost -P61800 -pCQ12345678

    
    chown -R mysql:mysql  -R ${Mysql_path}

}

# 开机自启动mysql服务
function mysql_auto_start {
    # 创建systemd服务文件
cat > /etc/systemd/system/mysql8.service << EOF
[Unit]
Description=MySQL 8 Server
After=network.target                
[Service]                           
Type=forking    
User=${MYSQL_USER}
Group=${MYSQL_GROUP}
ExecStart=${Mysql_app}/bin/mysqld_safe --defaults-file=${Mysql_etc}/my.cnf --user=${MYSQL_USER} &
ExecStop=${Mysql_app}/bin/mysqladmin --defaults-file=${Mysql_etc}/my.cnf shutdown
RemainAfterExit=yes
[Install]
WantedBy=multi-user.target
[Service]
TimeoutStartSec=300
EOF
    # 启动MySQL服务
    systemctl daemon-reload
    systemctl enable mysql8
    systemctl start mysql8
    echo "MySQL service started and enabled to start on boot."

}
function mysql_auto_start2(){
	echo "添加Mysql8开机自启动脚本" >> /etc/rc.local
	echo "nohup ${Mysql_app}/bin/mysqld_safe --defaults-file=${Mysql_etc}/my.cnf --user=${MYSQL_USER} > /dev/null 2>&1 &">> /etc/rc.local
	#启用rc-local
	systemctl enable rc-local
	systemctl start rc-local
    chmod +x /etc/rc.d/rc.local
}

# 添加环境变量
function add_environment_variable() {
    echo '#mysql8' >> /etc/profile
    echo "export PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin:${Mysql_app}/bin" >> /etc/profile
	source /etc/profile
	mysql -V
}
# 开启防火墙
function open_firewall() {
    firewall-cmd --zone=public --add-port=${MYSQL_PORT}/tcp --permanent
    firewall-cmd --reload
    # 查看所有端口
    firewall-cmd --zone=public --list-ports
    echo "Firewall port ${MYSQL_PORT} opened."
}

    # 输出mysql8.sh脚本
    echo '# 启动mysql8服务' >> /root/mysql8.sh
    echo 'systemctl start mysql8' >> /root/mysql8.sh

    echo '# 关闭mysql8服务' >> /root/mysql8.sh
    echo 'systemctl stop mysql8' >> /root/mysql8.sh

#检查系统
check_os
# 安装依赖包
install_dependencies
# 安装MySQL
install_mysql
# 编写MySQL配置文件
mysql_conf
# 初始化MySQL
mysql_initialize        
# 开机自启动mysql服务 -报错
# mysql_auto_start
mysql_auto_start2
# 添加环境变量
# add_environment_variable
# 开启防火墙
open_firewall

# 附加：
# 创建一个名字star账号，密码为 PASs5566a ，管理员权限的账号
#  /data/app/mysql8/install/bin/mysql -u root -h localhost -P61800 -pCQ12345678
#-- 1. 创建用户（支持本地和远程登录）
# CREATE USER 'star'@'%' IDENTIFIED BY 'PASs5566a';
#-- 2. 授予所有权限（包括所有数据库 + 所有操作）
# GRANT ALL PRIVILEGES ON *.* TO 'star'@'%' WITH GRANT OPTION;
#-- 3. 立即刷新权限
# FLUSH PRIVILEGES;