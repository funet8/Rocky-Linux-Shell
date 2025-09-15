#!/bin/sh 

# 功能： 
# 1.使用 mysqldump 备份每个数据库
# 2.可以排除某些数据库不备份
# 3.使用 tar工具将mysql备份文件XXX.sql 打包为 XXX.sql.tar.gz 以节省硬盘空间。
# 4.删除过期文件

function Backup_MySQL(){
	############### 
	# 1.定义变量
	# 用户名，把变量改成你自己的
	mysqlUser='root'
	mysqlPWD='123456'
	#数据库地址、端口
	Mysql_hosts='192.168.1.12'
	Mysql_hosts_Name="NODE12"
	Mysql_Prot='3306'
	
	#备份的数据库名 grep -v忽略不需要备份的数据库
	#Mysql_NAMES='DB01 DB02 DB03' # 指定备份DB01、DB02、DB03数据库。
	
	#动态获取数据库名，除了information_schema、performance_schema、test等数据库
	Mysql_NAMES=`mysql -h$Mysql_hosts -u$mysqlUser -p$mysqlPWD -P$Mysql_Prot -e "show databases\G" |grep 'Database'|awk -F'Database: ' '{print $2}' |grep -v 'information_schema\|performance_schema\|test\|sys\|mysql\|__recycle_bin__'`

	Today=`date -I` 
	#临时目录
	tmpBackupDir=/data/tmp/mysqlblackup/mysql-$Mysql_hosts_Name
	
	#备份之后的目录
	backupDir=/data/backup/mysql/mysql-$Mysql_hosts_Name/$Today
	
	#日志
	MySQLBackup_Log=$backupDir/MySQLBackup_Log_$Mysql_hosts_Name.log
	###############

	##2.创建目录
	if [[ -e $tmpBackupDir ]]; then 
		rm -rf $tmpBackupDir/* 
	else 
		mkdir -p $tmpBackupDir 
	fi 
	# 如果备份目录不存在则创建它 
	if [[ ! -e $backupDir ]];then 
		mkdir -p $backupDir
	fi 
	
	
	########################################################################
	##3.备份数据库
	######################################################################## 
	for databases in $Mysql_NAMES;
	do
		dateTime=`date "+%Y.%m.%d %H:%M:%S"` 
		echo "$dateTime START backup $databases!" >> $MySQLBackup_Log
		/usr/bin/mysqldump -h$Mysql_hosts -P$Mysql_Prot -u$mysqlUser --skip-lock-tables -p"$mysqlPWD" $databases > $tmpBackupDir/$databases.sql
		dateTime=`date "+%Y.%m.%d %H:%M:%S"` 
		echo "$dateTime Database:$databases backup success!" >>$MySQLBackup_Log
	done

	########################################################################
	##4.压缩备份文件
	######################################################################## 
	for databases in $Mysql_NAMES;
	do
		date=`date -I` 
		cd $tmpBackupDir 
		tar czf $backupDir/$databases-$date.tar.gz ./$databases.sql
	done
}

function Delete_MySQL(){
	TARGET_DIR="/data/backup/mysql/mysql-*/*"
	Days="7"

	# 删除 7 天前的文件
	find "$TARGET_DIR" -type f -mtime +$Days -print -delete >> /dev/null 2>&1

	# 说明：
	# -type f      只匹配文件
	# -mtime +7    修改时间在 7 天前
	# -print       删除前输出文件路径（方便记录日志）
	# -delete      直接删除文件
}




# 备份数据库
Backup_MySQL

# 删除过期备份文件
Delete_MySQL









