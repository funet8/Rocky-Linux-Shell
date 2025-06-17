#!/bin/bash

# Filename:    create_dirs.sh
# Revision:    1.0
# Date:        2025/06/17
# Author:      star
# Email:       star@xgss.net
# Description: 创建常用的目录

# Rocky Linux 9 系统初始化与安全加固脚本

# -------------------------------------------------------------------------------
# 使用：
# wget https://gitee.com/funet8/Rocky-Linux-Shell/raw/main/shell/create_dirs.sh
# sh create_dirs.sh

# github:
# wget https://raw.githubusercontent.com/funet8/Rocky-Linux-Shell/refs/heads/main/shell/create_dirs
# sh create_dirs.sh
# -------------------------------------------------------------------------------

# 功能介绍：
# 新建常用目录
# /data/wwwroot/web  作用：存放WEB应用程序
# /data/wwwroot/log  作用：存放WEB日志

# /data/conf 作用：存放应用程序配置文件
# /data/conf/sites-available 作用：存放nginx站点配置文件
# /data/conf/shell 作用：存放shell脚本
# /data/backup 作用：存放备份文件
# /data/software 作用：存放安装软件目录
# /data/wwwroot/nginx_old_log/ 作用：存放Nginx切割日志
# /data/app   作用：软件安装的目录
# -------------------------------------------------------------------------------

#目录设置############################################################################
#创建网站相关目录####################################################################

	mkdir /home/data
	ln -s /home/data /data
	
	mkdir /data/wwwroot
	mkdir -p /data/wwwroot/web
	mkdir -p /data/wwwroot/log

	mkdir /data/conf
	mkdir /data/conf/sites-available
	mkdir /data/conf/shell
	mkdir /data/backup
	mkdir /data/software
	mkdir /data/wwwroot/nginx_old_log/
	mkdir /data/app
	
	
#执行退出，后面的操作在相应的脚本中执行################################################
echo 'Create Dir success!!! '