# DevBox GitHub 发布指南

## 🚀 发布概览

本文档介绍如何将 DevBox Docker 镜像发布到 GitHub，包括自动化的 CI/CD 流程和手动发布方法。

## 📋 发布前准备

### 1. 必要工具
```bash
# 安装必要工具
# Ubuntu/Debian
sudo apt install git docker.io gh

# macOS
brew install git docker gh

# Windows
# 安装 Docker Desktop 和 GitHub CLI
```

### 2. 账户准备
- **GitHub 账户**: [注册 GitHub](https://github.com/signup)
- **Docker Hub 账户**: [注册 Docker Hub](https://hub.docker.com/)
- **GitHub Personal Access Token**: [创建 Token](https://github.com/settings/tokens)

### 3. 认证配置
```bash
# GitHub 认证
gh auth login

# Docker Hub 认证
docker login

# 设置环境变量
export GITHUB_USER="your-github-username"
export GITHUB_TOKEN="your-personal-access-token"
export DOCKER_HUB_USER="your-dockerhub-username"
```

## 🎯 发布方式

### 方式一: 一键发布脚本 (推荐)

```bash
# 运行自动化发布脚本
./publish-github.sh

# 脚本将自动完成:
# 1. 检查环境和依赖
# 2. 创建 GitHub 仓库
# 3. 构建 Docker 镜像
# 4. 测试镜像功能
# 5. 推送到 Docker Hub
# 6. 推送到 GitHub Container Registry
# 7. 创建 GitHub Release
# 8. 更新文档
```

### 方式二: GitHub Actions 自动发布

```bash
# 1. 初始化 Git 仓库
git init
git add .
git commit -m "Initial commit: DevBox v1.0.0"

# 2. 创建 GitHub 仓库
gh repo create devbox-images --public --source=. --remote=origin --push

# 3. 配置 GitHub Secrets
gh secret set DOCKERHUB_USERNAME --body="your-dockerhub-username"
gh secret set DOCKERHUB_TOKEN --body="your-dockerhub-token"

# 4. 创建版本标签
git tag v1.0.0
git push origin v1.0.0

# GitHub Actions 将自动构建和发布
```

### 方式三: 手动发布

```bash
# 1. 构建 Docker 镜像
docker build -t devbox-ubuntu24:v1.0.0 .

# 2. 推送到 Docker Hub
docker tag devbox-ubuntu24:v1.0.0 your-username/devbox-ubuntu24:v1.0.0
docker push your-username/devbox-ubuntu24:v1.0.0

# 3. 推送到 GitHub Container Registry
docker tag devbox-ubuntu24:v1.0.0 ghcr.io/your-username/devbox-images/devbox-ubuntu24:v1.0.0
docker push ghcr.io/your-username/devbox-images/devbox-ubuntu24:v1.0.0

# 4. 创建 GitHub Release
gh release create v1.0.0 \
    --title "DevBox v1.0.0" \
    --notes "Release notes for v1.0.0"
```

## 🏗️ CI/CD 配置

### GitHub Actions 工作流

项目已配置以下 GitHub Actions:

#### 1. 构建和发布 (`.github/workflows/build-and-publish.yml`)
- 多平台构建 (linux/amd64, linux/arm64)
- 自动推送到 GHCR 和 Docker Hub
- 创建 GitHub Release
- 镜像测试和验证

#### 2. 测试验证 (`.github/workflows/test.yml`)
- Dockerfile 语法检查
- 脚本权限验证
- 安全扫描 (Trivy)
- 文档链接检查

### Secrets 配置

在 GitHub 仓库设置中配置以下 Secrets:

```bash
# Docker Hub 认证
gh secret set DOCKERHUB_USERNAME
gh secret set DOCKERHUB_TOKEN

# 其他可选配置
gh secret set SLACK_WEBHOOK    # 发布通知
gh secret set TWITTER_BEARER_TOKEN  # 社交媒体发布
```

## 📦 镜像仓库

### GitHub Container Registry (推荐)
```bash
# 拉取镜像
docker pull ghcr.io/your-username/devbox-images/devbox-ubuntu24:v1.0.0

# 运行容器
docker run -d -p 2222:22 ghcr.io/your-username/devbox-images/devbox-ubuntu24:v1.0.0
```

### Docker Hub
```bash
# 拉取镜像
docker pull your-username/devbox-ubuntu24:v1.0.0

# 运行容器
docker run -d -p 2222:22 your-username/devbox-ubuntu24:v1.0.0
```

## 🔄 版本管理

### 版本标签策略
```bash
# 语义化版本标签
git tag v1.0.0    # 主版本
git tag v1.0.1    # 补丁版本
git tag v1.1.0    # 次版本

# 开发版本标签
git tag develop   # 开发分支
git tag nightly   # 每夜构建
```

### 自动版本更新
```bash
# 使用发布脚本自动更新版本
./publish-github.sh --bump-patch    # v1.0.0 -> v1.0.1
./publish-github.sh --bump-minor    # v1.0.0 -> v1.1.0
./publish-github.sh --bump-major    # v1.0.0 -> v2.0.0
```

## 🧪 发布验证

### 自动化测试
```bash
# 运行测试套件
./validate.sh

# 测试镜像构建
docker build -t devbox-test .

# 测试容器运行
docker run -d --name devbox-test -p 2223:22 devbox-test
ssh devuser@localhost -p 2223  # 测试 SSH 连接
```

### 手动验证清单
- [ ] Docker 镜像构建成功
- [ ] 容器启动正常
- [ ] SSH 连接工作
- [ ] 用户权限正确
- [ ] 开发工具可用
- [ ] AI 工具安装正常
- [ ] 文档更新完成
- [ ] Release 创建成功

## 📊 发布监控

### 下载统计
```bash
# Docker Hub 统计
docker hub your-username/devbox-ubuntu24

# GitHub Package 统计
gh api rate-limit
```

### 使用监控
```bash
# 查看镜像拉取情况
docker images | grep devbox

# 监控容器运行
docker ps | grep devbox
```

## 🐛 问题处理

### 常见问题

#### 1. GitHub Actions 失败
```bash
# 检查 Actions 日志
gh run list --limit 10
gh run view <run-id>

# 重新运行失败的 Action
gh run rerun <run-id>
```

#### 2. Docker 推送失败
```bash
# 检查 Docker 登录状态
docker info | grep Username

# 重新登录 Docker Hub
docker login

# 检查镜像标签
docker images | grep devbox
```

#### 3. 权限问题
```bash
# 检查 GitHub 权限
gh auth status

# 更新 Personal Access Token
gh auth refresh
```

### 回滚发布
```bash
# 删除错误的 Release
gh release delete v1.0.0-broken

# 删除错误的标签
git tag -d v1.0.0-broken
git push origin :refs/tags/v1.0.0-broken

# 删除 Docker 镜像
docker rmi your-username/devbox-ubuntu24:v1.0.0-broken
```

## 📈 发布优化

### 构建优化
```dockerfile
# 多阶段构建减少镜像大小
FROM ubuntu:24.04 as builder
# ... 构建步骤 ...

FROM ubuntu:24.04 as runtime
COPY --from=builder /app /app
# ... 运行时配置 ...
```

### 缓存优化
```yaml
# GitHub Actions 缓存配置
- uses: actions/cache@v3
  with:
    path: /tmp/.buildx-cache
    key: ${{ runner.os }}-buildx-${{ github.sha }}
    restore-keys: |
      ${{ runner.os }}-buildx-
```

### 安全扫描
```bash
# 使用 Trivy 扫描镜像
trivy image your-username/devbox-ubuntu24:v1.0.0

# 使用 Snyk 扫描
snyk container test your-username/devbox-ubuntu24:v1.0.0
```

## 🎉 发布成功检查清单

### 立即检查
- [ ] GitHub 仓库创建成功
- [ ] Docker 镜像构建成功
- [ ] 镜像推送到所有仓库
- [ ] GitHub Release 创建成功
- [ ] 文档更新完成

### 后续检查
- [ ] 下载统计正常
- [ ] 用户反馈收集
- [ ] 问题跟踪
- [ ] 版本监控

### 持续改进
- [ ] 用户建议收集
- [ ] 功能需求分析
- [ ] 性能优化
- [ ] 安全更新

---

*发布指南 v1.0 | 最后更新: 2025-09-20*