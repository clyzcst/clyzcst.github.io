# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

Hexo 8 静态博客（「圣经集锦」，语录合集站点），源码在 master 分支，`hexo deploy` 把生成的 `public/` 强推到 gh-pages 分支，由 GitHub Pages 提供服务（https://clyzcst.github.io/）。

## 常用命令

```bash
npm install                        # 安装依赖（含 NexT 主题）
npx hexo clean && npx hexo generate  # 清理并生成到 public/（应生成 83 个文件）
npx hexo server                    # 本地预览 http://localhost:4000
npx hexo deploy                    # 部署：强推 public/ 到 gh-pages
./auto.sh                          # 全流程：Generator.py → git 提交推送 → hexo clean+g+d
./Generator.py                     # 重写 README 的代码统计表和目录树
```

## 关键陷阱（改动前必读）

- **`themes/` 必须保持只有 `.gitkeep`**。主题 NexT 通过 npm 包 `hexo-theme-next` 安装。Hexo 解析主题时 `themes/<name>` 优先于 `node_modules/hexo-theme-<name>`；一旦出现 `themes/next` 目录（哪怕是空的），Hexo 会以它为主题目录、找不到任何布局，全站每个页面都渲染成 **0 字节**且不报错。历史上该目录曾是无 `.gitmodules` 的悬空子模块，正是全站空白的根因，勿再引入。
- **首页折叠靠 front matter 的 `description:`**，不是 `<!-- more -->`。多篇文章的 `<!-- more -->` 紧跟 front matter、摘要为空，此时 NexT 会在首页渲染全文。NexT 配置 `excerpt_description: true` 让 `description` 优先生效：首页只显示这句话 + 「阅读全文」按钮。**新文章务必写 `description:`**。
- **`hexo deploy` 会把本地 master 的跟踪改成 gh-pages**（hexo-deployer-git 的副作用）。部署后如需 pull，先确认 `git config branch.master.merge` 仍是 `refs/heads/master`，否则改回。
- **跑 `Generator.py` 前先 `npx hexo clean`**：它用 `lsd --tree` 生成目录树，只排除了 node_modules/.deploy_git/public，`db.json` 若存在会混入目录树。依赖系统命令 `tokei` 和 `lsd`。统计有自引用滞后（统计的是改写前的 README），README 行数变化后需跑两遍才收敛。

## 内容约定

- 文章在 `source/_posts/`，中文，front matter 日期格式 `date: YYYY-M-D HH:mm:ss`，数字与中文间加空格（如「荣获 60 分」）。
- 语录文风格：`### 名人名言`/`### 公式` 等列表小节 + `### 著名事迹` 下按 `#### 第N记` 记事。
- 「记」标题为章回体对仗押韵句，例：`#### 第七记 一点开会两点到 一纸公告成绩消`；每记以「惨遭嘲笑。」收尾。
