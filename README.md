# 圣经集锦

[![Deploy Hexo to GitHub Pages](https://github.com/clyzcst/clyzcst.github.io/actions/workflows/deploy-pages.yml/badge.svg)](https://github.com/clyzcst/clyzcst.github.io/actions/workflows/deploy-pages.yml)

一个基于 [Hexo](https://hexo.io/) 和 [NexT](https://theme-next.js.org/) 的静态内容站点。

- 线上地址：<https://clyzcst.github.io/>
- 源码分支：`master`
- 部署方式：GitHub Actions + GitHub Pages Artifact
- Node.js 版本：24 LTS（见 `.nvmrc`）

## 部署架构

```text
推送 master
    │
    ▼
GitHub Actions
    ├─ npm ci
    ├─ npm run clean && npm run build
    └─ 上传 public/ 为 Pages Artifact
                    │
                    ▼
              GitHub Pages 发布
```

站点不再使用 `hexo deploy` 向 `gh-pages` 分支推送编译结果。GitHub Actions 只会将 `public/` 打包为 Pages Artifact，部署任务也不需要 Node.js 或 `node_modules`。

Node.js 版本由仓库根目录的 `.nvmrc` 统一管理：

- GitHub Actions 通过 `actions/setup-node` 读取 `.nvmrc`。
- `package.json#engines` 用于提示本地环境的版本不一致。

升级 Node.js 时，应同时更新 `.nvmrc` 和 `package.json` 中的 `engines`，并在本地完整执行一次 `npm ci && npm run build`。

## 本地开发

### 1. 准备环境

推荐使用 [nvm](https://github.com/nvm-sh/nvm)：

```bash
nvm install
nvm use
node --version
```

`node --version` 应显示 `v24.x.x`。

### 2. 安装依赖

```bash
npm ci
```

`npm ci` 会严格按照 `package-lock.json` 安装依赖，与 GitHub Actions 的构建环境保持一致。

### 3. 启动预览

```bash
npm run server
```

访问 <http://localhost:4000/>。Hexo 会监听文件变化并自动重新生成页面。

### 4. 本地构建

```bash
npm run clean && npm run build
```

上述命令会先清理旧产物，再将站点生成到 `public/`。`public/` 是本地构建产物，已被 Git 忽略。

## 编辑内容

文章位于 `source/_posts/`。新建文章可使用：

```bash
npx hexo new post "文章标题"
```

文章的 front matter 示例：

```yaml
---
title: 文章标题
date: 2026-08-15 12:00:00
description: 首页上显示的摘要
categories:
  - 分类
tags:
  - 标签
---
```

NexT 主题使用 `description` 生成首页摘要，因此新文章应填写该字段。

## 自动部署

### 首次启用

仓库管理员需要在 GitHub 完成一次设置：

1. 打开仓库的 **Settings → Pages**。
2. 在 **Build and deployment** 下，将 **Source** 设为 **GitHub Actions**。
3. 打开 **Actions → Deploy Hexo to GitHub Pages**，点击 **Run workflow** 进行首次部署，或直接向 `master` 推送一次提交。

工作流文件为 `.github/workflows/deploy-pages.yml`，它支持：

- 向 `master` 分支推送时自动部署。
- 在 GitHub Actions 页面中手动触发。
- 同一时间只运行一个 Pages 部署，避免并发发布互相覆盖。

### 日常发布

手动提交并推送：

```bash
git add -A
git commit -m "Update content"
git push
```

推送完成后，可在仓库的 **Actions** 页面查看构建和部署进度。

### 一键发布脚本

```bash
./auto.sh
```

`auto.sh` 会依次：

1. 运行 `Generator.py` 更新 README 中的项目统计。
2. 提交所有变更并推送 `master`。

脚本只负责更新 `master` 源码分支，不负责安装依赖或编译站点。部署由推送后触发的 GitHub Actions 完成。请在运行前先用 `git status` 确认所有变更都应该被提交。

## 常用命令

| 命令 | 用途 |
| --- | --- |
| `npm ci` | 按锁文件安装依赖 |
| `npm run server` | 启动本地预览服务器 |
| `npm run clean` | 删除 Hexo 缓存和 `public/` |
| `npm run build` | 生成静态站点 |
| `npx hexo new post "标题"` | 创建文章 |
| `./auto.sh` | 更新 README 统计、提交并推送 `master` |

## 目录结构

```text
.
├── .github/workflows/       # GitHub Actions 部署工作流
├── scaffolds/              # Hexo 文章、草稿和页面模板
├── source/
│   ├── _data/             # NexT 主题覆盖配置
│   ├── _posts/            # 站点文章
│   ├── categories/        # 分类页
│   └── tags/              # 标签页
├── themes/.gitkeep        # 占位目录，主题由 npm 安装
├── .nvmrc                 # Node.js 主版本
├── _config.yml            # Hexo 站点配置
├── auto.sh                # 更新并推送 master 的脚本
├── Generator.py           # README 统计生成器
├── package.json           # npm 命令和依赖配置
└── package-lock.json      # 依赖锁文件
```

> `themes/` 必须保持只有 `.gitkeep`。NexT 主题由 `hexo-theme-next` npm 包提供；不要创建 `themes/next/`，否则 Hexo 会优先读取该目录，可能生成空页面。

## 故障排查

### Actions 提示 Node.js 版本或依赖错误

确认 `.nvmrc` 和 `package.json#engines` 的版本一致，然后在同版本 Node.js 下重新生成锁文件：

```bash
nvm use
npm install
npm ci
npm run build
```

### Actions 构建成功，但网站没有更新

- 确认 **Settings → Pages → Source** 已设为 **GitHub Actions**。
- 确认工作流的 `deploy` 任务也已成功，而不只是 `build` 任务。
- 等待 GitHub Pages CDN 刷新，然后强制刷新浏览器缓存。

### 编译后页面为空

检查 `themes/` 下是否意外出现 `next/` 目录。正常情况下，该目录只应包含 `.gitkeep`。

## 项目统计

Count My Code:

<!-- count the code begin -->
```plain
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 Language              Files        Lines         Code     Comments       Blanks
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 JSON                      2         3043         3043            0            0
 Python                    1           20           18            1            1
 Shell                     1           13            5            4            4
 YAML                      2          101           61           28           12
─────────────────────────────────────────────────────────────────────────────────
 Markdown                 14          696            0          536          160
 |- BASH                   2           21           21            0            0
 |- YAML                   1            9            9            0            0
 (Total)                              726           30          536          160
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 Total                    20         3903         3157          569          177
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```
<!-- count the code end -->

The Directory Tree of My Codes:

<!-- directory tree begin -->
```plain
.
├── _config.landscape.yml
├── _config.yml
├── auto.sh
├── CLAUDE.md
├── db.json
├── Generator.py
├── package-lock.json
├── package.json
├── README.md
├── scaffolds
│   ├── draft.md
│   ├── page.md
│   └── post.md
├── SECURITY.md
├── source
│   ├── _data
│   ├── _posts
│   │   ├── ak-圣经.md
│   │   ├── at-the-Bible.md
│   │   ├── at-圣经.md
│   │   ├── id-圣经.md
│   │   ├── 吉吉经.md
│   │   ├── 孙子兵法.md
│   │   ├── 幺言惑众.md
│   │   └── 美因圣经.md
│   ├── categories
│   └── tags
└── themes
```
<!-- directory tree end -->
