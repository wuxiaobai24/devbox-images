#!/bin/bash

# DevBox GitHub 发布脚本
echo "🚀 准备发布 DevBox 到 GitHub..."

set -e

# 配置变量
REPO_NAME="devbox-images"
GITHUB_USER="${GITHUB_USER:-$(git config user.name)}"
IMAGE_NAME="devbox-ubuntu24"
VERSION="1.0.0"

echo "📋 发布配置:"
echo "   仓库名: $REPO_NAME"
echo "   GitHub 用户: $GITHUB_USER"
echo "   镜像名: $IMAGE_NAME"
echo "   版本: $VERSION"
echo ""

# 检查必要工具
check_prerequisites() {
    echo "🔍 检查必要工具..."

    missing_tools=()

    if ! command -v git &> /dev/null; then
        missing_tools+=("git")
    fi

    if ! command -v docker &> /dev/null; then
        missing_tools+=("docker")
    fi

    if ! command -v gh &> /dev/null; then
        missing_tools+=("gh (GitHub CLI)")
    fi

    if [ ${#missing_tools[@]} -gt 0 ]; then
        echo "❌ 缺少必要工具:"
        for tool in "${missing_tools[@]}"; do
            echo "   - $tool"
        done
        echo ""
        echo "📦 安装命令:"
        echo "   Ubuntu/Debian: sudo apt install git docker.io gh"
        echo "   macOS: brew install git docker gh"
        exit 1
    fi

    echo "✅ 所有工具已安装"
}

# 检查 Git 状态
check_git_status() {
    echo ""
    echo "🔍 检查 Git 状态..."

    if [ ! -d ".git" ]; then
        echo "❌ 当前目录不是 Git 仓库"
        echo "📋 初始化 Git 仓库:"
        echo "   git init"
        echo "   git add ."
        echo "   git commit -m 'Initial commit: DevBox Ubuntu 24.04'"
        exit 1
    fi

    # 检查是否有未提交的更改
    if ! git diff-index --quiet HEAD --; then
        echo "⚠️  发现未提交的更改:"
        git status --porcelain
        echo ""
        read -p "是否提交所有更改? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            git add .
            git commit -m "准备发布 DevBox v$VERSION"
            echo "✅ 更改已提交"
        else
            echo "❌ 请先提交所有更改再发布"
            exit 1
        fi
    fi

    echo "✅ Git 状态正常"
}

# 创建 GitHub 仓库
create_github_repo() {
    echo ""
    echo "🌐 创建 GitHub 仓库..."

    # 检查是否已连接 GitHub
    if ! gh auth status &> /dev/null; then
        echo "🔑 需要 GitHub 认证..."
        gh auth login
    fi

    # 检查远程仓库是否已存在
    remote_url=$(git remote get-url origin 2>/dev/null || echo "")
    if [[ -n "$remote_url" && "$remote_url" =~ github\.com ]]; then
        echo "✅ GitHub 远程仓库已存在: $remote_url"
        return 0
    fi

    # 创建新仓库
    echo "📦 创建新仓库: $GITHUB_USER/$REPO_NAME"

    if gh repo create "$GITHUB_USER/$REPO_NAME" --public --source=. --remote=origin --push; then
        echo "✅ GitHub 仓库创建成功"
        echo "   URL: https://github.com/$GITHUB_USER/$REPO_NAME"
    else
        echo "⚠️  仓库创建失败，可能已存在"
        # 尝试手动添加远程
        git remote add origin "https://github.com/$GITHUB_USER/$REPO_NAME.git"
        git push -u origin main
    fi
}

# 构建 Docker 镜像
build_docker_image() {
    echo ""
    echo "🏗️  构建 Docker 镜像..."

    # 标签镜像
    local tags="$IMAGE_NAME:$VERSION $IMAGE_NAME:latest"

    echo "📋 构建标签: $tags"

    # 构建镜像
    if docker build -t $IMAGE_NAME:$VERSION -t $IMAGE_NAME:latest .; then
        echo "✅ Docker 镜像构建成功"
        docker images | grep "$IMAGE_NAME"
    else
        echo "❌ Docker 镜像构建失败"
        exit 1
    fi
}

# 测试镜像
test_docker_image() {
    echo ""
    echo "🧪 测试 Docker 镜像..."

    # 创建测试容器
    local test_container="devbox-test-$$"

    echo "🔬 启动测试容器..."
    if docker run -d --name "$test_container" -p 2223:22 $IMAGE_NAME:$VERSION; then
        echo "✅ 测试容器启动成功"

        # 等待容器启动
        echo "⏳ 等待容器启动..."
        sleep 10

        # 检查 SSH 服务
        if docker exec "$test_container" pgrep sshd > /dev/null; then
            echo "✅ SSH 服务运行正常"
        else
            echo "⚠️  SSH 服务可能未启动"
        fi

        # 检查用户
        if docker exec "$test_container" id devuser > /dev/null; then
            echo "✅ 开发用户存在"
        else
            echo "❌ 开发用户不存在"
        fi

        # 清理测试容器
        echo "🧹 清理测试容器..."
        docker stop "$test_container" && docker rm "$test_container"
        echo "✅ 镜像测试完成"
    else
        echo "❌ 测试容器启动失败"
        exit 1
    fi
}

# 推送到 Docker Hub
push_to_docker_hub() {
    echo ""
    echo "📤 推送到镜像仓库..."

    # 检查 Docker 登录状态
    if ! docker info | grep -q "Username"; then
        echo "🔑 需要 Docker Hub 认证..."
        echo "请运行: docker login"
        exit 1
    fi

    # 推送到 Docker Hub
    local docker_hub_user="${DOCKER_HUB_USER:-$(docker info | grep Username | awk '{print $2}')}"

    if [ -z "$docker_hub_user" ]; then
        echo "❌ 无法获取 Docker Hub 用户名"
        echo "请运行: docker login"
        exit 1
    fi

    echo "📋 推送到 $docker_hub_user/$IMAGE_NAME"

    # 重新标签镜像
    docker tag $IMAGE_NAME:$VERSION "$docker_hub_user/$IMAGE_NAME:$VERSION"
    docker tag $IMAGE_NAME:latest "$docker_hub_user/$IMAGE_NAME:latest"

    # 推送镜像
    if docker push "$docker_hub_user/$IMAGE_NAME:$VERSION" && docker push "$docker_hub_user/$IMAGE_NAME:latest"; then
        echo "✅ 镜像推送成功"
        echo "   Docker Hub: https://hub.docker.com/r/$docker_hub_user/$IMAGE_NAME"
    else
        echo "❌ 镜像推送失败"
        exit 1
    fi
}

# 推送到 GitHub Container Registry
push_to_ghcr() {
    echo ""
    echo "📤 推送到 GitHub Container Registry..."

    # 检查 GitHub 认证
    if ! gh auth status &> /dev/null; then
        echo "❌ GitHub 未认证"
        exit 1
    fi

    # 登录到 GHCR
    echo "🔑 登录到 GitHub Container Registry..."
    echo "$GITHUB_TOKEN" | docker login ghcr.io -u "$GITHUB_USER" --password-stdin

    # GHCR 镜像名称
    local ghcr_image="ghcr.io/$GITHUB_USER/$REPO_NAME/$IMAGE_NAME"

    # 重新标签镜像
    docker tag $IMAGE_NAME:$VERSION "$ghcr_image:$VERSION"
    docker tag $IMAGE_NAME:latest "$ghcr_image:latest"

    # 推送镜像
    echo "📋 推送到 $ghcr_image"
    if docker push "$ghcr_image:$VERSION" && docker push "$ghcr_image:latest"; then
        echo "✅ GHCR 推送成功"
        echo "   GHCR: $ghcr_image"
    else
        echo "❌ GHCR 推送失败"
        exit 1
    fi
}

# 创建 GitHub Release
create_github_release() {
    echo ""
    echo "📦 创建 GitHub Release..."

    # 创建发布说明
    local release_notes="DevBox v$VERSION

## 功能特性
- Ubuntu 24.04 LTS 开发环境
- SSH 访问支持 (端口 2222)
- Claude Code CLI 预装
- Claude Code Router (@musistudio) 支持
- Happy (@slopus) Claude Code 客户端
- Node.js 20 + Python 3.11
- 现代化开发工具集

## 快速开始
\`\`\`bash
docker run -d -p 2222:22 --name devbox $GITHUB_USER/$REPO_NAME/$IMAGE_NAME:v$VERSION
ssh devuser@localhost -p 2222
# 密码: devuser
\`\`\`

## 详细文档
- 项目主页: https://github.com/$GITHUB_USER/$REPO_NAME
- Docker Hub: https://hub.docker.com/r/$GITHUB_USER/$IMAGE_NAME
- GHCR: ghcr.io/$GITHUB_USER/$REPO_NAME/$IMAGE_NAME

---
此版本由 DevBox 发布脚本自动生成"

    # 创建 Release
    if gh release create "v$VERSION" \
        --title "DevBox v$VERSION" \
        --notes "$release_notes" \
        --target main; then
        echo "✅ GitHub Release 创建成功"
        echo "   Release URL: https://github.com/$GITHUB_USER/$REPO_NAME/releases/tag/v$VERSION"
    else
        echo "⚠️  Release 创建可能失败"
    fi
}

# 更新 README
update_readme() {
    echo ""
    echo "📝 更新 README..."

    # 备份原 README
    cp README.md README.md.backup

    # 添加下载徽章
    cat > README.md.new << 'EOF'
# DevBox - Ubuntu 24.04 开发环境 Docker 镜像

[![Docker Pulls](https://img.shields.io/docker/pulls/USERNAME/devbox-ubuntu24.svg)](https://hub.docker.com/r/USERNAME/devbox-ubuntu24)
[![GitHub Release](https://img.shields.io/github/v/release/USERNAME/devbox-images.svg)](https://github.com/USERNAME/devbox-images/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

EOF

    # 替换占位符
    sed "s/USERNAME/$GITHUB_USER/g" README.md.new > README.md.temp

    # 追加原 README 内容
    tail -n +2 README.md >> README.md.temp

    # 更新文件
    mv README.md.temp README.md

    # 提交更改
    git add README.md
    git commit -m "更新 README: 添加下载徽章和发布信息"
    git push origin main

    echo "✅ README 更新完成"

    # 清理临时文件
    rm -f README.md.new README.md.temp README.md.backup
}

# 生成发布报告
generate_report() {
    echo ""
    echo "📊 生成发布报告..."

    local report_file="publish-report-$(date +%Y%m%d-%H%M%S).txt"

    cat > "$report_file" << EOF
DevBox 发布报告
===============

发布时间: $(date)
发布版本: v$VERSION
GitHub 用户: $GITHUB_USER

镜像信息:
- 名称: $IMAGE_NAME
- 版本: $VERSION
- 大小: $(docker images $IMAGE_NAME:$VERSION --format "table {{.Size}}")

发布地址:
- GitHub: https://github.com/$GITHUB_USER/$REPO_NAME
- Docker Hub: https://hub.docker.com/r/$GITHUB_USER/$IMAGE_NAME
- GHCR: ghcr.io/$GITHUB_USER/$REPO_NAME/$IMAGE_NAME

发布状态:
- ✅ 代码已推送到 GitHub
- ✅ Docker 镜像已构建
- ✅ 镜像已测试
- ✅ 镜像已推送到 Docker Hub
- ✅ 镜像已推送到 GHCR
- ✅ GitHub Release 已创建

使用方法:
1. 拉取镜像:
   docker pull $GITHUB_USER/$IMAGE_NAME:$VERSION

2. 运行容器:
   docker run -d -p 2222:22 --name devbox $GITHUB_USER/$IMAGE_NAME:$VERSION

3. 连接容器:
   ssh devuser@localhost -p 2222
   # 密码: devuser

---
此报告由 DevBox 发布脚本自动生成
EOF

    echo "✅ 发布报告已生成: $report_file"
    echo ""
    echo "📊 发布摘要:"
    cat "$report_file" | grep -E "^(发布时间|GitHub 用户|镜像信息|发布地址)"
}

# 主函数
main() {
    echo "🚀 DevBox GitHub 发布流程"
    echo "================================="

    # 检查环境
    check_prerequisites
    check_git_status

    # 创建仓库
    create_github_repo

    # 构建和测试镜像
    build_docker_image
    test_docker_image

    # 推送到镜像仓库
    push_to_docker_hub
    push_to_ghcr

    # 创建 GitHub Release
    create_github_release

    # 更新文档
    update_readme

    # 生成报告
    generate_report

    echo ""
    echo "🎉 DevBox 发布完成！"
    echo ""
    echo "🌐 项目地址:"
    echo "   GitHub: https://github.com/$GITHUB_USER/$REPO_NAME"
    echo "   Docker Hub: https://hub.docker.com/r/$GITHUB_USER/$IMAGE_NAME"
    echo "   GHCR: ghcr.io/$GITHUB_USER/$REPO_NAME/$IMAGE_NAME"
    echo ""
    echo "📦 快速使用:"
    echo "   docker run -d -p 2222:22 --name devbox $GITHUB_USER/$IMAGE_NAME:$VERSION"
    echo "   ssh devuser@localhost -p 2222"
}

# 运行主函数
main "$@"