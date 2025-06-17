#!/bin/bash

#设置日志保存的时间，天
save_days=30
log_files_path="/data/wwwroot/log/"
nginx_old_log_path="/data/wwwroot/nginx_old_log/"
log_files_dir=${nginx_old_log_path}$(date -d "yesterday" +"%Y")/$(date -d "yesterday" +"%m")
log_files_name=`/bin/ls $log_files_path`


mkdir -p $log_files_dir

function cut_log {
	#移动日志
	for log_name in $log_files_name;do
		mv ${log_files_path}${log_name} ${log_files_dir}/${log_name}_$(date -d "yesterday" +"%Y%m%d").log
	done

	#删除过期日志
	find $nginx_old_log_path/* -mtime +$save_days -exec rm -rf {} \; 
}

function restart_web {
	echo 'restart web service'
	systemctl reload nginx
	systemctl reload httpd
	/etc/init.d/php7.3-fpm reload
}

function vsftp_other {
	if [ ! -d "/data/wwwroot/log/other" ];then
		mkdir -p /data/wwwroot/log/other
	fi
}
cut_log
restart_web
#vsftp_other