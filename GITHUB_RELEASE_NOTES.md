# DevBox v1.0.0 Release

## 🎉 版本信息
- **版本**: v1.0.0
- **发布时间**: 2025-09-20
- **兼容性**: Ubuntu 24.04 LTS
- **架构**: linux/amd64, linux/arm64

## ✨ 主要特性

### 🐧 系统基础
- 🆕 **Ubuntu 24.04 LTS** - 最新的长期支持版本
- 🔐 **SSH 服务** - 完整配置，支持密码和密钥认证
- 👤 **用户管理** - 预配置的 devuser 用户，sudo 权限
- 🌍 **多语言支持** - 中文环境，UTF-8 编码

### 🤖 AI 开发工具
- 🧠 **Claude Code CLI** - Anthropic 官方 AI 编程助手
- 🛣️ **Claude Code Router** - @musistudio 开发的路由服务
- 😊 **Happy** - @slopus 开发的 Claude Code Mobile/Web 客户端
- 🔄 **智能安装** - 自动检测和安装 AI 工具，支持多种安装方式

### 🛠️ 开发环境
- 🟢 **Node.js 20** - 最新 LTS 版本
- 🐍 **Python 3.11** - 现代 Python 环境
- 📦 **包管理** - npm, pip3 预配置
- 🔧 **开发工具** - git, vim, zsh, tmux, htop, tree

### 🚀 部署特性
- 🐳 **Docker 优化** - 多阶段构建，镜像大小优化
- 🌐 **多平台支持** - amd64, arm64 架构
- 📊 **CI/CD 集成** - GitHub Actions 自动化构建
- 🔒 **安全配置** - 用户隔离，最小权限原则

## 🚀 快速开始

### 方式一：Docker Hub（推荐）
```bash
# 拉取镜像
docker pull wuxiaobai24/devbox-ubuntu24:v1.0.0

# 运行容器
docker run -d \
  --name devbox \
  -p 2222:22 \
  -v ~/projects:/home/devuser/projects \
  wuxiaobai24/devbox-ubuntu24:v1.0.0

# 连接容器
ssh devuser@localhost -p 2222
# 密码: devuser
```

### 方式二：GitHub Container Registry
```bash
# 拉取镜像
docker pull ghcr.io/wuxiaobai24/devbox-images/devbox-ubuntu24:v1.0.0

# 运行容器
docker run -d \
  --name devbox \
  -p 2222:22 \
  ghcr.io/wuxiaobai24/devbox-images/devbox-ubuntu24:v1.0.0
```

### 方式三：本地构建
```bash
# 克隆仓库
git clone https://github.com/wuxiaobai24/devbox-images.git
cd devbox-images

# 使用便捷脚本
./start.sh

# 连接到容器
./connect.sh
```

## 🔧 连接后配置

### 初始化 AI 工具
```bash
# 在容器内运行
./init-dev-env.sh

# 智能安装 AI 工具
sudo /usr/local/bin/install-ai-tools.sh

# Claude Code 认证
claude-code auth login
```

### 可用命令别名
```bash
cc          # claude-code
ccr         # claude-code-router
hc          # happy
```

## 📦 预装软件清单

### 系统工具
- **Ubuntu 24.04 LTS** - 基础操作系统
- **OpenSSH Server** - SSH 服务（端口 22）
- **sudo, curl, wget** - 系统管理工具
- **git, vim, zsh** - 开发基础工具
- **tmux, htop, tree** - 系统监控和导航

### 编程环境
- **Node.js 20** - JavaScript 运行时
- **npm** - Node.js 包管理器
- **Python 3.11** - Python 运行时
- **pip3** - Python 包管理器
- **build-essential** - C/C++ 编译工具

### AI 工具
- **Claude Code CLI** - AI 编程助手
- **Claude Code Router** - 路由服务
- **Happy Client** - Mobile/Web 客户端
- **Anthropic SDK** - Python API 客户端

## 📁 项目结构
```
devbox-images/
├── Dockerfile              # 主镜像构建文件
├── docker-compose.yml      # 容器编排配置
├── entrypoint.sh          # 容器启动脚本
├── start.sh               # 一键启动脚本
├── connect.sh             # 连接脚本
├── install-ai-tools.sh    # AI 工具安装脚本
├── validate.sh            # 环境验证脚本
├── README.md              # 详细使用说明
├── INSTALL.md             # 安装指南
└── PUBLISHING.md          # 发布指南
```

## 🔐 默认配置

### 用户信息
- **用户名**: devuser
- **密码**: devuser
- **家目录**: /home/devuser
- **Shell**: /bin/bash
- **权限**: sudo (无密码)

### 网络配置
- **SSH 端口**: 2222 (宿主机) → 22 (容器)
- **可选端口**: 8080 (Claude Code Router)

### 持久化存储
- `~/projects/` - 项目代码目录
- `~/.ssh/` - SSH 密钥和配置
- `~/.config/` - 应用配置文件
- `~/.local/` - 本地数据和缓存

## 🛡️ 安全特性

### 容器安全
- **用户隔离** - 非特权用户运行
- **最小权限** - 仅必要的 sudo 权限
- **网络隔离** - 独立的网络命名空间
- **文件系统只读** - 基础系统只读，用户数据可写

### 访问控制
- **SSH 密钥认证** - 支持密钥和密码两种方式
- **防火墙规则** - 仅暴露必要端口
- **日志记录** - 完整的 SSH 和系统日志

## 📚 文档资源

### 核心文档
- [README.md](README.md) - 完整使用指南
- [INSTALL.md](INSTALL.md) - 详细安装步骤
- [PUBLISHING.md](PUBLISHING.md) - 发布和贡献指南
- [VERSION.md](VERSION.md) - 版本信息和更新日志

### 快速指南
- [QUICK_PUBLISH.md](QUICK_PUBLISH.md) - 快速发布指南
- [BUILD_SUMMARY.md](BUILD_SUMMARY.md) - 构建测试报告
- [ISSUES.md](ISSUES.md) - 常见问题解答

## 🔄 更新和维护

### 版本更新
```bash
# 拉取最新版本
docker pull wuxiaobai24/devbox-ubuntu24:latest

# 重新创建容器
docker stop devbox && docker rm devbox
docker run -d --name devbox -p 2222:22 wuxiaobai24/devbox-ubuntu24:latest
```

### 备份和恢复
```bash
# 备份用户数据
docker cp devbox:/home/devuser/projects ./backup/
docker cp devbox:/home/devuser/.ssh ./backup/
docker cp devbox:/home/devuser/.config ./backup/
```

## 🐛 问题反馈

### 获取帮助
- 📖 **文档**: [README.md](README.md)
- 🐛 **问题报告**: [GitHub Issues](https://github.com/wuxiaobai24/devbox-images/issues)
- 💡 **功能建议**: [GitHub Discussions](https://github.com/wuxiaobai24/devbox-images/discussions)
- 📧 **联系**: [GitHub Profile](https://github.com/wuxiaobai24)

### 常见问题
1. **SSH 连接失败**: 检查端口映射和防火墙设置
2. **AI 工具安装失败**: 确保网络连接正常，重试安装脚本
3. **权限问题**: 使用 devuser 用户，避免直接使用 root
4. **性能问题**: 检查系统资源，调整 Docker 内存限制

## 🎯 路线图

### v1.1.0 (计划中)
- [ ] VS Code Remote Development 支持
- [ ] 更多编程语言支持 (Go, Rust, Java)
- [ ] 数据库服务集成
- [ ] 性能优化和镜像大小优化

### v1.2.0 (远期规划)
- [ ] Kubernetes 支持
- [ ] Web 管理界面
- [ ] 自动备份和恢复
- [ ] 企业级功能

## 🤝 贡献指南

我们欢迎所有形式的贡献！

### 如何贡献
1. **Fork** 仓库
2. **创建** 功能分支: `git checkout -b feature/amazing-feature`
3. **提交** 更改: `git commit -m 'Add amazing feature'`
4. **推送** 分支: `git push origin feature/amazing-feature`
5. **创建** Pull Request

### 开发环境设置
```bash
# 克隆仓库
git clone https://github.com/wuxiaobai24/devbox-images.git
cd devbox-images

# 运行测试
./validate.sh

# 构建镜像
docker build -t devbox-test .
```

## 📄 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件。

## 🙏 致谢

感谢以下开源项目和贡献者：

- [Ubuntu](https://ubuntu.com/) - 基础操作系统
- [Docker](https://docker.com/) - 容器化平台
- [Claude Code](https://claude.ai/code) - AI 编程助手
- [@musistudio](https://github.com/musistudio) - Claude Code Router
- [@slopus](https://github.com/slopus) - Happy 客户端

---

**🎉 DevBox v1.0.0 - 让开发环境搭建变得简单！**

*发布时间: 2025-09-20 | 维护者: @wuxiaobai24*