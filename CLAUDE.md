# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

这是一个基于 Ubuntu 24.04 的完整开发环境 Docker 镜像项目，专门为 AI 辅助编程而设计。项目提供了包含 SSH 访问、预装 AI 工具的完整开发环境。

## 常用命令

### 构建和运行
```bash
# 构建镜像
docker build -t devbox-ubuntu24 .

# 或使用 docker-compose
docker-compose build

# 启动容器（使用默认用户 devuser/devuser）
./start.sh

# 启动容器（指定用户名和密码）
DEV_USER=myuser DEV_PASSWORD=mypassword ./start.sh

# 手动启动（使用环境变量）
DEV_USER=myuser DEV_PASSWORD=mypassword docker-compose up -d

# 停止容器
./stop.sh
docker-compose down

# 连接到容器
./connect.sh
ssh myuser@localhost -p 2222

# 安装增强工具（可选，如果 Dockerfile 中未预装）
./install-enhanced-tools.sh
```

### 容器管理和验证
```bash
# 检查容器状态
docker-compose ps
docker ps | grep devbox

# 查看容器日志
docker-compose logs

# 进入容器
docker-compose exec devbox /bin/bash
# 或进入开发用户环境
docker-compose exec devbox sudo -u devuser /bin/bash

# 快速验证
./quick-check.sh

# 检查已安装的增强工具
go version
rustc --version
gh --version
nvim --version
starship --version
```

### 开发环境设置
```bash
# 在容器内安装 AI 工具
./install-ai-tools.sh

# 安装开发工具
./install-dev-tools.sh

# 设置 SSH
./setup-ssh.sh
```

## 项目架构

### 核心组件
1. **Dockerfile** - 主镜像构建文件，基于 Ubuntu 24.04
   - 创建 devuser 用户和开发环境
   - 安装系统工具、Node.js 20、Python 3
   - 配置 SSH 服务和端口 2222
   - 预装 Claude Code CLI

2. **docker-compose.yml** - 容器编排配置
   - 端口映射：2222 (SSH) 和 8080 (Claude Code Router)
   - 数据持久化：volumes 用于 devuser 配置和项目
   - 健康检查：SSH 服务状态监控

3. **entrypoint.sh** - 容器启动脚本
   - 初始化 SSH 主机密钥
   - 确保开发用户和环境配置
   - 启动 SSH 服务

4. **install-ai-tools.sh** - AI 工具智能安装脚本
   - 安装 Claude Code CLI (多种安装方式)
   - 安装 Claude Code Router (@musistudio/claude-code-router)
   - 安装 Happy Client (@slopus/happy)
   - 配置环境变量和别名

### 数据持久化
- `./config` - 应用配置文件持久化
- `./projects` - 项目代码目录
- `./ssh` - SSH 密钥配置 (只读挂载)
- Docker volumes: `devbox_home` 和 `devbox_projects`

### 网络配置
- 自定义网络：`devbox_network`
- 端口映射：2222→22 (SSH), 8080→8080 (Claude Code Router)

## 开发环境特点

### 预装工具
- **系统**: Ubuntu 24.04 LTS, SSH, zsh, tmux
- **编程环境**: Node.js 20, Python 3, Go, Rust
- **开发工具**: Neovim, Git, GitHub CLI (gh)
- **现代工具**: ripgrep (rg), fd, jq, yq, bat, exa, btop
- **终端增强**: fzf, zoxide, starship, oh-my-zsh
- **网络工具**: nmap, tcpdump, netcat, socat
- **调试工具**: gdb, strace, lsof
- **压缩工具**: 7z, zstd, pv
- **AI 工具**: Claude Code CLI, Claude Code Router, Happy Client

### 用户配置
- 默认用户名: `devuser`
- 默认密码: `devuser`
- 支持通过环境变量自定义用户名和密码
- 主目录: `/home/{DEV_USER}`
- 项目目录: `/home/{DEV_USER}/projects`

### 环境变量
- `TZ=Asia/Shanghai`
- `LANG=en_US.UTF-8`
- `DEV_USER`: 自定义用户名（默认: devuser）
- `DEV_PASSWORD`: 自定义密码（默认: devuser）
- `CLAUDE_CODE_HOME=/home/{DEV_USER}/.claude-code`

## 重要注意事项

1. **SSH 访问**: 容器启动后可通过 SSH 连接，端口 2222
2. **数据持久化**: 使用 docker-compose 启动时，配置和项目数据会持久化
3. **AI 工具安装**: 需要在容器内运行 `./install-ai-tools.sh` 安装完整的 AI 工具套件
4. **首次启动**: entrypoint.sh 会自动初始化开发环境
5. **动态用户**: 支持通过环境变量 `DEV_USER` 和 `DEV_PASSWORD` 自定义用户名和密码
6. **用户目录**: 会根据指定的用户名自动创建对应的用户目录和项目目录

## 故障排除

### SSH 连接问题
- 检查容器状态：`docker ps | grep devbox`
- 检查端口映射：`docker port devbox 22`
- 查看容器日志：`docker-compose logs`

### 构建问题
- 确保运行在支持的系统架构上 (x86_64 或 arm64)
- 清理构建缓存：`docker system prune`
- 重新构建：`docker build --no-cache -t devbox-ubuntu24 .`

### 工具安装问题
- 进入容器检查：`docker exec -it devbox /bin/bash`
- 重新运行安装脚本：`./install-ai-tools.sh`

## 增强开发工具

### 现代化命令行工具

#### 文件操作
```bash
# 使用 exa 替代 ls (带 Git 状态和图标)
ll          # 漂亮的文件列表
la          # 包含隐藏文件
lt          # 树状显示

# 使用 bat 替代 cat (语法高亮)
cat file.js # 带语法高亮的文件内容

# 使用 fd 替代 find (更快的文件搜索)
fd "*.py"   # 搜索 Python 文件
fd -d 2     # 最多深入 2 层目录
```

#### 搜索工具
```bash
# 使用 ripgrep 替代 grep (超快搜索)
rg "function"     # 搜索包含 function 的文件
rg -t py "import" # 只在 Python 文件中搜索
rg -i "error"     # 不区分大小写搜索
```

#### 系统监控
```bash
# 使用 btop 替代 htop (更美观的系统监控)
btop    # 启动系统监控器

# 模糊搜索
fzf     # 模糊搜索文件历史
Ctrl+R  # 在命令历史中搜索
```

### 编程语言支持

#### Go 开发
```bash
# 检查 Go 版本
go version

# 创建 Go 项目
mkdir myproject && cd myproject
go mod init myproject

# 常用 Go 命令
gobuild   # 构建项目
gotest    # 运行测试
gorun     # 运行程序
gofmt     # 格式化代码
```

#### Rust 开发
```bash
# 检查 Rust 版本
rustc --version
cargo --version

# 创建 Rust 项目
cargo new myproject
cd myproject

# 常用 Cargo 命令
cargo build    # 构建项目
cargo run      # 运行项目
cargo test     # 运行测试
cargo check    # 检查代码
```

### 终端增强

#### 智能目录跳转
```bash
# 使用 zoxide 替代 cd (记录访问频率)
z project     # 跳转到最常访问的 project 目录
z docs        # 跳转到 docs 目录
z -l project  # 查看匹配的目录列表
```

#### Git 增强
```bash
# 常用 Git 别名
gs    # git status
gl    # git log --oneline --graph
ga    # git add
gc    # git commit
gp    # git push
gd    # git diff
gco   # git checkout
```

#### GitHub CLI
```bash
# 管理 GitHub 仓库
gh issue list       # 列出 issues
gh pr create        # 创建 Pull Request
gh pr view          # 查看 PR 详情
gh pr list          # 列出 PRs
gh repo clone user/repo  # 克隆仓库
```

### Neovim 配置

#### 基本使用
```bash
# 启动 Neovim
nvim file.txt
nvim .              # 打开当前目录

# 常用快捷键
<leader>w           # 保存文件
<leader>q           # 退出
<leader>so          # 重新加载配置
<leader>v           # 垂直分屏
<leader>h           # 水平分屏
<leader>nh          # 清除搜索高亮
```

#### 文件操作
```bash
# 缓冲区管理
<leader>bn          # 下一个缓冲区
<leader>bp          # 上一个缓冲区
<leader>bd          # 删除缓冲区
```

### 快速开始指南

#### 首次连接后
```bash
# 1. 检查增强工具安装情况
go version && rustc --version && gh --version

# 2. 验证终端工具
rg --version && fd --version && bat --version

# 3. 测试智能跳转
cd ~ && z projects  # 跳转到项目目录

# 4. 启动 Neovim
nvim --version

# 5. 检查 Shell 提示符
echo $SHELL
```

#### 日常开发工作流
```bash
# 1. 进入项目目录
z myproject

# 2. 查看文件状态
ll

# 3. 搜索文件内容
rg "function"

# 4. 编辑文件
nvim main.go

# 5. Git 操作
gs && ga . && gc -m "feat: add new feature"

# 6. 运行测试
gotest

# 7. 提交到 GitHub
gp && gh pr create
```

### 性能提示

- **ripgrep (rg)**: 比传统 grep 快 5-10 倍
- **fd**: 比 find 快 5-10 倍，更智能的默认设置
- **bat**: 自动检测文件类型并应用语法高亮
- **exa**: 支持图标、Git 状态、树状显示
- **btop**: 实时系统监控，支持图表显示
- **zoxide**: 基于访问频率的智能目录跳转