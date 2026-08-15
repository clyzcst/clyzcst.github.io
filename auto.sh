#!/bin/bash

./Generator.py

# 获取当前时间
TIME=$(date +"%Y-%m-%d %H:%M:%S")

# 添加所有修改
git add -A

# 提交并推送 master 源码分支；网站构建与部署由 GitHub Actions 完成
git commit -m "Site updated: $TIME"
git push
