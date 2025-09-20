# DevBox - Ubuntu 24.04 开发环境 Docker 镜像

一个基于 Ubuntu 24.04 的完整开发环境 Docker 镜像，预装了常用的开发工具和 AI 辅助编程工具。

## 功能特性

- ✅ **Ubuntu 24.04 LTS** 基础系统
- ✅ **SSH 访问** 支持（端口 2222）
- ✅ **Claude Code CLI** 预装
- ✅ **Claude Code Router** (@musistudio) 支持
- ✅ **Happy** (@slopus) - Claude Code Mobile/Web Client
- ✅ **多语言支持**：Python, Node.js, Go, Rust
- ✅ **云原生工具**：Docker, kubectl, helm
- ✅ **现代化终端**：zsh, oh-my-zsh, starship
- ✅ **数据持久化**：用户配置和项目代码

## 快速开始

### 1. 构建镜像

```bash
# 构建基础镜像
docker-compose build

# 或者使用更完整的构建（包含额外开发工具）
./install-dev-tools.sh
docker-compose build
```

### 2. 启动容器

```bash
# 启动开发环境
docker-compose up -d

# 查看容器状态
docker-compose ps
```

### 3. 连接到容器

#### SSH 连接

```bash
# 使用密码连接
ssh devuser@localhost -p 2222
# 密码: devuser

# 使用 SSH 密钥连接（推荐）
ssh -i ssh/id_rsa devuser@localhost -p 2222
```

#### Docker exec 连接

```bash
# 进入开发用户环境
docker-compose exec devbox sudo -u devuser /bin/bash

# 进入 root 环境
docker-compose exec devbox /bin/bash
```

## 预装工具列表

### 基础系统工具
- Ubuntu 24.04 LTS
- SSH 服务器
- Git, curl, wget
- vim, tmux, htop
- zsh, oh-my-zsh

### 编程语言和运行时
- **Node.js 20** - JavaScript 运行时
- **Python 3.11** - Python 运行时
- **Go 1.21** - Go 语言
- **Rust** - 系统编程语言

### AI 辅助编程工具
- **Claude Code CLI** - Anthropic 的 AI 编程助手
- **Claude Code Router** - @musistudio 开发的 Claude Code 路由服务
- **Happy** - @slopus 开发的 Claude Code Mobile/Web 客户端

### 云原生工具
- **Docker CLI** - 容器管理
- **kubectl** - Kubernetes 集群管理
- **helm** - Kubernetes 包管理
- **Azure CLI** - Azure 云工具
- **AWS CLI** - AWS 云工具

### 现代化开发工具
- **starship** - 跨平台 shell 提示符
- **zoxide** - 智能目录跳转
- **fzf** - 模糊查找器
- **ripgrep** - 快速文本搜索
- **bat** - 语法高亮的 cat
- **exa** - 现代化的 ls
- **neovim** - 现代化 Vim
- **lazygit** - 简单的 Git 终端 UI

## 目录结构

```
devbox-images/
├── Dockerfile              # 主镜像构建文件
├── docker-compose.yml      # 容器编排配置
├── entrypoint.sh          # 容器启动脚本
├── setup-ssh.sh          # SSH 配置脚本
├── install-dev-tools.sh   # 开发工具安装脚本
├── ssh/                  # SSH 配置目录
│   ├── id_rsa           # SSH 私钥
│   ├── id_rsa.pub       # SSH 公钥
│   └── authorized_keys  # 授权密钥
├── config/              # 用户配置持久化
└── projects/            # 项目代码目录
```

## 配置说明

### SSH 配置

首次使用前，请运行 SSH 配置脚本：

```bash
chmod +x setup-ssh.sh
./setup-ssh.sh
```

这将生成 SSH 密钥对并配置 authorized_keys。

### 环境变量

可以通过环境变量自定义容器配置：

```yaml
environment:
  - TZ=Asia/Shanghai      # 时区设置
  - LANG=en_US.UTF-8      # 语言设置
  - CLAUDE_API_KEY=your_key  # Claude API 密钥
```

### 数据持久化

容器使用以下卷来持久化数据：

- `devbox_home` - 用户主目录
- `devbox_projects` - 项目代码目录
- `./ssh` - SSH 配置文件
- `./config` - 应用配置文件

## 使用 Claude Code

### 初始化 Claude Code

首次使用时，需要进行身份验证：

```bash
# 在容器内执行
claude-code auth login
```

### 使用 Claude Code

```bash
# 基本使用
claude-code "帮我创建一个 Python 脚本"

# 在项目目录中使用
cd projects/my-project
claude-code "优化这个 React 组件"
```

## 故障排除

### SSH 连接失败

1. 检查容器是否正在运行：`docker-compose ps`
2. 检查端口映射：`docker-compose port devbox 22`
3. 检查 SSH 服务：`docker-compose logs devbox`

### 工具无法使用

1. 确保已运行安装脚本：`./install-dev-tools.sh`
2. 重新构建镜像：`docker-compose build --no-cache`

### 权限问题

1. 检查文件权限：`ls -la ssh/`
2. 重新运行 SSH 配置：`./setup-ssh.sh`

## 更新和维护

### 更新基础镜像

```bash
# 拉取最新的 Ubuntu 基础镜像
docker pull ubuntu:24.04

# 重新构建
docker-compose build --no-cache
```

### 更新开发工具

```bash
# 在容器内运行
./install-dev-tools.sh
```

## 贡献

欢迎提交 Issue 和 Pull Request 来改进这个开发环境！

## 许可证

MIT License