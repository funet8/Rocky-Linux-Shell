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

## [Rocky Linux 9 系统安装配置图解教程并做简单配置](https://vuepress-v2.xgss.net/Rocky-Linux/1.Rocky-Linux-9-%E7%B3%BB%E7%BB%9F%E5%AE%89%E8%A3%85%E9%85%8D%E7%BD%AE%E5%9B%BE%E8%A7%A3%E6%95%99%E7%A8%8B%E5%B9%B6%E5%81%9A%E7%AE%80%E5%8D%95%E9%85%8D%E7%BD%AE.html)

## [Rocky-Linux-9常用命令备忘录](https://vuepress-v2.xgss.net/Rocky-Linux/2.Rocky-Linux-9%E5%B8%B8%E7%94%A8%E5%91%BD%E4%BB%A4%E5%A4%87%E5%BF%98%E5%BD%95.html)







# 把文件同时push到多个仓库

https://gitee.com/funet8/rocky-linux-shell.git

https://github.com/funet8/Rocky-Linux-Shell.git

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





