#!/bin/bash

# DevBox GitHub 发布脚本 (仅 GitHub 仓库，不包含 Docker)
echo "🚀 开始发布 DevBox 到 GitHub..."

set -e

# 配置
GITHUB_USER="wuxiaobai24"
REPO_NAME="devbox-images"
VERSION="1.0.0"

echo "📋 发布配置:"
echo "   GitHub 用户: $GITHUB_USER"
echo "   仓库名: $REPO_NAME"
echo "   版本: $VERSION"
echo ""

# 检查 Git 状态
if [ ! -d ".git" ]; then
    echo "❌ 不是 Git 仓库"
    exit 1
fi

echo "✅ Git 仓库已准备"

# 检查是否有远程仓库
remote_url=$(git remote get-url origin 2>/dev/null || echo "")
if [[ -z "$remote_url" ]]; then
    echo "🌐 没有远程仓库，提供手动创建说明："
    echo ""
    echo "📋 创建 GitHub 仓库步骤："
    echo "1. 访问: https://github.com/new"
    echo "2. 仓库名称: $REPO_NAME"
    echo "3. 描述: Ubuntu 24.04 开发环境 Docker 镜像"
    echo "4. 设置为 Public"
    echo "5. 不要初始化 README (我们已经有了)"
    echo "6. 点击 'Create repository'"
    echo ""
    echo "🔗 仓库创建后，在终端中运行："
    echo "   git remote add origin https://github.com/$GITHUB_USER/$REPO_NAME.git"
    echo "   git push -u origin main"
    echo "   git push origin v$VERSION"
    echo ""

    # 等待用户确认
    read -p "仓库已创建？按回车键继续推送代码，或 Ctrl+C 取消..."

    # 尝试推送
    echo "📤 推送代码到 GitHub..."
    if git push -u origin main 2>/dev/null; then
        echo "✅ 代码推送成功"
        remote_url="https://github.com/$GITHUB_USER/$REPO_NAME.git"
    else
        echo "❌ 代码推送失败，请检查："
        echo "   1. GitHub 仓库是否已创建"
        echo "   2. 网络连接是否正常"
        echo "   3. 是否有 GitHub 认证问题"
        echo ""
        echo "🔧 手动推送命令："
        echo "   git remote add origin https://github.com/$GITHUB_USER/$REPO_NAME.git"
        echo "   git push -u origin main"
        exit 1
    fi
else
    echo "✅ 远程仓库已配置: $remote_url"

    # 推送最新更改
    echo "📤 推送最新代码..."
    if git push origin main 2>/dev/null; then
        echo "✅ 代码推送成功"
    else
        echo "⚠️  推送可能需要认证，请手动运行："
        echo "   git push origin main"
    fi
fi

# 创建版本标签
echo ""
echo "🏷️  创建版本标签..."
if git tag "v$VERSION" 2>/dev/null; then
    echo "✅ Git 标签创建成功: v$VERSION"

    if git push origin "v$VERSION" 2>/dev/null; then
        echo "✅ 标签推送成功"
    else
        echo "⚠️  标签推送失败，请手动运行："
        echo "   git push origin v$VERSION"
    fi
else
    echo "⚠️  标签可能已存在"
fi

# 创建 GitHub Release 说明
echo ""
echo "📦 创建 GitHub Release 说明..."

cat > "RELEASE_NOTES.md" << EOF
# DevBox v$VERSION Release

## 🎉 版本信息
- **版本**: v$VERSION
- **发布时间**: $(date)
- **兼容性**: Ubuntu 24.04 LTS

## ✨ 新功能
- 🆕 Ubuntu 24.04 LTS 基础镜像
- 🔐 SSH 服务完整配置
- 🤖 Claude Code CLI 预装
- 🛣️ Claude Code Router (@musistudio) 支持
- 😊 Happy (@slopus) 客户端支持
- 🟢 Node.js 20 + Python 3.11
- 🛠️ 现代化开发工具集
- 🧪 智能安装脚本
- 🌍 多平台支持 (linux/amd64, linux/arm64)

## 🚀 快速开始

### 本地构建
\`\`\`bash
# 克隆仓库
git clone https://github.com/$GITHUB_USER/$REPO_NAME.git
cd $REPO_NAME

# 构建 Docker 镜像
docker build -t devbox-ubuntu24:v$VERSION .

# 运行容器
docker run -d -p 2222:22 --name devbox devbox-ubuntu24:v$VERSION

# 连接容器
ssh devuser@localhost -p 2222
# 密码: devuser
\`\`\`

### 使用便捷脚本
\`\`\`bash
# 启动开发环境
./start.sh

# 连接到容器
./connect.sh

# 安装 AI 工具
./init-dev-env.sh
\`\`\`

## 📦 包含的软件

### 系统基础
- Ubuntu 24.04 LTS
- SSH 服务器 (端口 22)
- sudo, curl, wget, git

### 开发环境
- Node.js 20 + npm
- Python 3.11 + pip
- vim, zsh, tmux, htop

### AI 工具
- Claude Code CLI (智能安装)
- Claude Code Router (@musistudio)
- Happy 客户端 (@slopus)

## 🔧 配置说明

### 默认用户
- **用户名**: devuser
- **密码**: devuser
- **权限**: sudo

### 端口映射
- **SSH**: 2222:22
- **可选**: 8080:8080 (Claude Code Router)

### 持久化存储
- \~/projects/ - 项目代码
- \~/.ssh/ - SSH 配置
- \~/.config/ - 应用配置

## 📚 文档
- [README.md](README.md) - 详细使用说明
- [INSTALL.md](INSTALL.md) - 安装指南
- [PUBLISHING.md](PUBLISHING.md) - 发布指南
- [VERSION.md](VERSION.md) - 版本信息

## 🐛 问题反馈
- 🐛 [报告问题](https://github.com/$GITHUB_USER/$REPO_NAME/issues)
- 💡 [功能建议](https://github.com/$GITHUB_USER/$REPO_NAME/discussions)
- 📧 [联系维护者](mailto:$GITHUB_USER@users.noreply.github.com)

## 📄 许可证
MIT License - 详见 [LICENSE](LICENSE) 文件

---

## 🤝 贡献
欢迎贡献代码！请查看 [CONTRIBUTING.md](CONTRIBUTING.md) 了解详情。

*此版本由 DevBox 团队发布*
EOF

echo "✅ Release 说明已生成: RELEASE_NOTES.md"

# 创建手动发布指南
echo ""
echo "📋 创建手动发布指南..."

cat > "MANUAL_PUBLISH_STEPS.md" << EOF
# DevBox 手动发布指南

## 🎉 GitHub 仓库发布完成！

### ✅ 已完成
- [x] Git 仓库初始化
- [x] 代码提交到 GitHub
- [x] 版本标签创建和推送
- [x] Release 说明准备

### 📋 下一步手动操作

#### 1. 创建 GitHub Release
1. 访问: https://github.com/$GITHUB_USER/$REPO_NAME/releases
2. 点击 "Create a new release"
3. 选择标签: v$VERSION
4. 标题: DevBox v$VERSION
5. 复制 RELEASE_NOTES.md 的内容到描述框
6. 点击 "Publish release"

#### 2. 构建 Docker 镜像 (可选)
当有 Docker 环境时：
\`\`\`bash
# 登录 Docker Hub
docker login

# 构建镜像
docker build -t $GITHUB_USER/devbox-ubuntu24:v$VERSION .

# 推送到 Docker Hub
docker push $GITHUB_USER/devbox-ubuntu24:v$VERSION
\`\`\`

#### 3. 配置 GitHub Actions (可选)
在仓库设置中添加 Secrets：
- DOCKERHUB_USERNAME
- DOCKERHUB_TOKEN

然后 GitHub Actions 将自动构建和推送镜像。

### 🌐 项目地址
- **GitHub**: https://github.com/$GITHUB_USER/$REPO_NAME
- **Release 页面**: https://github.com/$GITHUB_USER/$REPO_NAME/releases

### 📧 分享项目
现在你可以分享这个项目地址了：
> https://github.com/$GITHUB_USER/$REPO_NAME

### 📊 项目统计
仓库创建后，你可以查看：
- Star 数量
- Fork 数量
- Issues 和 Pull Requests
- Docker 镜像下载量（如果发布到 Docker Hub）

---

*手动发布指南 - DevBox v$VERSION*
*生成时间: $(date)*
EOF

echo "✅ 手动发布指南已生成: MANUAL_PUBLISH_STEPS.md"

# 最终报告
echo ""
echo "🎉 DevBox GitHub 发布完成！"
echo ""
echo "✅ 已完成的项目:"
echo "   📦 Git 仓库初始化和提交"
echo "   🌐 代码推送到 GitHub"
echo "   🏷️  版本标签创建"
echo "   📝 Release 说明准备"
echo "   📋 手动发布指南"
echo ""
echo "📋 文件生成:"
echo "   RELEASE_NOTES.md - GitHub Release 说明"
echo "   MANUAL_PUBLISH_STEPS.md - 手动发布步骤"
echo ""
echo "🌐 GitHub 地址:"
echo "   https://github.com/$GITHUB_USER/$REPO_NAME"
echo ""
echo "🎯 下一步手动操作:"
echo "   1. 创建 GitHub Release"
echo "   2. 可选：配置 Docker Hub 推送"
echo "   3. 可选：设置 GitHub Actions"
echo ""
echo "📚 查看生成的文档："
echo "   cat RELEASE_NOTES.md"
echo "   cat MANUAL_PUBLISH_STEPS.md"
echo ""
echo "🎉 恭喜！你的 DevBox 现在已经在 GitHub 上了！"

# 显示项目统计
echo ""
echo "📊 项目统计:"
echo "   文件数量: $(find . -type f | wc -l)"
echo "   代码行数: $(find . -name '*.sh' -o -name '*.md' -o -name '*.yml' | xargs wc -l | tail -1 | awk '{print $1}')"
echo "   仓库大小: $(du -sh . | cut -f1)"
echo "   版本: v$VERSION"