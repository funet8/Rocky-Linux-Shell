#!/bin/bash
# Filename:    Rocky_Linux_9_system_init_shell_mini.sh
# Revision:    1.0
# Date:        2025/06/13
# Author:      star
# Email:       star@xgss.net
# Description: Rocky_Linux_9系统新安装后的初始设置

# 使用：
# gitee:
# wget https://gitee.com/funet8/Rocky-Linux-Shell/raw/main/shell/Rocky_Linux_9_system_init_shell_mini.sh
# sh Rocky_Linux_9_system_init_shell_mini.sh
# github:
# wget https://raw.githubusercontent.com/funet8/Rocky-Linux-Shell/refs/heads/main/shell/Rocky_Linux_9_system_init_shell_mini.sh
# sh Rocky_Linux_9_system_init_shell_mini.sh
# -------------------------------------------------------------------------------


# Rocky Linux 9 系统初始化与安全加固脚本
# 适用于生产环境服务器基础安全配置
# 注意：执行前请备份重要数据，部分配置可能影响系统功能
# 先修改 主机名： HOSTNAME 、 SSH的端口等变量
# -------------------------------------------------------------------------------
# 注意事项:
# 先ping百度域名，看能否解析域名、修改主机名和ssh端口
# -------------------------------------------------------------------------------


# 主要功能:
#	1.修改主机名 ： set_hostname
#   2.安装基础软件包 ： install_base_software
#   3.更新系统 ： update_system
#   4.修改SSH端口 ： config_ssh
#   5.配置防火墙 ： configure_firewall
#   6.配置SSH安全 ： configure_ssh
#   7.配置SELinux ： configure_selinux
#   8.配置系统日志 ： configure_logging
#   9.配置账户安全 ： configure_accounts
#   10.配置系统资源限制 ： configure_resource_limits
#   11.配置网络安全 ： configure_network_security
#   12.配置Cron和at服务 ： configure_cron
#   13.自动配置 chronyd 同步时间 ： configure_time
#   14.配置系统审计 ： configure_audit
#   15.安装安全工具 ： install_security_tools
#   16.配置定时任务 ： configure_scheduled_tasks(未开启)
#   17.显示完成信息 ： show_completion
#   18.记录日志 ：log
#   19.初始化日志 ： init_log
#   20.显示欢迎信息 ：show_welcome
#   21.检查操作系统版本 ：check_os
#   22.检查是否以root权限运行 ：check_root
#   23.脚本执行日志记录到文件 ：LOG_FILE
# -------------------------------------------------------------------------------


# 修改自定义内容
HOSTNAME="node2"
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


# 修改主机名
set_hostname() {
	hostnamectl set-hostname ${HOSTNAME}
}

# 安装基础软件包
install_base_software(){
    dnf install -y vim wget curl lrzsz net-tools lsof bash-completion yum-utils tar zip unzip sudo cronie chrony policycoreutils-python-utils

    
    # 安装 EPEL 仓库
    dnf install -y epel-release
    dnf makecache

    # rc.local添加执行权限   
    chmod +x /etc/rc.d/rc.local
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

# 系统更新
update_system() {
    log "INFO" "开始系统更新..."
	
    dnf clean all
    dnf -y update
    
    if [ $? -eq 0 ]; then
        log "INFO" "系统更新完成"
    else
        log "ERROR" "系统更新失败"
    fi
}


# 修改SSH端口
config_ssh(){

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
	firewall-cmd --permanent --add-port=${SSH_PROT}/tcp
	firewall-cmd --reload

	echo "重启 sshd 服务..."
	systemctl restart sshd

	log "INFO" "SSH 端口已修改为 ${SSH_PROT}"
}

# 配置防火墙
configure_firewall() {
    log "INFO" "配置防火墙..."
    
    # 确保防火墙服务已启用
    systemctl enable firewalld
    systemctl start firewalld

    
    # 开放必要端口
    firewall-cmd --permanent --add-service=ssh
    firewall-cmd --permanent --add-service=http
    firewall-cmd --permanent --add-service=https
    
    # 重新加载防火墙规则
    firewall-cmd --reload
    
    log "INFO" "防火墙配置完成，SSH端口: $ssh_port"
    log "INFO" "已开放服务: SSH, HTTP, HTTPS"
    
    return 0
}

# 配置SSH安全
configure_ssh() {
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
    
    # 设置SELinux为强制模式
    sed -i 's/SELINUX=permissive/SELINUX=enforcing/g' /etc/selinux/config
    sed -i 's/SELINUX=disabled/SELINUX=enforcing/g' /etc/selinux/config
    
    # 检查当前SELinux状态
    current_status=$(getenforce)
    if [ "$current_status" != "Enforcing" ]; then
        log "WARNING" "SELinux当前状态为 $current_status，需要重启系统以应用更改"
        log "WARNING" "当前配置已设置为强制模式，重启后生效"
    else
        log "INFO" "SELinux已处于强制模式"
    fi
    
    return 0
}

# 配置系统日志
configure_logging() {
    log "INFO" "配置系统日志..."
    
    # 确保rsyslog服务已启用
    systemctl enable rsyslog
    systemctl start rsyslog
    
    # 配置日志轮转
    cat > /etc/logrotate.d/secure << "EOF"
/var/log/secure {
    daily
    missingok
    rotate 7
    compress
    delaycompress
    notifempty
    create 600 root root
    sharedscripts
    postrotate
        /usr/bin/systemctl restart rsyslog.service > /dev/null 2>&1 || true
    endscript
}
EOF

    # 配置日志大小限制
    cat > /etc/systemd/journald.conf << "EOF"
[Journal]
Storage=persistent
Compress=yes
SyncIntervalSec=5m
RateLimitIntervalSec=30s
RateLimitBurst=1000
SystemMaxUse=100M
SystemMaxFileSize=20M
EOF

    # 重启journald服务
    systemctl restart systemd-journald
    
    log "INFO" "系统日志配置完成"
    
    return 0
}

# 配置账户安全
configure_accounts() {
    log "INFO" "配置账户安全..."
    
    # 设置密码复杂度策略
    if [ ! -f "/etc/pam.d/system-auth.bak" ]; then
        cp /etc/pam.d/system-auth /etc/pam.d/system-auth.bak
        log "INFO" "已备份系统认证配置: /etc/pam.d/system-auth.bak"
    fi
    
    # 添加密码复杂度要求
    sed -i 's/password    requisite     pam_pwquality.so/password    requisite     pam_pwquality.so minlen=12 ucredit=-1 lcredit=-1 dcredit=-1 ocredit=-1/g' /etc/pam.d/system-auth
    
    # 设置密码过期策略
	#UMASK                    077	生成的文件权限是600（666-077）
	#UMASK                    022	生成的文件权限是644
    cat > /etc/login.defs << "EOF"
# 密码过期设置
PASS_MAX_DAYS   90
PASS_MIN_DAYS   7
PASS_WARN_AGE   14

# 账户设置
UID_MIN                  1000
UID_MAX                 60000
GID_MIN                  1000
GID_MAX                 60000
CREATE_HOME             yes
UMASK                    022
ENCRYPT_METHOD           SHA512
EOF

    # 锁定不必要的账户
    for user in adm lp sync shutdown halt news uucp operator games gopher; do
        if id "$user" &>/dev/null; then
            usermod -L "$user"
            log "INFO" "已锁定账户: $user"
        fi
    done
    
    log "INFO" "账户安全配置完成"
    log "INFO" "已设置密码复杂度要求和过期策略"
    
    return 0
}

# 配置系统资源限制
configure_resource_limits() {
    log "INFO" "配置系统资源限制..."
    
    # 设置用户资源限制
    cat > /etc/security/limits.conf << "EOF"
# 资源限制配置
*               hard    core            0
*               hard    nproc           10000
*               hard    nofile          65535
root            hard    nproc           unlimited
root            hard    nofile          65535
EOF

    # 配置PAM以应用资源限制
    if ! grep -q "pam_limits.so" /etc/pam.d/common-session; then
        echo "session    required   pam_limits.so" >> /etc/pam.d/common-session
    fi
    
    log "INFO" "系统资源限制配置完成"
    
    return 0
}

# 配置网络安全
configure_network_security() {
    log "INFO" "配置网络安全..."
    
    # 备份原始网络配置
    cp /etc/sysctl.conf /etc/sysctl.conf.bak
    log "INFO" "已备份系统参数配置: /etc/sysctl.conf.bak"
    
    # 配置系统网络参数
    cat > /etc/sysctl.d/99-security-hardening.conf << "EOF"
# 防止IP欺骗
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1

# 禁用IP源路由
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0

# 禁用ICMP重定向
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0

# 不发送ICMP重定向
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0

# 启用SYN洪水保护
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_max_syn_backlog = 2048
net.ipv4.tcp_synack_retries = 3

# 禁用IP转发
net.ipv4.ip_forward = 0
# 启用IP转发，改为此配置，并且执行生效： sysctl -p
# net.ipv4.ip_forward = 1


# 禁用IPv6
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1

# 启用内核保护
kernel.exec-shield = 1
kernel.randomize_va_space = 2

# 限制core文件大小
fs.suid_dumpable = 0

# 提高网络性能
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.core.netdev_max_backlog = 250000
net.core.somaxconn = 4096
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216
net.ipv4.tcp_max_tw_buckets = 1440000
net.ipv4.tcp_fin_timeout = 15
net.ipv4.tcp_keepalive_time = 300
net.ipv4.tcp_max_syn_backlog = 8192
net.ipv4.tcp_timestamps = 0
EOF

    # 应用系统参数
    sysctl --system
    
    log "INFO" "网络安全配置完成"
    
    return 0
}

# 配置Cron和at服务
configure_cron() {
    log "INFO" "配置计划任务服务..."
    
    # 确保Cron服务已启用
    systemctl enable crond
    systemctl start crond
    
    # 确保atd服务已禁用
    systemctl disable atd
    systemctl stop atd
    
    # 配置Cron安全
    chmod 600 /etc/crontab
    chmod 600 /etc/cron.hourly
    chmod 600 /etc/cron.daily
    chmod 600 /etc/cron.weekly
    chmod 600 /etc/cron.monthly
    chmod 600 /etc/cron.d
    
    # 限制访问Cron
    echo "root" > /etc/cron.allow
    rm -f /etc/cron.deny
    
    log "INFO" "计划任务服务配置完成"
    
    return 0
}

# 自动配置 chronyd 同步时间
configure_time(){
	dnf install -y chrony

	sed -i 's/^server/#server/g' /etc/chrony.conf
	echo "server ntp.aliyun.com iburst" >> /etc/chrony.conf
	echo "server 0.centos.pool.ntp.org iburst" >> /etc/chrony.conf
	echo "server 1.centos.pool.ntp.org iburst" >> /etc/chrony.conf
	echo "server 2.centos.pool.ntp.org iburst" >> /etc/chrony.conf
	echo "server 3.centos.pool.ntp.org iburst" >> /etc/chrony.conf

	systemctl restart chronyd
	systemctl enable chronyd

	log "INFO" "chronyd 同步时间完成"
}

# 配置系统审计
configure_audit() {
    log "INFO" "配置系统审计..."
    
    # 安装auditd
    dnf -y install audit audit-libs
    
    # 备份原始配置
    cp /etc/audit/auditd.conf /etc/audit/auditd.conf.bak
    log "INFO" "已备份审计配置: /etc/audit/auditd.conf.bak"
    
    # 配置auditd
    sed -i 's/max_log_file = 8/max_log_file = 100/g' /etc/audit/auditd.conf
    sed -i 's/max_log_file_action = ROTATE/max_log_file_action = KEEP_LOGS/g' /etc/audit/auditd.conf
    sed -i 's/num_logs = 5/num_logs = 50/g' /etc/audit/auditd.conf
    
    # 配置审计规则
    cat > /etc/audit/rules.d/audit.rules << "EOF"
# 基本审计规则
## 登录和认证
-w /var/log/faillog -p wa -k logins
-w /var/log/lastlog -p wa -k logins
-w /var/log/tallylog -p wa -k logins

## 账户和权限
-w /etc/group -p wa -k identity
-w /etc/passwd -p wa -k identity
-w /etc/gshadow -p wa -k identity
-w /etc/shadow -p wa -k identity
-w /etc/security/opasswd -p wa -k identity

## 关键文件和目录
-w /etc/sudoers -p wa -k sudo
-w /etc/ssh/sshd_config -p wa -k sshd
-w /etc/selinux/ -p wa -k selinux
-w /etc/grub2.cfg -p wa -k bootloader
-w /etc/localtime -p wa -k time-change

## 系统事件
-w /var/log/audit/ -p wa -k auditd
-w /etc/sysctl.conf -p wa -k sysctl
-w /usr/bin/newgrp -p x -k privileged
-w /usr/bin/sudo -p x -k privileged
-w /usr/bin/su -p x -k privileged

## 内核模块
-w /sbin/insmod -p x -k modules
-w /sbin/rmmod -p x -k modules
-w /sbin/modprobe -p x -k modules
-a always,exit -F arch=b64 -S init_module,finit_module -k modules

## 关键系统调用
-a always,exit -F arch=b64 -S adjtimex -S settimeofday -k time-change
-a always,exit -F arch=b32 -S adjtimex -S settimeofday -k time-change
-a always,exit -F arch=b64 -S clock_settime -k time-change
-a always,exit -F arch=b32 -S clock_settime -k time-change
-a always,exit -F arch=b64 -S clone -S fork -S vfork -k process
-a always,exit -F arch=b32 -S clone -S fork -S vfork -k process

## 网络活动
-a always,exit -F arch=b64 -S socket -S bind -S connect -k network
-a always,exit -F arch=b32 -S socket -S bind -S connect -k network

## 特权命令
-a always,exit -F path=/usr/bin/sudo -F perm=x -F auid>=1000 -F auid!=unset -k privileged
-a always,exit -F path=/usr/bin/newgrp -F perm=x -F auid>=1000 -F auid!=unset -k privileged
-a always,exit -F path=/usr/bin/passwd -F perm=x -F auid>=1000 -F auid!=unset -k privileged

## 敏感文件
-a always,exit -F path=/etc/issue -F perm=wa -F auid>=1000 -F auid!=unset -k etc-files
-a always,exit -F path=/etc/issue.net -F perm=wa -F auid>=1000 -F auid!=unset -k etc-files
-a always,exit -F path=/etc/motd -F perm=wa -F auid>=1000 -F auid!=unset -k etc-files
-a always,exit -F path=/etc/group -F perm=wa -F auid>=1000 -F auid!=unset -k etc-files
-a always,exit -F path=/etc/passwd -F perm=wa -F auid>=1000 -F auid!=unset -k etc-files
-a always,exit -F path=/etc/shadow -F perm=wa -F auid>=1000 -F auid!=unset -k etc-files
-a always,exit -F path=/etc/gshadow -F perm=wa -F auid>=1000 -F auid!=unset -k etc-files
-a always,exit -F path=/etc/sudoers -F perm=r -F auid>=1000 -F auid!=unset -k sudoers

## 审计配置
-w /etc/audit/ -p wa -k auditd
-w /etc/libaudit.conf -p wa -k auditd
-w /etc/audisp/ -p wa -k auditd

# 性能优化
-f 2
EOF

    # 启用并启动auditd服务
    systemctl enable auditd
    systemctl restart auditd
    
    log "INFO" "系统审计配置完成"
    
    return 0
}

# 安装安全工具
install_security_tools() {
    log "INFO" "安装安全工具..."
    
    # 安装基础安全工具
    # 如果报错：Error: Unable to find a match: lynis rkhunter fail2ban
    # dnf install -y epel-release

    dnf -y install aide lynis rkhunter fail2ban nmap sysstat lsof bind-utils

    # 初始化AIDE
    if [ -f "/usr/sbin/aide" ]; then
        /usr/sbin/aide --init
        if [ -f "/var/lib/aide/aide.db.new.gz" ]; then
            mv /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz
            log "INFO" "AIDE数据库已初始化"
        fi
    fi
    
    # 配置fail2ban
    if [ -f "/etc/fail2ban/jail.conf" ]; then
        cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
        sed -i 's/bantime  = 10m/bantime  = 1h/g' /etc/fail2ban/jail.local
        sed -i 's/maxretry = 5/maxretry = 3/g' /etc/fail2ban/jail.local
        
        # 确保fail2ban服务已启用
        systemctl enable fail2ban
        systemctl start fail2ban
        
        log "INFO" "fail2ban已配置"
    fi
    
    log "INFO" "安全工具安装完成"
    
    return 0
}

# 配置定时任务
configure_scheduled_tasks() {
    log "INFO" "配置定时任务..."
    
    # 创建安全检查脚本
    cat > /usr/local/bin/security_check.sh << "EOF"
#!/bin/bash

# 安全检查脚本
LOG_FILE="/var/log/security_check_$(date +%Y%m%d).log"
DATE=$(date "+%Y-%m-%d %H:%M:%S")

echo "==========================================" > $LOG_FILE
echo "安全检查报告 - $DATE" >> $LOG_FILE
echo "==========================================" >> $LOG_FILE
echo "" >> $LOG_FILE

# 检查系统更新
echo "系统更新状态:" >> $LOG_FILE
dnf check-update >> $LOG_FILE 2>&1
echo "" >> $LOG_FILE

# 检查登录失败
echo "最近登录失败记录:" >> $LOG_FILE
lastb | head -n 10 >> $LOG_FILE 2>&1
echo "" >> $LOG_FILE

# 检查root登录
echo "最近root登录记录:" >> $LOG_FILE
last root | head -n 10 >> $LOG_FILE 2>&1
echo "" >> $LOG_FILE

# 检查系统日志
echo "系统安全日志:" >> $LOG_FILE
grep -i "failed\|error\|denied\|refused\|invalid" /var/log/secure | tail -n 20 >> $LOG_FILE 2>&1
echo "" >> $LOG_FILE

# 检查监听端口
echo "当前监听端口:" >> $LOG_FILE
ss -tuln >> $LOG_FILE 2>&1
echo "" >> $LOG_FILE

# 检查可疑进程
echo "可疑进程:" >> $LOG_FILE
ps aux | grep -v grep | egrep "root|sudo|bash|sh|python|perl" | awk '$3 > 10 || $4 > 10' >> $LOG_FILE 2>&1
echo "" >> $LOG_FILE

# 检查开放文件
echo "打开的文件数量:" >> $LOG_FILE
lsof | wc -l >> $LOG_FILE 2>&1
echo "" >> $LOG_FILE

# 检查SELinux状态
echo "SELinux状态:" >> $LOG_FILE
getenforce >> $LOG_FILE 2>&1
echo "" >> $LOG_FILE

# 检查防火墙状态
echo "防火墙状态:" >> $LOG_FILE
firewall-cmd --list-all >> $LOG_FILE 2>&1
echo "" >> $LOG_FILE

# 检查磁盘使用情况
echo "磁盘使用情况:" >> $LOG_FILE
df -h >> $LOG_FILE 2>&1
echo "" >> $LOG_FILE

# 检查内存使用情况
echo "内存使用情况:" >> $LOG_FILE
free -m >> $LOG_FILE 2>&1
echo "" >> $LOG_FILE

# 检查CPU使用情况
echo "CPU使用情况:" >> $LOG_FILE
top -bn1 | head -n 5 >> $LOG_FILE 2>&1
echo "" >> $LOG_FILE

# 检查AIDE完整性
echo "文件完整性检查:" >> $LOG_FILE
if [ -f "/usr/sbin/aide" ]; then
    /usr/sbin/aide --check >> $LOG_FILE 2>&1
else
    echo "AIDE未安装" >> $LOG_FILE
fi
echo "" >> $LOG_FILE

# 检查rkhunter
echo "Rootkit检查:" >> $LOG_FILE
if [ -f "/usr/bin/rkhunter" ]; then
    /usr/bin/rkhunter --check --skip-keypress >> $LOG_FILE 2>&1
else
    echo "rkhunter未安装" >> $LOG_FILE
fi
echo "" >> $LOG_FILE

# 发送邮件通知（如果配置了邮件）
if [ -x "/usr/bin/mail" ] && [ -f "/root/.forward" ]; then
    mail -s "系统安全检查报告 - $DATE" root < $LOG_FILE
fi

echo "安全检查完成: $DATE" >> $LOG_FILE
EOF

    # 设置脚本权限
    chmod +x /usr/local/bin/security_check.sh
    
    # 添加到crontab
    if ! crontab -l | grep -q "security_check.sh"; then
        (crontab -l 2>/dev/null; echo "0 3 * * * /usr/local/bin/security_check.sh") | crontab -
        log "INFO" "已添加每日安全检查任务"
    fi
    
    # 添加每周系统更新任务
    #if ! crontab -l | grep -q "dnf update"; then
    #    (crontab -l 2>/dev/null; echo "0 2 * * 0 dnf -y update && dnf -y autoremove") | crontab -
    #    log "INFO" "已添加每周系统更新任务"
    #fi
    
    # 添加每周AIDE数据库更新任务
    if [ -f "/usr/sbin/aide" ] && ! crontab -l | grep -q "aide --update"; then
        (crontab -l 2>/dev/null; echo "0 4 * * 0 /usr/sbin/aide --update && mv /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz") | crontab -
        log "INFO" "已添加每周AIDE数据库更新任务"
    fi
    
    log "INFO" "定时任务配置完成"
    
    return 0
}

# 显示完成信息
show_completion() {
    log "INFO" "系统初始化与安全加固完成"
    log "INFO" "日志文件: $LOG_FILE"
    
    echo ""
    echo "=============================================="
    echo "系统初始化与安全加固已完成"
    echo "=============================================="
    echo ""
    echo "重要注意事项:"
    echo "1. 请检查日志文件: $LOG_FILE"
    echo "2. 部分安全配置可能需要重启系统才能完全生效"
    echo "3. 请确保SSH密钥已正确配置，否则可能无法登录系统"
    echo "4. 建议在生产环境使用前进行全面测试"
    echo ""
    echo "推荐后续操作:"
    echo "1. 配置邮件服务以接收安全警报"
    echo "2. 设置定期备份重要数据"
    echo "3. 考虑配置入侵检测系统(IDS)或入侵防御系统(IPS)"
    echo "4. 定期审查系统日志和安全检查报告"
    echo ""
    
    read -p "是否需要重启系统? (y/n): " choice
    if [ "$choice" == "y" ] || [ "$choice" == "Y" ]; then
        log "INFO" "系统将在3秒后重启！"
        sleep 3
        reboot
    fi
}

# 主函数
main() {
	check_os
    check_root
	set_hostname
    install_base_software
    init_log
    show_welcome
    
    log "INFO" "开始Rocky Linux 9 系统初始化与安全加固"
    
    # 按顺序执行各个安全加固步骤
    update_system
	config_ssh
    configure_firewall
    configure_ssh
    configure_selinux
    configure_logging
    configure_accounts
    configure_resource_limits
    configure_network_security
    configure_cron
	configure_time
    configure_audit
    install_security_tools
    # configure_scheduled_tasks
    
    show_completion
    
    log "INFO" "Rocky Linux 9 系统初始化与安全加固脚本执行完毕"
}

# 执行主函数
main
