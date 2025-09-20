# 🚀 DevBox GitHub 快速发布指南

## 5 分钟快速发布

### 第一步：准备工作
```bash
# 1. 安装必要工具
sudo apt install git docker.io gh   # Ubuntu/Debian
# 或
brew install git docker gh           # macOS

# 2. 登录账户
gh auth login                        # GitHub
docker login                         # Docker Hub
```

### 第二步：一键发布
```bash
# 运行发布脚本（推荐）
./publish-github.sh

# 或手动发布
git init
git add .
git commit -m "Initial release: DevBox v1.0.0"
gh repo create devbox-images --public --source=. --push
git tag v1.0.0
git push origin v1.0.0
```

### 第三步：验证发布
```bash
# 检查 GitHub Actions
gh run list --limit 5

# 测试镜像
docker pull ghcr.io/your-username/devbox-images/devbox-ubuntu24:v1.0.0
docker run -d -p 2222:22 --name devbox-test ghcr.io/your-username/devbox-images/devbox-ubuntu24:v1.0.0
ssh devuser@localhost -p 2222  # 密码: devuser
```

## 📦 发布地址

发布成功后，你的 DevBox 将在以下地址可用：

- **GitHub**: https://github.com/your-username/devbox-images
- **Docker Hub**: https://hub.docker.com/r/your-username/devbox-ubuntu24
- **GitHub Container Registry**: ghcr.io/your-username/devbox-images/devbox-ubuntu24

## 🎯 用户使用方法

### Docker Hub 用户
```bash
docker run -d -p 2222:22 --name devbox your-username/devbox-ubuntu24:v1.0.0
ssh devuser@localhost -p 2222
```

### GitHub Container Registry 用户
```bash
docker run -d -p 2222:22 --name devbox ghcr.io/your-username/devbox-images/devbox-ubuntu24:v1.0.0
ssh devuser@localhost -p 2222
```

## 🔧 必要的 GitHub Secrets

在仓库设置中配置：
- `DOCKERHUB_USERNAME`
- `DOCKERHUB_TOKEN`

```bash
gh secret set DOCKERHUB_USERNAME --body="your-dockerhub-username"
gh secret set DOCKERHUB_TOKEN --body="your-dockerhub-token"
```

## 🆘 遇到问题？

### 常见问题
1. **GitHub CLI 未安装**: `brew install gh` 或 `sudo apt install gh`
2. **Docker 未安装**: 安装 [Docker Desktop](https://docker.com/products/docker-desktop)
3. **权限问题**: 确保已登录 GitHub 和 Docker Hub
4. **网络问题**: 检查网络连接和代理设置

### 获取帮助
- 📖 [详细发布指南](PUBLISHING.md)
- 🐛 [报告问题](https://github.com/your-username/devbox-images/issues)
- 💬 [GitHub Discussions](https://github.com/your-username/devbox-images/discussions)

---

**🎉 恭喜！你的 DevBox 现已发布到 GitHub！**

*快速发布指南 v1.0 | 2025-09-20*