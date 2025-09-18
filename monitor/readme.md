# Rocky-Linux-Shell 系统监控

## ps_mem

https://github.com/pixelb/ps_mem

### 使用

```
wget https://raw.githubusercontent.com/pixelb/ps_mem/master/ps_mem.py
python ps_mem.py

或者

wget -qO- https://raw.githubusercontent.com/pixelb/ps_mem/master/ps_mem.py | python3

```

### 效果

```
root@developer:~# wget -qO- https://raw.githubusercontent.com/pixelb/ps_mem/master/ps_mem.py | python3
 Private  +   Shared  =  RAM used       Program

128.0 KiB +  15.5 KiB = 143.5 KiB       fusermount3
 96.0 KiB +  72.5 KiB = 168.5 KiB       lightdm-greeter
100.0 KiB +  72.5 KiB = 172.5 KiB       Xtigervnc-sessi
中间省略......
 27.7 MiB +   5.8 MiB =  33.5 MiB       Xorg
 35.9 MiB +   0.5 KiB =  35.9 MiB       snapd
 13.6 MiB +  23.7 MiB =  37.2 MiB       systemd-journald
 28.3 MiB +   9.3 MiB =  37.6 MiB       xfwm4
 46.9 MiB +   8.0 MiB =  54.9 MiB       xfdesktop
 82.8 MiB +   9.6 MiB =  92.3 MiB       Xtigervnc
---------------------------------
                        849.4 MiB
=================================
```



# Linux 跑分测试

参考网站：[https://blog.csdn.net/AlegFox/article/details/146125974](https://blog.csdn.net/AlegFox/article/details/146125974)

## 使用 nench

nench 会自动测试：

CPU 性能、磁盘 I/O 读写速度、网络下载速度（测速多个区域）

```
curl -sL wget.racing/nench.sh | bash
或者

curl -sL https://gitee.com/funet8/Rocky-Linux-Shell/raw/main/monitor/nench.sh | bash
```

### 显示结果

```
[root@node3 ~]# curl -sL wget.racing/nench.sh | bash
-------------------------------------------------
 nench.sh v2019.07.20 -- https://git.io/nench.sh
 benchmark timestamp:    2025-09-18 06:20:18 UTC
-------------------------------------------------

Processor:    11th Gen Intel(R) Core(TM) i7-11390H @ 3.40GHz
CPU cores:    2
Frequency:    3417.606 MHz
RAM:          3.5Gi
Swap:         2.0Gi
Kernel:       Linux 5.14.0-570.22.1.el9_6.x86_64 x86_64

Disks:
nvme0n1    100G  SSD
nvme0n2    100G  SSD

CPU: SHA256-hashing 500 MB
    0.471 seconds
CPU: bzip2-compressing 500 MB
    CPU: AES-encrypting 500 MB
    0.582 seconds

ioping: seek rate
    ioping: sequential read speed
    
dd: sequential write speed
    1st run:    613.21 MiB/s
    2nd run:    2193.45 MiB/s
    3rd run:    2193.45 MiB/s
    average:    1666.70 MiB/s

IPv4 speedtests
    your IPv4:    14.155.113.xxxx

    Cachefly CDN:         0.00 MiB/s
    Leaseweb (NL):        0.02 MiB/s
    Softlayer DAL (US):   0.00 MiB/s
    Online.net (FR):      6.91 MiB/s
    OVH BHS (CA):         0.21 MiB/s

No IPv6 connectivity detected
-------------------------------------------------
```



## 使用 bench.sh

服务器硬件+网速+硬盘

```

curl -sL https://gitee.com/funet8/Rocky-Linux-Shell/raw/main/monitor/bench.sh| bash

源文件来自：https://raw.githubusercontent.com/teddysun/across/refs/heads/master/bench.sh

```



## 使用 superspeed测速



国内主要运营商（电信/联通/移动）速度

多个区域的 ping 值

```
这个文件已经找不到了：curl -fsSL https://bench.im/speedtest.sh | bash  


或者
bash <(curl -sL https://raw.githubusercontent.com/i-abc/Speedtest/main/speedtest.sh)


```





