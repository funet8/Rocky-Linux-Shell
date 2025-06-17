#!/bin/bash
# Filename:    Rocky_Linux_9_Dnf_Install_Nginx.sh
# Revision:    1.0
# Date:        2025/06/13
# Author:      star
# Email:       star@xgss.net
# Description: Rocky_Linux_9系统新安装后的初始设置

# 使用：
# gitee:
# wget https://gitee.com/funet8/Rocky-Linux-Shell/raw/main/shell/Rocky_Linux_9_Dnf_Install_Nginx.sh
# sh Rocky_Linux_9_Dnf_Install_Nginx.sh
# github:
# wget https://raw.githubusercontent.com/funet8/Rocky-Linux-Shell/refs/heads/main/shell/Rocky_Linux_9_Dnf_Install_Nginx.sh
# sh Rocky_Linux_9_Dnf_Install_Nginx.sh
# -------------------------------------------------------------------------------


# 判断系统是否为 Rocky Linux 9

os_release=$(cat /etc/os-release | grep -i "^name=")
version_id=$(cat /etc/os-release | grep -i "^version_id=")

if [[ "$os_release" != *"Rocky Linux"* ]] || [[ "$version_id" != *"9"* ]]; then
  echo "该脚本仅适用于 Rocky Linux 9 系统。"
  exit 1
fi

echo "开始安装 Nginx..."


# 更新系统
dnf update -y

# 安装 EPEL 仓库（以防依赖）
dnf install epel-release -y


# 安装 Nginx
dnf install nginx -y

# 启动并设置开机自启
systemctl start nginx
systemctl enable nginx

# 配置防火墙允许 HTTP 和 HTTPS
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=https
firewall-cmd --reload

#配置文件目录设置######################################################################
#移动nginx配置文件
cp -p /etc/nginx/nginx.conf  /etc/nginx/nginx.conf.bak
rm -rf /etc/nginx/nginx.conf
cd /data/conf/
wget https://gitee.com/funet8/centos6_LANP_dockerfile/raw/master/centos7_nginx_apache/nginx.conf
ln -s /data/conf/nginx.conf /etc/nginx/
echo "nginx.conf move success"

#站点配置
cd /data/conf/sites-available/
wget https://gitee.com/funet8/centos6_LANP_dockerfile/raw/master/centos7_nginx_apache/nginx_main.conf

# 删除默认站点
rm -rf /usr/share/nginx/html/*
echo 'index page' > /usr/share/nginx/html/index.html
chown www.www -R /usr/share/nginx/html/

#设置目录权限##########################################################################
chown -R www:www /data/wwwroot/web
chown -R www:www /data/conf/sites-available/


# 检查是否启动成功
systemctl restart nginx
systemctl status nginx | grep Active

echo "Nginx 安装并启动完成。"
echo "请访问 http://<你的服务器IP> 验证 Nginx 是否运行。"


###切割日志
cd /data/conf/shell/
wget https://gitee.com/funet8/Rocky-Linux-Shell/raw/main/shell/cut_web_log.sh
chmod +x /data/conf/shell/cut_web_log.sh
echo "00 00 * * * root /data/conf/shell/cut_web_log.sh" >> /etc/crontab
systemctl restart crond






