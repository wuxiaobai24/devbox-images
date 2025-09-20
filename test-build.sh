#!/bin/bash

# Docker 镜像构建测试脚本
echo "🧪 开始测试 Docker 镜像构建..."

set -e

# 检查 Docker 是否可用
check_docker() {
    echo "🔍 检查 Docker 环境..."

    if ! command -v docker &> /dev/null; then
        echo "❌ Docker 未安装"
        echo "📋 安装 Docker 的方法："
        echo "   1. 官方脚本: curl -fsSL https://get.docker.com | sh"
        echo "   2. Ubuntu 包: sudo apt install docker.io"
        echo "   3. 手动安装: 参考 https://docs.docker.com/"
        return 1
    fi

    if ! docker info &> /dev/null; then
        echo "❌ Docker 服务未运行或权限不足"
        echo "📋 解决方案："
        echo "   - 启动 Docker: sudo systemctl start docker"
        echo "   - 添加用户到 docker 组: sudo usermod -aG docker \$USER"
        echo "   - 重新登录或运行: newgrp docker"
        return 1
    fi

    echo "✅ Docker 环境正常"
    echo "📋 Docker 版本信息:"
    docker --version
    docker info --format 'Docker Version: {{.ServerVersion}}'
    return 0
}

# 验证 Dockerfile 语法
validate_dockerfile() {
    echo ""
    echo "🔍 验证 Dockerfile 语法..."

    if [ ! -f "Dockerfile" ]; then
        echo "❌ Dockerfile 不存在"
        return 1
    fi

    # 基础语法检查
    echo "📋 Dockerfile 内容检查:"

    # 检查 FROM 指令
    if ! grep -q "^FROM" Dockerfile; then
        echo "❌ 缺少 FROM 指令"
        return 1
    fi

    # 检查基础镜像
    FROM_IMAGE=$(grep "^FROM" Dockerfile | head -1 | awk '{print $2}')
    echo "   基础镜像: $FROM_IMAGE"

    # 检查关键指令
    for cmd in RUN ENV WORKDIR COPY EXPOSE ENTRYPOINT CMD; do
        count=$(grep -c "^$cmd" Dockerfile || echo "0")
        echo "   $cmd 指令: $count 个"
    done

    # 检查潜在问题
    echo "🔍 检查潜在问题:"

    # 检查长命令行
    long_lines=$(grep -E '\\\\$' Dockerfile | wc -l)
    if [ "$long_lines" -gt 0 ]; then
        echo "   ⚠️  发现 $long_lines 个长命令行（使用 \\ 续行）"
    fi

    # 检查包管理器更新
    if ! grep -q "apt-get update" Dockerfile; then
        echo "   ⚠️  建议在安装包前运行 apt-get update"
    fi

    # 检查清理
    if ! grep -q "rm -rf.*var/lib/apt" Dockerfile; then
        echo "   ⚠️  建议清理 apt 缓存以减小镜像大小"
    fi

    echo "✅ Dockerfile 基础语法检查通过"
}

# 验证必要文件
validate_files() {
    echo ""
    echo "🔍 验证必要文件..."

    required_files=("docker-compose.yml" "entrypoint.sh" "install-ai-tools.sh")
    missing_files=()

    for file in "${required_files[@]}"; do
        if [ ! -f "$file" ]; then
            missing_files+=("$file")
        else
            echo "   ✅ $file"
        fi
    done

    if [ ${#missing_files[@]} -gt 0 ]; then
        echo "❌ 缺少必要文件:"
        for file in "${missing_files[@]}"; do
            echo "   - $file"
        done
        return 1
    fi

    echo "✅ 所有必要文件存在"
}

# 检查脚本权限
validate_permissions() {
    echo ""
    echo "🔍 检查文件权限..."

    scripts=("*.sh")
    for script in $scripts; do
        if [ -f "$script" ]; then
            if [ -x "$script" ]; then
                echo "   ✅ $script (可执行)"
            else
                echo "   ⚠️  $script (不可执行)"
                chmod +x "$script"
                echo "      已修复权限"
            fi
        fi
    done

    echo "✅ 文件权限检查完成"
}

# 模拟构建（测试语法）
simulate_build() {
    echo ""
    echo "🏗️  模拟构建测试..."

    # 检查是否有语法错误
    echo "🔍 检查 Dockerfile 语法错误..."

    # 使用 Docker 自己的语法检查（如果可用）
    if command -v docker &> /dev/null; then
        echo "📋 使用 Docker 检查语法..."
        if docker run --rm -i hadolint/hadolint < Dockerfile 2>/dev/null; then
            echo "✅ Hadolint 语法检查通过"
        else
            echo "⚠️  Hadolint 检查发现问题，但继续构建"
        fi
    else
        echo "⚠️  Docker 不可用，跳过语法检查"
    fi

    # 检查常见的语法问题
    echo "🔍 手动语法检查..."

    # 检查无效指令
    invalid_cmds=$(grep -v '^#' Dockerfile | grep -v '^$' | awk '{print $1}' | sort -u | grep -v -E '^(FROM|RUN|CMD|LABEL|EXPOSE|ENV|ADD|COPY|ENTRYPOINT|VOLUME|USER|WORKDIR|ARG|ONBUILD|STOPSIGNAL|HEALTHCHECK|SHELL)$' || true)
    if [ -n "$invalid_cmds" ]; then
        echo "   ⚠️  发现可能的无效指令: $invalid_cmds"
    fi

    # 检查引号匹配
    quote_errors=$(grep -o '"' Dockerfile | wc -l)
    if [ $((quote_errors % 2)) -ne 0 ]; then
        echo "   ⚠️  引号可能不匹配"
    fi

    echo "✅ 模拟构建检查完成"
}

# 创建构建报告
create_build_report() {
    echo ""
    echo "📋 创建构建报告..."

    report_file="build-report-$(date +%Y%m%d-%H%M%S).txt"

    cat > "$report_file" << EOF
DevBox Docker 构建测试报告
==========================

测试时间: $(date)
测试环境: $(uname -a)

Docker 状态:
- Docker 可用: $(command -v docker &> /dev/null && echo "是" || echo "否")
- Docker 运行: $(docker info &> /dev/null 2>&1 && echo "是" || echo "否")

文件检查:
- Dockerfile: $([ -f Dockerfile ] && echo "存在" || echo "不存在")
- docker-compose.yml: $([ -f docker-compose.yml ] && echo "存在" || echo "不存在")
- entrypoint.sh: $([ -f entrypoint.sh ] && echo "存在" || echo "不存在")
- install-ai-tools.sh: $([ -f install-ai-tools.sh ] && echo "存在" || echo "不存在")

Dockerfile 分析:
- 基础镜像: $(grep "^FROM" Dockerfile | head -1 | awk '{print $2}')
- RUN 指令数: $(grep -c "^RUN" Dockerfile)
- COPY 指令数: $(grep -c "^COPY" Dockerfile)
- EXPOSE 端口: $(grep "^EXPOSE" Dockerfile | awk '{print $2}' | tr '\n' ', ')

项目信息:
- Claude Code Router: @musistudio/claude-code-router
- Happy: @slopus/happy (Claude Code Mobile/Web Client)
- 基础系统: Ubuntu 24.04 LTS

预计镜像大小: ~2-4GB (包含所有开发工具)
预计构建时间: 10-30分钟 (取决于网络速度)

下一步:
1. 安装 Docker: curl -fsSL https://get.docker.com | sh
2. 构建镜像: docker build -t devbox-ubuntu24 .
3. 启动容器: docker run -d -p 2222:22 --name devbox devbox-ubuntu24
EOF

    echo "✅ 构建报告已创建: $report_file"
    echo ""
    echo "📊 报告摘要:"
    cat "$report_file" | grep -E "^(Docker 状态|文件检查|基础镜像|预计)"
}

# 主函数
main() {
    echo "🚀 DevBox Docker 镜像构建测试"
    echo "================================="

    # 检查 Docker
    if ! check_docker; then
        echo ""
        echo "🔧 将继续进行文件验证和语法检查..."
    fi

    # 验证文件
    validate_dockerfile
    validate_files
    validate_permissions

    # 模拟构建
    simulate_build

    # 创建报告
    create_build_report

    echo ""
    echo "🎉 测试完成！"
    echo ""
    echo "📝 在有 Docker 的系统上，请运行："
    echo "   docker build -t devbox-ubuntu24 ."
    echo "   docker run -d -p 2222:22 --name devbox devbox-ubuntu24"
    echo ""
    echo "📋 或使用便捷脚本："
    echo "   ./start.sh"
}

# 运行主函数
main "$@"