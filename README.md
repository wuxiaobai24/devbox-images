# DevBox - Ubuntu 24.04 开发环境 Docker 镜像

一个基于 Ubuntu 24.04 的完整开发环境 Docker 镜像，预装了 SSH 访问和 AI 辅助编程工具。

## 功能特性

- ✅ **Ubuntu 24.04 LTS** 基础系统
- ✅ **SSH 访问** 支持（端口 2222）
- ✅ **Claude Code CLI** 预装
- ✅ **Claude Code Router** 支持
- ✅ **Happy Client** 支持
- ✅ **Node.js 20** 和 npm
- ✅ **Python 3** 和 pip
- ✅ **现代化终端**：zsh, vim, tmux
- ✅ **开发工具**：git, curl, wget
- ✅ **数据持久化**：用户配置和项目代码

## 快速开始

### 1. 构建镜像

```bash
# 直接构建
docker build -t devbox-ubuntu24 .

# 或者使用 docker-compose
docker-compose build
```

### 2. 启动容器

```bash
# 使用 docker run
docker run -d -p 2222:22 --name devbox devbox-ubuntu24

# 或者使用 docker-compose
docker-compose up -d
```

### 3. 连接到容器

#### SSH 连接（推荐）

```bash
# 使用密码连接
ssh devuser@localhost -p 2222
# 密码: devuser
```

#### Docker exec 连接

```bash
# 进入开发用户环境
docker exec -it devbox sudo -u devuser /bin/bash

# 进入 root 环境
docker exec -it devbox /bin/bash
```

## 预装工具列表

### 系统基础
- **Ubuntu 24.04 LTS** - 基础操作系统
- **SSH 服务器** - 远程访问支持
- **用户管理** - devuser 用户，密码 devuser

### 编程语言和工具
- **Node.js 20** - JavaScript 运行时和 npm
- **Python 3** - Python 运行时和 pip
- **Git** - 版本控制
- **curl, wget** - 网络工具

### AI 辅助编程工具
- **Claude Code CLI** - Anthropic 的 AI 编程助手
- **Claude Code Router** - Claude Code 路由服务
- **Happy Client** - Claude Code 移动/网页客户端

### 开发工具
- **zsh** - 现代化 shell
- **vim, tmux** - 终端编辑器和会话管理
- **htop** - 系统监控工具
- **man** - 帮助文档

## 项目文件结构

```
devbox-images/
├── Dockerfile              # 主镜像构建文件
├── docker-compose.yml      # 容器编排配置
├── entrypoint.sh          # 容器启动脚本
├── install-ai-tools.sh    # AI 工具安装脚本
├── connect.sh            # 快速连接脚本
├── start.sh              # 启动脚本
├── stop.sh               # 停止脚本
├── quick-check.sh        # 快速验证脚本
├── devbox.json           # Devbox 配置
├── config/               # 应用配置持久化目录
├── projects/             # 项目代码目录
└── ssh/                  # SSH 配置目录
```

## 使用说明

### SSH 访问

容器已预配置 SSH 服务器，默认端口 2222：

```bash
# 连接到容器
ssh devuser@localhost -p 2222
# 密码: devuser
```

### 数据持久化

使用 docker-compose 时，以下目录会持久化：

- `./config` - 应用配置文件
- `./projects` - 项目代码目录

### 环境变量

可以在 docker-compose.yml 中设置环境变量：

```yaml
environment:
  - TZ=Asia/Shanghai      # 时区设置
  - LANG=en_US.UTF-8      # 语言设置
```

## 使用 AI 工具

### Claude Code CLI

容器已预装 Claude Code CLI：

```bash
# 在容器内执行
claude-code auth login  # 首次使用需要登录
claude-code "帮我创建一个 Python 脚本"
```

### 安装 AI 工具

运行 AI 工具安装脚本：

```bash
# 在容器内执行
./install-ai-tools.sh
```

此脚本会安装：
- Claude Code Router
- Happy Client
- 其他 AI 辅助工具

## 故障排除

### SSH 连接失败

1. 检查容器状态：`docker ps | grep devbox`
2. 检查端口映射：`docker port devbox 22`
3. 查看容器日志：`docker logs devbox`

### 构建失败

1. 检查 Docker 版本：`docker --version`
2. 清理构建缓存：`docker system prune`
3. 重新构建：`docker build --no-cache -t devbox-ubuntu24 .`

### 工具无法使用

1. 进入容器检查：`docker exec -it devbox /bin/bash`
2. 运行安装脚本：`./install-ai-tools.sh`

## 快速脚本

项目提供了一些快速操作脚本：

```bash
# 启动容器
./start.sh

# 停止容器
./stop.sh

# 连接到容器
./connect.sh

# 快速检查
./quick-check.sh
```

## 贡献

欢迎提交 Issue 和 Pull Request 来改进这个开发环境！

## 许可证

MIT License