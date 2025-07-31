#!/bin/bash
# Filename:    Rocky_Linux_9_Install_Docker.sh
# Revision:    1.0
# Date:        2025/07/18
# Author:      star
# Email:       star@xgss.net
# Description: Rocky_Linux_9系统安装 Redis

# 功能：Rocky Linux 9系统中源码包安装 Docker 和docker-compose 的shell脚本



# 使用：
# gitee:
# wget https://gitee.com/funet8/Rocky-Linux-Shell/raw/main/shell/Rocky_Linux_9_Install_Docker.sh
# sh Rocky_Linux_9_Install_Docker.sh
# github:
# wget https://raw.githubusercontent.com/funet8/Rocky-Linux-Shell/refs/heads/main/shell/Rocky_Linux_9_Install_Docker.sh
# sh Rocky_Linux_9_Install_Docker.sh

# 修改Docker镜像存储位置
docker_file="/data/docker-lib"

# 修改配置国内镜像源： /etc/docker/daemon.json 改成自己的地址。

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

# 安装 Docker 依赖
dnf clean all
dnf makecache
dnf install -y yum-utils device-mapper-persistent-data lvm2
# 添加 Docker 仓库
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
# 安装 Docker
dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
# 启动 Docker 服务
systemctl start docker.service
# 设置 Docker 开机启动
systemctl enable docker.service
# 验证 Docker 安装
docker --version

function Modify_Conf(){
######修改docker默认存储位置
	mkdir /home/data
	ln -s /home/data /data
	mkdir -p $docker_file
	systemctl stop docker.service
	yum install -y rsync
	rsync -av /var/lib/docker $docker_file

######配置国内镜像源
mkdir -p /etc/docker
cat <<EOF >/etc/docker/daemon.json
{  
"registry-mirrors": [
	"https://docker.m.daocloud.io", 
    "https://noohub.ru", 
    "https://huecker.io",
    "https://dockerhub.timeweb.cloud",
	"https://f3e2e938202649e9b525ffb7272d7486.mirror.swr.myhuaweicloud.com",  
    "https://otow63ff.mirror.aliyuncs.com",
    "https://docker.1panel.live",
    "http://mirrors.ustc.edu.cn/",
    "http://mirror.azure.cn/",
    "https://hub.rat.dev/",
    "https://docker.ckyl.me/",
    "https://docker.chenby.cn",
    "https://docker.hpcloud.cloud",
    "https://docker.m.daocloud.io",
    "https://d-hub.xgss.net"  
],  
"data-root": "/data/docker-lib"  
}
EOF

	systemctl start docker.service
	#查看docker信息
	docker info
}

function Install_Docker_Compose(){
	curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
	# 改成国内的下载地址
	#curl -L "http://js.funet8.com/centos_software/docker-compose-Linux-x86_64" -o /usr/local/bin/docker-compose
	chmod +x /usr/local/bin/docker-compose
	ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
	docker-compose -v
}

systemctl daemon-reload
systemctl restart docker.service
systemctl enable docker.service

# 安装
#Install_Docker

# 修改docker配置
Modify_Conf

# 安装 docker-compose
Install_Docker_Compose