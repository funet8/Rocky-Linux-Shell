# Rocky Linux 服务器的脚本

## 功能

基于 Rocky Linux 9系统的一些实用Shell脚本



## 为什么选择Rocky Linux 

CentOS 7 过保后换什么操作系统的问题？

众所周知，CentOS 7 在 2024年6月已经结束生命周期，后期一些漏洞不会被官方修复，所以要抓紧时间来更新系统！

EL 的兼容发行版中，Rocky Linux 的兼容性最好，建议使用 9.X，目前[10.1也已经在2025年6月发布了](https://mp.weixin.qq.com/s/93KEfxV8THxrHlARHLJq_g)

Debian 系发行版稳定性也非常不错，当下最合适的选择是 Debian 12 。

Ubuntu 作为桌面端还是不错的，但作为服务端操作系统还是拉垮了，如果不是有特殊需求（比如 NVIDIA 驱动），如果用 Ubuntu 22 或者是24。

Rocky Linux还是作为服务器系统来替代CentOS 7。

Rocky Linux 的创始人 Greg Kurtzer 就是 CentOS 的创始人之一，因此，Rocky Linux 保留了很多 CentOS 的设计理念和目标，继续为用户提供一个稳定的、长期支持的企业级操作系统。 这也是使用Rocky Linux 来替代CentOS 7的一个重要的原因。

# 【文档目录】

## [Rocky-Linux-9软件安装流程](https://vuepress-v2.xgss.net/Rocky-Linux/0.Rocky-Linux-9软件安装流程.html)

# 【目录】

## [Rocky Linux 9 系统安装配置图解教程并做简单配置](https://vuepress-v2.xgss.net/article/thpvukry/)

## [Rocky-Linux-9常用命令备忘录](https://vuepress-v2.xgss.net/article/jddfyujx/)

## [Rocky Linux 9 系统初始化与安全加固脚本](https://vuepress-v2.xgss.net/article/k5sevquu/)

```
Rocky_Linux_9系统新安装后的初始设置
# 使用：
# gitee:
# wget https://gitee.com/funet8/Rocky-Linux-Shell/raw/main/shell/Rocky_Linux_9_system_init_shell_mini.sh
# sh Rocky_Linux_9_system_init_shell_mini.sh
# github:
# wget https://raw.githubusercontent.com/funet8/Rocky-Linux-Shell/refs/heads/main/shell/Rocky_Linux_9_system_init_shell_mini.sh
# sh Rocky_Linux_9_system_init_shell_mini.sh

简单版：
# Description: Rocky_Linux_9系统新安装后的初始设置-简易版
# 使用：
# gitee:
# wget https://gitee.com/funet8/Rocky-Linux-Shell/raw/main/shell/Rocky_Linux_9_system_init.sh
# sh Rocky_Linux_9_system_init.sh
# github:
# wget https://raw.githubusercontent.com/funet8/Rocky-Linux-Shell/refs/heads/main/shell/Rocky_Linux_9_system_init.sh
sh Rocky_Linux_9_system_init.sh
```



## [Rocky-Linux-9挂载硬盘的方法](https://vuepress-v2.xgss.net/Rocky-Linux/4.Rocky-Linux-9挂载硬盘的方法.html)



## [Rocky-Linux-9-安装Nginx](https://vuepress-v2.xgss.net/Rocky-Linux/5.Rocky-Linux-9-安装Nginx.html)

```
# 使用：
# gitee:
# wget https://gitee.com/funet8/Rocky-Linux-Shell/raw/main/shell/Rocky_Linux_9_Dnf_Install_Nginx.sh
# sh Rocky_Linux_9_Dnf_Install_Nginx.sh
# github:
# wget https://raw.githubusercontent.com/funet8/Rocky-Linux-Shell/refs/heads/main/shell/Rocky_Linux_9_Dnf_Install_Nginx.sh
# sh Rocky_Linux_9_Dnf_Install_Nginx.sh

```



## [Rocky-Linux-9-源码包安装Mysql5.7](https://vuepress-v2.xgss.net/Rocky-Linux/6.Rocky-Linux-9-源码包安装Mysql5.7.html)

```
# 使用：
# gitee:
# wget https://gitee.com/funet8/Rocky-Linux-Shell/raw/main/shell/Rocky_Linux_9_Install_MySQL5_7.sh
# sh Rocky_Linux_9_Install_MySQL5_7.sh
# github:
# wget https://raw.githubusercontent.com/funet8/Rocky-Linux-Shell/refs/heads/main/shell/Rocky_Linux_9_Install_MySQL5_7.sh
# sh Rocky_Linux_9_Install_MySQL5_7.sh
```



## [Rocky-Linux-9-源码包安装Mysql8](https://vuepress-v2.xgss.net/Rocky-Linux/7.Rocky-Linux-9-源码包安装Mysql8.html)

```
# 使用：
# gitee:
# wget https://gitee.com/funet8/Rocky-Linux-Shell/raw/main/shell/Rocky_Linux_9_Install_MySQL8.sh
# sh Rocky_Linux_9_Install_MySQL8.sh
# github:
# wget https://raw.githubusercontent.com/funet8/Rocky-Linux-Shell/refs/heads/main/shell/Rocky_Linux_9_Install_MySQL8.sh
# sh Rocky_Linux_9_Install_MySQL8.sh
```



## [Rocky-Linux-9-源码包安装php8](https://vuepress-v2.xgss.net/Rocky-Linux/8.Rocky-Linux-9-源码包安装php8.html)

```
# 使用：
# gitee:
# wget https://gitee.com/funet8/Rocky-Linux-Shell/raw/main/shell/Rocky_Linux_9_Install_PHP8_3_PHPFPM.sh
# sh Rocky_Linux_9_Install_PHP8_3_PHPFPM.sh
# github:
# wget https://raw.githubusercontent.com/funet8/Rocky-Linux-Shell/refs/heads/main/shell/Rocky_Linux_9_Install_PHP8_3_PHPFPM.sh
# sh Rocky_Linux_9_Install_PHP8_3_PHPFPM.sh
```



## [Rocky-Linux-9-源码包安装php7](https://vuepress-v2.xgss.net/Rocky-Linux/9.Rocky-Linux-9-源码包安装php7.html)

```
# 使用：
# gitee:
# wget https://gitee.com/funet8/Rocky-Linux-Shell/raw/main/shell/Rocky_Linux_9_Install_PHP7_3_PHPFPM.sh
# sh Rocky_Linux_9_Install_PHP7_3_PHPFPM.sh
# github:
# wget https://raw.githubusercontent.com/funet8/Rocky-Linux-Shell/refs/heads/main/shell/Rocky_Linux_9_Install_PHP7_3_PHPFPM.sh
# sh Rocky_Linux_9_Install_PHP7_3_PHPFPM.sh
```

## Rocky-Linux-9-安装Docker

```
# 使用：
# gitee:
# wget https://gitee.com/funet8/Rocky-Linux-Shell/raw/main/shell/Rocky_Linux_9_Install_Docker.sh
# sh Rocky_Linux_9_Install_Docker.sh
# github:
# wget https://raw.githubusercontent.com/funet8/Rocky-Linux-Shell/refs/heads/main/shell/Rocky_Linux_9_Install_Docker.sh
# sh Rocky_Linux_9_Install_Docker.sh
```





## [Rocky-Linux-9-安装VSFTP](https://vuepress-v2.xgss.net/Rocky-Linux/10.Rocky-Linux-9-安装FTP.html)

```
# 使用：
# gitee:
# wget https://gitee.com/funet8/Rocky-Linux-Shell/raw/main/shell/Rocky_Linux_9_Install_Vsftpd.sh
# sh Rocky_Linux_9_Install_Vsftpd.sh
# github:
# wget https://raw.githubusercontent.com/funet8/Rocky-Linux-Shell/refs/heads/main/shell/Rocky_Linux_9_Install_Vsftpd.sh
# sh Rocky_Linux_9_Install_Vsftpd.sh
```



## [Rocky-Linux-9-安装Redis](https://vuepress-v2.xgss.net/Rocky-Linux/11.Rocky-Linux-9-安装Redis.html)

```
# 使用：
# gitee:
# wget https://gitee.com/funet8/Rocky-Linux-Shell/raw/main/shell/Rocky_Linux_9_Install_Redis.sh
# sh Rocky_Linux_9_Install_Redis.sh
# github:
# wget https://raw.githubusercontent.com/funet8/Rocky-Linux-Shell/refs/heads/main/shell/Rocky_Linux_9_Install_Redis.sh
# sh Rocky_Linux_9_Install_Redis.sh
```



## [Rocky-Linux-9-安装Nodejs](https://vuepress-v2.xgss.net/Rocky-Linux/12.Rocky-Linux-9-安装Nodejs.html)

```
# 使用：
# gitee:
# wget https://gitee.com/funet8/Rocky-Linux-Shell/raw/main/shell/Rocky_Linux_9_Install_Nodejs.sh
# sh Rocky_Linux_9_Install_Nodejs.sh
# github:
# wget https://raw.githubusercontent.com/funet8/Rocky-Linux-Shell/refs/heads/main/shell/Rocky_Linux_9_Install_Nodejs.sh
# sh Rocky_Linux_9_Install_Nodejs.sh
```



# [Linux 性能跑分](monitor/readme.md)



# 把文件同时push到多个仓库

Github地址： https://github.com/funet8/Rocky-Linux-Shell.git

Gitee地址： https://gitee.com/funet8/Rocky-Linux-Shell



注意

- 两个仓库都需要配置 SSH 公钥授权。
- 推荐使用 SSH 地址，避免每次输入密码。
- 如果你担心同步出错，建议先 push 到主仓库，再 push 到镜像仓库。

```
首先克隆 
git clone git@github.com:funet8/Rocky-Linux-Shell.git

# 添加远程仓库（如果尚未添加，添加一次即可）
git remote add gitee git@gitee.com:funet8/Rocky-Linux-Shell.git
git remote add github git@github.com:funet8/Rocky-Linux-Shell.git
# 查看当前远程仓库
git remote -v

```



更新到多个仓库

```
# 添加并提交更改
git add .
git commit -m "自动更新文件"

# 推送至所有远程仓库
git push github main  	# 推送到 GitHub
git push gitee main   # 推送到 Gitee

echo "文件已成功更新到所有仓库"
```

可以查看update-repos.sh文件





