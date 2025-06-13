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







## 仓库地址

把文件同时push到多个仓库

```

https://gitee.com/funet8/rocky-linux-shell.git
https://github.com/funet8/Rocky-Linux-Shell.git

把文件同时push到多个仓库。
git@gitee.com:funet8/rocky-linux-shell.git
git@github.com:funet8/Rocky-Linux-Shell.git

```



```
Administrator@chuanqu-star MINGW64 /e/360data/重要数据/桌面
$ mkdir rocky-linux-shell

Administrator@chuanqu-star MINGW64 /e/360data/重要数据/桌面
$ cd rocky-linux-shell/

Administrator@chuanqu-star MINGW64 /e/360data/重要数据/桌面/rocky-linux-shell
$ git remote add multi git@gitee.com:funet8/rocky-linux-shell.git
$ git remote set-url --add multi git@github.com:funet8/Rocky-Linux-Shell.git



```





