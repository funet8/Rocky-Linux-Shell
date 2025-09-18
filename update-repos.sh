#!/bin/bash

# 添加远程仓库（如果尚未添加）
# git remote add gitee git@gitee.com:funet8/Rocky-Linux-Shell.git
# git remote add github git@github.com:funet8/Rocky-Linux-Shell.git

# 查看当前远程仓库
git remote -v

# 添加并提交更改
git add .
git commit -m "修改readme"

# 推送至所有远程仓库
git push github main  	# 推送到 GitHub
git push gitee main   # 推送到 Gitee

echo "文件已成功更新到所有仓库"

#两个仓库都需要配置 SSH 公钥授权。

#推荐使用 SSH 地址，避免每次输入密码。

#如果你担心同步出错，建议先 push 到主仓库，再 push 到镜像仓库。