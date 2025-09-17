#!/bin/bash

# 功能： 
# 1.使用 myloader 恢复数据库
# 需要有 mydumper 恢复的文件夹、或者指定数据库名

if ! command -v myloader >/dev/null 2>&1; then
    echo "错误: 未找到 myloader 命令"
    exit 1
fi

function Recovery_Mysql(){
	############### 
	# 1.定义变量
	# 用户名，把变量改成你自己的
	mysqlUser='root'
	mysqlPWD='123456'
	Mysql_hosts='192.168.1.12'
	Mysql_hosts_Name="NODE12"
	Mysql_Prot='61921'
	
	# 备份的目录
	RecoveryDir=/data2T/tmp/mysqlblackup/mysql-xiaoyouxi
	
	#日志
	MySQLBackup_Log=/data2T/tmp/Recovery_Mysql_mydumper.log
	###############

	
	########################################################################
	##2.恢复数据库
	######################################################################## 
	# 指定数据库名称
	#Mysql_NAMES="DB1 DB2"
	
	# 指定文件夹名为数据库名
	Mysql_NAMES="`ls $RecoveryDir`"
	
	for databases in $Mysql_NAMES;
	do

		start_time=$(date +%s)
		
		echo "开始备份： $databases，时间戳：$start_time" >>$MySQLBackup_Log

		myloader -u $mysqlUser -h $Mysql_hosts -P $Mysql_Prot -p $mysqlPWD -B $databases -d $RecoveryDir/$databases
		
		end_time=$(date +%s)
		
		echo "结束备份： $databases，时间戳：$end_time" >>$MySQLBackup_Log
		echo "备份耗时：$((end_time - start_time)) 秒" >>$MySQLBackup_Log
	done
}

# 恢复数据库
Recovery_Mysql





