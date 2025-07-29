#!/bin/bash

# Filename:    Rocky_Linux_9_Install_Nodejs.sh
# Revision:    1.0
# Date:        2024/07/22
# Author:      star
# Email:       star@xgss.net
# 功能: Rocky Linux 9系统中源码包安装Nodejs，shell脚本
# 安装目录为：/data/app/nodejs-v22.17.1
# nodejs官网：https://nodejs.org/zh-cn
# 安装版本： v22.17.1 LTS版

# 使用：
# gitee:
# wget https://gitee.com/funet8/Rocky-Linux-Shell/raw/main/shell/Rocky_Linux_9_Install_Nodejs.sh
# sh Rocky_Linux_9_Install_Nodejs.sh
# github:
# wget https://raw.githubusercontent.com/funet8/Rocky-Linux-Shell/refs/heads/main/shell/Rocky_Linux_9_Install_Nodejs.sh
# sh Rocky_Linux_9_Install_Nodejs.sh

# 设置变量
NODE_HOME='/data/app/nodejs-v22.17.1'


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

dnf clean all
dnf makecache

mkdir -p /data/software 
mkdir -p /data/app/
cd /data/software
# 官网下载
# wget https://nodejs.org/dist/v22.17.1/node-v22.17.1-linux-x64.tar.xz
# 备用下载
wget http://js.funet8.com/rocky-linux/node-v22.17.1-linux-x64.tar.xz
tar xf /data/software/node-v22.17.1-linux-x64.tar.xz -C /data/app/


#重命名
mv /data/app/node-v22.17.1-linux-x64/ ${NODE_HOME}

ln -s ${NODE_HOME}/bin/cnpm /usr/local/bin/

# 配置环境变量
## 编辑 /etc/profile
echo "export NODE_HOME=${NODE_HOME}" >> /etc/profile
echo 'export PATH=${NODE_HOME}/bin:$PATH' >> /etc/profile
## 生效
source /etc/profile

## 安装cnpm
npm install -g cnpm --registry=https://registry.npmmirror.com/
npm config set registry https://registry.npmmirror.com

# 安装 yarn
#如果你已经安装了 Node.js，那么可以直接使用 npm 安装 Yarn：
npm install -g yarn

## 查看版本
node -v
npm -v
cnpm -v
yarn -v

######
# 另外的安装方法
# 添加 Node.js 22.x LTS 仓库
# curl -fsSL https://rpm.nodesource.com/setup_22.x | sudo bash -
# 安装 Node.js 和 NPM
# dnf install -y nodejs