# Rocky-Linux-Shell 系统跑分

# 别只会测手机！Linux 性能跑分全攻略

很多人一提“跑分”，脑子里立刻想到的就是手机测安兔兔、电脑跑个 3DMark——要么是 Windows，要么是安卓。 可你知道吗？在 Linux 里也能跑分，而且不只是测个“分数”那么简单。它能帮你摸清服务器的 CPU、内存、磁盘、网络到底有多能打，甚至能精准定位性能瓶颈。 这篇文章，我们就用最接地气的方式，带你认识几款常用的 Linux 跑分工具，让你不再只会看手机分数，也能玩转服务器性能测试。

![img](https://imgoss.xgss.net/picgo-tx2025/QQ_1758186729438.png?tx)

## 一、使用 nench

nench 会自动测试：

CPU 性能、磁盘 I/O 读写速度、网络下载速度（测速多个区域）

```
curl -sL wget.racing/nench.sh | bash
或者

curl -sL https://gitee.com/funet8/Rocky-Linux-Shell/raw/main/monitor/nench.sh | bash
```

### nench显示结果

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



## 二、使用 bench.sh

服务器硬件+网速+硬盘

```

curl -sL https://gitee.com/funet8/Rocky-Linux-Shell/raw/main/monitor/bench.sh| bash

源文件来自：https://raw.githubusercontent.com/teddysun/across/refs/heads/master/bench.sh

```

### bench测试结果

```
curl -sL https://raw.githubusercontent.com/teddysun/across/refs/heads/master/bench.sh | bash
-------------------- A Bench.sh Script By Teddysun -------------------
 Version            : v2025-05-08
 Usage              : wget -qO- bench.sh | bash
----------------------------------------------------------------------
 CPU Model          : 11th Gen Intel(R) Core(TM) i7-11390H @ 3.40GHz
 CPU Cores          : 2 @ 3417.606 MHz
 CPU Cache          : 12288 KB
 AES-NI             : ✓ Enabled
 VM-x/AMD-V         : ✗ Disabled
 Total Disk         : 197.7 GB (5.7 GB Used)
 Total Mem          : 3.5 GB (606.1 MB Used)
 Total Swap         : 2.0 GB (0 Used)
 System uptime      : 1 days, 7 hour 8 min
 Load average       : 0.00, 0.03, 0.08
 OS                 : Rocky Linux release 9.6 (Blue Onyx)
 Arch               : x86_64 (64 Bit)
 Kernel             : 5.14.0-570.22.1.el9_6.x86_64
 TCP CC             : cubic
 Virtualization     : VMware
 IPv4/IPv6          : ✓ Online / ✗ Offline
 Organization       : AS4134 CHINANET-BACKBONE
 Location           : Shenzhen / CN
 Region             : Guangdong
----------------------------------------------------------------------
 I/O Speed(1st run) : 1.0 GB/s
 I/O Speed(2nd run) : 1.6 GB/s
 I/O Speed(3rd run) : 1.6 GB/s
 I/O Speed(average) : 1433.6 MB/s
----------------------------------------------------------------------
 Node Name        Upload Speed      Download Speed      Latency     
 Paris, FR        105.06 Mbps       577.33 Mbps         223.35 ms   
 Amsterdam, NL    65.13 Mbps        6.85 Mbps           256.49 ms   
 Shanghai, CN     97.54 Mbps        482.40 Mbps         32.10 ms    
 Hong Kong, CN    4.50 Mbps         5.25 Mbps           11.61 ms    
 Tokyo, JP        79.18 Mbps        689.46 Mbps         115.56 ms   
----------------------------------------------------------------------
 Finished in        : 4 min 30 sec
 Timestamp          : 2025-09-18 16:22:21 CST
----------------------------------------------------------------------
```



## 三、使用 superspeed测速（结果报错）

开源地址： https://github.com/i-abc/Speedtest

国内主要运营商（电信/联通/移动）速度

多个区域的 ping 值

```
这个文件已经找不到了：curl -fsSL https://bench.im/speedtest.sh | bash  

curl -sL https://gitee.com/funet8/Rocky-Linux-Shell/raw/main/monitor/speedtest.sh| bash

源文件：
bash <(curl -sL https://raw.githubusercontent.com/i-abc/Speedtest/main/speedtest.sh)

```

### 测试结果

```
sha256sum: ./sp-github-i-abc/speedtest-cli.tgz: No such file or directory
sha256sum: ./sp-github-i-abc/bim-core: No such file or directory
sha256sum: ./sp-github-i-abc/speedtest-go.tar.gz: No such file or directory
sha256sum: ./sp-github-i-abc/librespeed-cli.tar.gz: No such file or directory
经检测，speedtest-cli的SHA-256与官方不符，方便的话欢迎到GitHub反馈
```

报错原因： https://github.com/i-abc/Speedtest/issues/19

## 四、网络质量测速Speedtest

```
# 安装 speedtest-cli（Ubuntu/Debian）
sudo apt install -y speedtest-cli

# 安装 speedtest-cli（CentOS/RHEL）
sudo yum install -y speedtest-cli

# 运行测试
speedtest-cli

```

### 测试结果

```
speedtest-cli
Retrieving speedtest.net configuration...
Testing from China Telecom (X.X.X.X)...
Retrieving speedtest.net server list...
Selecting best server based on ping...
Hosted by Chunghwa Mobile (Changhua) [679.03 km]: 176.978 ms
Testing download speed................................................................................
Download: 0.07 Mbit/s
Testing upload speed......................................................................................................
Upload: 0.41 Mbit/s
```



## 五. 使用 Geekbench

专业 CPU 跑分，一行命令

```
wget -qO- http://cdn.geekbench.com/Geekbench-6.2.2-Linux.tar.gz | tar xz --strip-components=1 && ./geekbench6
```

测试结果

```
wget -qO- http://cdn.geekbench.com/Geekbench-6.2.2-Linux.tar.gz | tar xz --strip-components=1 && ./geekbench6

Geekbench 6.2.2 : https://www.geekbench.com/

Geekbench 6 requires an active internet connection and automatically uploads 
benchmark results to the Geekbench Browser.

Upgrade to Geekbench 6 Pro to enable offline use and unlock other features:

  https://store.primatelabs.com/v6

Enter your Geekbench 6 Pro license using the following command line:

  ./geekbench6 --unlock <email> <key>

System Information
  Operating System              Rocky Linux 9.6 (Blue Onyx)
  Kernel                        Linux 5.14.0-570.22.1.el9_6.x86_64 x86_64
  Model                         VMware, Inc. VMware Virtual Platform
  Motherboard                   Intel Corporation 440BX Desktop Reference Platform
  BIOS                          Phoenix Technologies LTD 6.00

CPU Information
  Name                          Intel Core i7-11390H
  Topology                      2 Processors, 2 Cores
  Identifier                    GenuineIntel Family 6 Model 140 Stepping 2
  Base Frequency                3.42 GHz
  L1 Instruction Cache          32.0 KB
  L1 Data Cache                 48.0 KB
  L2 Cache                      1.25 MB
  L3 Cache                      12.0 MB

Memory Information
  Size                          3.54 GB

Single-Core
  Running File Compression
  Running Navigation
  Running HTML5 Browser
  Running PDF Renderer
  Running Photo Library
  Running Clang
  Running Text Processing
  Running Asset Compression
  Running Object Detection
  Running Background Blur
  Running Horizon Detection
  Running Object Remover
  Running HDR
  Running Photo Filter
  Running Ray Tracer
  Running Structure from Motion

Multi-Core
  Running File Compression
  Running Navigation
  Running HTML5 Browser
  Running PDF Renderer
  Running Photo Library
  Running Clang
  Running Text Processing
  Running Asset Compression
  Running Object Detection
  Running Background Blur
  Running Horizon Detection
  Running Object Remover
  Running HDR
  Running Photo Filter
  Running Ray Tracer
  Running Structure from Motion


Uploading results to the Geekbench Browser. This could take a minute or two 
depending on the speed of your internet connection.

Upload succeeded. Visit the following link and view your results online:

  https://browser.geekbench.com/v6/cpu/13890045

Visit the following link and add this result to your profile:

访问结果
  https://browser.geekbench.com/v6/cpu/13890045/claim?key=354758
  
```

## 六、查看内存占用工具ps_mem

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



## 七、综合跑分UnixBench

输出包含多项子测试及综合评分，数值越高性能越好。

```
# 安装依赖
sudo apt install -y build-essential perl
# 获取源码
git clone https://github.com/kdlucas/byte-unixbench.git
cd byte-unixbench/UnixBench
# 编译并运行
make
./Run
```



## 八、CPU 跑分：sysbench

关注 events per second（越高越好）和 total time（越短越好）。

```
# 安装
sudo apt install -y sysbench
# 测试 CPU（计算 20000 以内素数）
sysbench cpu --cpu-max-prime=20000 run
```



## 九、磁盘 I/O：fio

关注 IOPS（每秒读写次数）和 BW（带宽）。

```
# 安装
sudo apt install -y fio
# 随机写测试
fio --name=randwrite --ioengine=libaio --rw=randwrite \
    --bs=4k --size=1G --numjobs=4 --runtime=60 --group_reporting
```



## 十、 网络带宽：iperf3

结果显示实际带宽（Mbps/Gbps）。

```
# 安装
sudo apt install -y iperf3
# 服务器端
iperf3 -s
# 客户端（替换 <server_ip>）
iperf3 -c <server_ip>
```

## 常用跑分工具分类

| 工具/脚本            | 测试范围                 | 特点                         | 适用场景                 |
| -------------------- | ------------------------ | ---------------------------- | ------------------------ |
| **UnixBench**        | CPU、内存、I/O、进程管理 | 经典综合基准，结果可横向对比 | 全面评估服务器整体性能   |
| **Geekbench**        | CPU（单核/多核）、内存   | 跨平台，结果可上传对比       | CPU 性能对比、硬件评测   |
| **sysbench**         | CPU、内存、磁盘 I/O      | 可定制参数，适合压力测试     | 定向测试单一硬件性能     |
| **fio**              | 磁盘 I/O                 | 支持多种 I/O 模式，结果详细  | 存储性能评估、数据库调优 |
| **iperf3**           | 网络带宽                 | TCP/UDP 测试，支持双向       | 内网/公网带宽测试        |
| **nench / bench.sh** | CPU、磁盘、网络          | 一键脚本，快速出结果         | VPS/云主机快速评估       |
| **glmark2**          | GPU                      | 图形性能测试                 | GPU 服务器评估           |



参考网站：[https://blog.csdn.net/AlegFox/article/details/146125974](https://blog.csdn.net/AlegFox/article/details/146125974) 参考网站中有些地址失效，我下载到仓库中备用。

Linux 跑分测试工具种类丰富，从一键脚本到专业基准套件应有尽有。 建议先用 bench.sh / nench 快速摸底，再用 UnixBench / sysbench / fio / iperf3 做针对性深测，最后结合业务负载进行优化。



