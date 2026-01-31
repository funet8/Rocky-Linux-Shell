#!/bin/bash
# Filename:    Rocky_Linux_9_system_init.sh
# Revision:    1.0
# Date:        2026/01/31
# Author:      star
# Email:       star@xgss.net
# Description: Rocky_Linux_9系统新安装后的初始设置-简易版

# 使用：
# gitee:
# wget https://gitee.com/funet8/Rocky-Linux-Shell/raw/main/shell/Rocky_Linux_9_system_init.sh
# sh Rocky_Linux_9_system_init.sh
# github:
# wget https://raw.githubusercontent.com/funet8/Rocky-Linux-Shell/refs/heads/main/shell/Rocky_Linux_9_system_init.sh
# sh Rocky_Linux_9_system_init.sh
# -------------------------------------------------------------------------------


# Rocky Linux 9 系统初始化与安全加固脚本
# 适用于生产环境服务器基础安全配置
# 注意：执行前请备份重要数据，部分配置可能影响系统功能
# 先修改 主机名： HOSTNAME 、 SSH的端口等变量
# -------------------------------------------------------------------------------
# 注意事项:
# 先ping百度域名，看能否解析域名、修改主机名和ssh端口
# -------------------------------------------------------------------------------
#rockylinux 修改主机名，命令
#hostnamectl set-hostname my-server
#rockylinux 修改ssh端口22改为60920，命令
#rockylinux 用户root用户不能密码登录，必须密钥登录，命令


# 修改自定义内容
HOSTNAME="node"
SSH_PROT="60920"
# 定义公钥内容
PUB_KEY="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDP4yncDcWDllSoZfVoC8D8bh+tmvLtTBcNHJGkqnGoZRfoMZmCM3HX6QlP43U8xfObXjX3GmsrBKfcfEXT//XZVkp1XKa0omC8UkqKHokufBmzan2EMe1PC31w4UpOK+ZiRb2j70YgSUuV1IqasA0Z38H0zOeMuPnNP1Y8ZX8tD2UfhtX+TuD1T1wHdgRhAdhSr15APR059yRqQeDjIlVB+044JCx2yO/GUx3zoZUuPJrRl3FNbLnrsMTw6IVzuV68WxnHUsfkclrUlCYHwW5f8qpY0aWQBfON0ptJJBmLAmzdhvJkEGX5VZRTXlCO8m/aSR2+EEQvgWsyOJ4PrCMT root@shanghai-node02"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # 无颜色


# 日志文件
LOG_FILE="/root/Rocky_Linux_9_system_init_$(date +%Y%m%d_%H%M%S).log"

# 检查系统是否是Rocky Linux 9
check_os(){
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

# 检查是否以root权限运行
check_root() {
    if [ "$(id -u)" != "0" ]; then
        echo -e "${RED}错误：此脚本需要root权限运行${NC}"
        exit 1
    fi
}

# 记录日志函数
log() {
    local level=$1
    local message=$2
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
    
    case $level in
        "INFO")
            echo -e "${GREEN}[INFO]${NC} $message"
            ;;
        "WARNING")
            echo -e "${YELLOW}[WARNING]${NC} $message"
            ;;
        "ERROR")
            echo -e "${RED}[ERROR]${NC} $message"
            ;;
        *)
            echo "[$level] $message"
            ;;
    esac
}

# 初始化日志文件
init_log() {
    echo "==============================================" > "$LOG_FILE"
    echo "Rocky Linux 9 系统初始化与安全加固日志" >> "$LOG_FILE"
    echo "开始时间: $(date)" >> "$LOG_FILE"
    echo "==============================================" >> "$LOG_FILE"
    echo "" >> "$LOG_FILE"
    
    log "INFO" "日志文件已初始化: $LOG_FILE"
}

# 显示欢迎信息
show_welcome() {
    clear
    echo "=============================================="
    echo "Rocky Linux 9 系统初始化与安全加固脚本"
    echo "适用于生产环境服务器基础安全配置"
    echo "=============================================="
    echo ""
    echo "警告：此脚本将对系统进行重大更改，可能影响系统功能"
    echo "请在执行前备份重要数据，并确保了解每个操作的影响"
    echo ""
    
    read -p "是否继续执行? (y/n): " choice
    if [ "$choice" != "y" ] && [ "$choice" != "Y" ]; then
        log "INFO" "用户取消执行，脚本退出"
        exit 0
    fi
}
# 修改主机名
set_hostname() {
	hostnamectl set-hostname ${HOSTNAME}
}

# 安装基础软件包
install_base_software(){
    dnf update -y
	dnf install -y vim wget curl lrzsz net-tools lsof bash-completion yum-utils tar zip unzip sudo cronie chrony policycoreutils-python-utils

    # 安装 EPEL 仓库
    dnf install -y epel-release
    dnf makecache
}

# 修改SSH端口
config_ssh(){
	# 确保防火墙服务已启用
    systemctl enable firewalld
    systemctl start firewalld
	
	SSHD_CONFIG="/etc/ssh/sshd_config"

	echo "修改 sshd_config 文件..."
	if grep -q "^#Port 22" "$SSHD_CONFIG"; then
		sed -i "s/^#Port 22/Port ${SSH_PROT}/" "$SSHD_CONFIG"
	elif grep -q "^Port " "$SSHD_CONFIG"; then
		sed -i "s/^Port .*/Port ${SSH_PROT}/" "$SSHD_CONFIG"
	else
		echo "Port ${SSH_PROT}" >> "$SSHD_CONFIG"
	fi

	echo "添加防火墙端口规则..."
	firewall-cmd --zone=public --add-port=${SSH_PROT}/tcp --permanent
	firewall-cmd --reload

	echo "重启 sshd 服务..."
	systemctl restart sshd

	log "INFO" "SSH 端口已修改为 ${SSH_PROT}"
}


# 配置SSH安全
configure_ssh_key() {
    log "INFO" "配置SSH安全..."
    
    # 备份原始配置
    cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
    log "INFO" "已备份SSH配置文件: /etc/ssh/sshd_config.bak"
    
    # 配置SSH安全选项
    sed -i 's/#PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
    sed -i 's/#PermitEmptyPasswords no/PermitEmptyPasswords no/g' /etc/ssh/sshd_config
    sed -i 's/#UseDNS yes/UseDNS no/g' /etc/ssh/sshd_config
    sed -i 's/#AllowTcpForwarding yes/AllowTcpForwarding no/g' /etc/ssh/sshd_config
    sed -i 's/#X11Forwarding yes/X11Forwarding no/g' /etc/ssh/sshd_config
    sed -i 's/#MaxAuthTries 6/MaxAuthTries 3/g' /etc/ssh/sshd_config
    sed -i 's/#LoginGraceTime 2m/LoginGraceTime 60/g' /etc/ssh/sshd_config
    
	mkdir -p /root/.ssh
    # 将公钥写入 authorized_keys 文件
    echo "$PUB_KEY" >> /root/.ssh/authorized_keys
	
    chmod 600 /root/.ssh/authorized_keys
    chmod 700 /root/.ssh
	
    # 重启 SSH 服务以应用更改
    systemctl restart sshd
	
    log "INFO" "SSH安全配置完成"
    log "INFO" "已禁用root直接登录和密码认证"
}

# 配置SELinux
configure_selinux() {
    log "INFO" "配置SELinux..."
    
    # 备份原始配置
    cp /etc/selinux/config /etc/selinux/config.bak
    log "INFO" "已备份SELinux配置文件: /etc/selinux/config.bak"
    
    # 临时关闭 SELinux
    log "临时关闭 SELinux..."
    setenforce 0

    # 永久关闭 SELinux
    log "永久关闭 SELinux..."
    sed -i 's/^SELINUX=enforcing$/SELINUX=disabled/' /etc/selinux/config
    sed -i 's/^SELINUX=permissive$/SELINUX=disabled/' /etc/selinux/config

    # 重启系统以生效更改
    log "系统将重启以使更改生效..."
}


# 防止命令失效
chmod +x /etc/rc.d/rc.local

# 主函数
main() {
	check_os
    check_root
    init_log
    show_welcome
    log "INFO" "开始Rocky Linux 9 系统初始化与安全加固"
    set_hostname
    install_base_software
    config_ssh
    configure_ssh_key
    log "INFO" "Rocky Linux 9 系统初始化与安全加固脚本执行完毕"
}

# 执行主函数
main
