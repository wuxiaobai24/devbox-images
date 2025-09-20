#!/bin/bash

# 简化版 DevBox 发布脚本 (不依赖 GitHub CLI)
echo "🚀 开始发布 DevBox (简化版)..."

set -e

# 配置
GITHUB_USER="wuxiaobai24"
REPO_NAME="devbox-images"
IMAGE_NAME="devbox-ubuntu24"
VERSION="1.0.0"

echo "📋 发布配置:"
echo "   GitHub 用户: $GITHUB_USER"
echo "   仓库名: $REPO_NAME"
echo "   镜像名: $IMAGE_NAME"
echo "   版本: $VERSION"
echo ""

# 检查 Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker 未安装，请先安装 Docker"
    echo "   Ubuntu: sudo apt install docker.io"
    echo "   或访问: https://docker.com/"
    exit 1
fi

echo "✅ Docker 已安装"

# 检查 Git 状态
if [ ! -d ".git" ]; then
    echo "❌ 不是 Git 仓库"
    exit 1
fi

echo "✅ Git 仓库已准备"

# 检查是否有远程仓库
remote_url=$(git remote get-url origin 2>/dev/null || echo "")
if [[ -z "$remote_url" ]]; then
    echo "🌐 没有远程仓库，请手动创建："
    echo ""
    echo "1. 访问: https://github.com/new"
    echo "2. 仓库名: $REPO_NAME"
    echo "3. 设置为 Public"
    echo "4. 创建后运行:"
    echo "   git remote add origin https://github.com/$GITHUB_USER/$REPO_NAME.git"
    echo "   git push -u origin main"
    echo ""
    read -p "按回车键继续，或 Ctrl+C 取消..."
else
    echo "✅ 远程仓库已配置: $remote_url"
fi

# 构建 Docker 镜像
echo ""
echo "🏗️  构建 Docker 镜像..."

if docker build -t $IMAGE_NAME:$VERSION -t $IMAGE_NAME:latest .; then
    echo "✅ Docker 镜像构建成功"
    echo "   镜像大小: $(docker images $IMAGE_NAME:$VERSION --format "{{.Size}}")"
else
    echo "❌ Docker 镜像构建失败"
    exit 1
fi

# 测试镜像
echo ""
echo "🧪 测试 Docker 镜像..."
test_container="devbox-test-$$"

if docker run -d --name "$test_container" -p 2223:22 $IMAGE_NAME:$VERSION; then
    echo "✅ 测试容器启动成功"
    sleep 5

    if docker exec "$test_container" pgrep sshd > /dev/null; then
        echo "✅ SSH 服务运行正常"
    fi

    if docker exec "$test_container" id devuser > /dev/null; then
        echo "✅ 开发用户存在"
    fi

    docker stop "$test_container" && docker rm "$test_container"
    echo "✅ 镜像测试完成"
else
    echo "❌ 测试容器启动失败"
    exit 1
fi

# Docker Hub 发布
echo ""
echo "📤 推送到 Docker Hub..."

if docker info | grep -q "Username"; then
    echo "✅ Docker 已登录"

    # 获取 Docker Hub 用户名
    docker_hub_user=$(docker info | grep Username | awk '{print $2}')

    if [ -n "$docker_hub_user" ]; then
        echo "📋 Docker Hub 用户: $docker_hub_user"

        # 标签和推送
        docker tag $IMAGE_NAME:$VERSION "$docker_hub_user/$IMAGE_NAME:$VERSION"
        docker tag $IMAGE_NAME:latest "$docker_hub_user/$IMAGE_NAME:latest"

        if docker push "$docker_hub_user/$IMAGE_NAME:$VERSION" && docker push "$docker_hub_user/$IMAGE_NAME:latest"; then
            echo "✅ 推送到 Docker Hub 成功"
            echo "   地址: https://hub.docker.com/r/$docker_hub_user/$IMAGE_NAME"
        else
            echo "❌ 推送到 Docker Hub 失败"
        fi
    else
        echo "❌ 无法获取 Docker Hub 用户名，请先登录: docker login"
    fi
else
    echo "⚠️  Docker 未登录，跳过 Docker Hub 推送"
    echo "   请运行: docker login"
fi

# 创建版本标签
echo ""
echo "🏷️  创建版本标签..."
if git tag "v$VERSION" 2>/dev/null; then
    echo "✅ Git 标签创建成功: v$VERSION"

    if [ -n "$remote_url" ]; then
        echo "📤 推送标签..."
        if git push origin "v$VERSION"; then
            echo "✅ 标签推送成功"
        else
            echo "⚠️  标签推送失败"
        fi
    fi
else
    echo "⚠️  标签可能已存在"
fi

# 生成使用说明
echo ""
echo "📋 生成使用说明..."

cat > "PUBLISH_SUCCESS.md" << EOF
# DevBox v$VERSION 发布成功！

## 🎉 发布信息
- **版本**: v$VERSION
- **发布时间**: $(date)
- **GitHub 用户**: $GITHUB_USER

## 📦 镜像信息

### Docker Hub
${docker_hub_user:+- **地址**: https://hub.docker.com/r/$docker_hub_user/$IMAGE_NAME}
${docker_hub_user:+- **拉取命令**: docker pull $docker_hub_user/$IMAGE_NAME:$VERSION}

### 本地使用
- **构建命令**: docker build -t $IMAGE_NAME:$VERSION .
- **运行命令**: docker run -d -p 2222:22 --name devbox $IMAGE_NAME:$VERSION
- **连接方式**: ssh devuser@localhost -p 2222
- **默认密码**: devuser

## 🚀 快速开始
\`\`\`bash
# 拉取镜像
${docker_hub_user:+docker pull $docker_hub_user/$IMAGE_NAME:$VERSION}

# 运行容器
docker run -d \\
  --name devbox \\
  -p 2222:22 \\
  -v ~/projects:/home/devuser/projects \\
  ${docker_hub_user:+$docker_hub_user/$IMAGE_NAME:$VERSION}

# 连接容器
ssh devuser@localhost -p 2222
\`\`\`

## 📋 容器功能
- Ubuntu 24.04 LTS
- SSH 服务 (端口 22)
- Node.js 20 + npm
- Python 3.11 + pip
- Claude Code CLI
- Claude Code Router (@musistudio)
- Happy 客户端 (@slopus)
- 现代化开发工具

## 🔧 连接后配置
\`\`\`bash
# 在容器内运行
./init-dev-env.sh

# 安装 AI 工具
sudo /usr/local/bin/install-ai-tools.sh

# Claude Code 认证
claude-code auth login
\`\`\`

---
*此发布由 DevBox 自动生成*
*发布时间: $(date)*
EOF

echo "✅ 使用说明已生成: PUBLISH_SUCCESS.md"

# 最终报告
echo ""
echo "🎉 DevBox 发布完成！"
echo ""
echo "📊 发布摘要:"
echo "   ✅ Git 提交完成"
echo "   ✅ Docker 镜像构建成功"
echo "   ✅ 镜像测试通过"
${docker_hub_user:+   ✅ Docker Hub 推送成功}
echo "   ✅ 版本标签创建"
echo ""
echo "📋 下一步:"
${remote_url:+   1. 推送代码到 GitHub: git push origin main}
${remote_url:+   2. 手动创建 GitHub Release}
${docker_hub_user:+   3. 测试镜像: docker run -d -p 2222:22 $docker_hub_user/$IMAGE_NAME:$VERSION}
echo "   4. 查看使用说明: cat PUBLISH_SUCCESS.md"
echo ""
echo "🌐 项目地址:"
${remote_url:+   - GitHub: $remote_url}
${docker_hub_user:+   - Docker Hub: https://hub.docker.com/r/$docker_hub_user/$IMAGE_NAME}
echo ""
echo "🎯 快速测试:"
${docker_hub_user:+   docker run -d -p 2222:22 $docker_hub_user/$IMAGE_NAME:$VERSION}
echo "   sleep 10 && ssh devuser@localhost -p 2222"