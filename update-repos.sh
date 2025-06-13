#!/bin/bash

# 添加远程仓库（如果尚未添加）
git remote add gitee git@gitee.com:funet8/rocky-linux-shell.git
git remote add github git@github.com:funet8/Rocky-Linux-Shell.git

# 查看当前远程仓库
git remote -v

# 添加并提交更改
git add .
git commit -m "自动更新文件"

# 推送至所有远程仓库

git push gitee master   # 推送到 Gitee
git push github main  # 推送到 GitHub

echo "文件已成功更新到所有仓库"