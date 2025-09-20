# DevBox 版本管理

## 版本策略

DevBox 使用 [语义化版本控制](https://semver.org/)：

- **主版本号**: 不兼容的 API 更改
- **次版本号**: 向下兼容的功能性新增
- **修订号**: 向下兼容的问题修正

### 版本格式
```
v主版本号.次版本号.修订号
例如: v1.0.0, v1.1.0, v1.0.1
```

## 当前版本

### v1.0.0 (当前稳定版)
- **发布日期**: 2025-09-20
- **状态**: 🟢 稳定版
- **兼容性**: Ubuntu 24.04 LTS

### 主要特性
- ✅ Ubuntu 24.04 LTS 基础镜像
- ✅ SSH 服务完整配置
- ✅ Claude Code CLI 预装
- ✅ Claude Code Router 支持 (@musistudio)
- ✅ Happy 客户端支持 (@slopus)
- ✅ Node.js 20 + Python 3.11
- ✅ 现代化开发工具集
- ✅ 智能安装脚本
- ✅ 多平台支持 (linux/amd64, linux/arm64)

## 更新日志

### [v1.0.0] - 2025-09-20
#### 新增 (Added)
- 🆕 初始版本发布
- 🆕 Ubuntu 24.04 LTS 基础环境
- 🆕 SSH 服务配置 (端口 2222)
- 🆕 Claude Code CLI 智能安装
- 🆕 Claude Code Router 集成
- 🆕 Happy 客户端集成
- 🆕 Node.js 20 开发环境
- 🆕 Python 3.11 开发环境
- 🆕 多平台架构支持
- 🆕 GitHub Actions CI/CD
- 🆕 自动化发布流程

#### 技术特性
- 🛡️ 安全的用户隔离配置
- 🚀 优化的 Docker 镜像分层
- 📊 完整的构建和测试流程
- 📚 详细的使用文档
- 🔧 智能错误处理机制

## 发布计划

### 即将发布 (v1.1.0)
- [ ] 添加 VS Code Remote Development 支持
- [ ] 集成更多开发工具 (Go, Rust, Java)
- [ ] 优化镜像大小和启动速度
- [ ] 添加健康检查端点
- [ ] 改进日志系统

### 未来规划 (v1.2.0)
- [ ] 添加 Kubernetes 支持
- [ ] 集成数据库服务
- [ ] 添加备份和恢复功能
- [ ] 支持自定义配置
- [ ] Web 管理界面

## 发布流程

### 自动发布 (GitHub Actions)
```bash
# 创建版本标签
git tag v1.0.1
git push origin v1.0.1

# GitHub Actions 将自动:
# 1. 构建 Docker 镜像
# 2. 推送到 GHCR 和 Docker Hub
# 3. 创建 GitHub Release
# 4. 更新文档
```

### 手动发布
```bash
# 使用发布脚本
./publish-github.sh

# 或手动步骤
./validate.sh          # 验证配置
docker build -t devbox-ubuntu24:v1.0.1 .
docker push your-username/devbox-ubuntu24:v1.0.1
gh release create v1.0.1
```

## 版本兼容性

### 系统要求
- **Docker**: 20.10+
- **操作系统**: Linux, macOS, Windows (WSL2)
- **架构**: amd64, arm64
- **内存**: 最少 2GB，推荐 4GB+
- **存储**: 最少 5GB 可用空间

### 向后兼容性
- ✅ v1.0.x 系列完全兼容
- ✅ 配置文件格式稳定
- ✅ API 接口稳定
- ✅ 数据持久化兼容

## 镜像标签说明

### 版本标签
- `v1.0.0` - 特定版本
- `v1.0` - 主版本 + 次版本
- `v1` - 主版本
- `latest` - 最新稳定版

### 平台标签
- `linux-amd64` - x86_64 架构
- `linux-arm64` - ARM 64 位架构

### 开发标签
- `develop` - 开发分支版本
- `nightly` - 每夜构建版本

## 获取镜像

### GitHub Container Registry
```bash
docker pull ghcr.io/your-username/devbox-images/devbox-ubuntu24:v1.0.0
```

### Docker Hub
```bash
docker pull your-username/devbox-ubuntu24:v1.0.0
```

### 快速启动
```bash
docker run -d \
  --name devbox \
  -p 2222:22 \
  -v ~/projects:/home/devuser/projects \
  your-username/devbox-ubuntu24:v1.0.0
```

## 维护和支持

### 支持周期
- **v1.0.x**: 长期支持 (LTS)
- **安全更新**: 12 个月
- **Bug 修复**: 6 个月

### 问题反馈
- 🐛 [报告 Bug](https://github.com/your-username/devbox-images/issues)
- 💡 [功能建议](https://github.com/your-username/devbox-images/discussions)
- 📖 [文档问题](https://github.com/your-username/devbox-images/issues/new)

### 贡献指南
1. Fork 仓库
2. 创建功能分支
3. 提交更改
4. 创建 Pull Request
5. 等待审核和合并

---

*最后更新: 2025-09-20*
*维护者: DevBox Team*