#!/bin/bash

echo "🔍 快速检查 Dockerfile..."
echo "================================"

# 检查 Dockerfile 是否存在
if [ ! -f "Dockerfile" ]; then
    echo "❌ Dockerfile 不存在"
    exit 1
fi

echo "✅ Dockerfile 存在"

# 检查基本语法
echo ""
echo "📋 检查基本指令:"

# FROM 指令
if grep -q "^FROM" Dockerfile; then
    echo "✅ FROM 指令: $(grep "^FROM" Dockerfile)"
else
    echo "❌ 缺少 FROM 指令"
fi

# WORKDIR 指令
if grep -q "^WORKDIR" Dockerfile; then
    echo "✅ WORKDIR 指令: $(grep "^WORKDIR" Dockerfile)"
else
    echo "⚠️  没有 WORKDIR 指令"
fi

# USER 指令
USER_COUNT=$(grep -c "^USER" Dockerfile)
echo "👤 USER 指令数量: $USER_COUNT"

# EXPOSE 指令
if grep -q "^EXPOSE" Dockerfile; then
    echo "✅ EXPOSE 指令: $(grep "^EXPOSE" Dockerfile)"
else
    echo "⚠️  没有 EXPOSE 指令"
fi

# CMD 指令
if grep -q "^CMD" Dockerfile; then
    echo "✅ CMD 指令: $(grep "^CMD" Dockerfile | head -1)"
else
    echo "❌ 缺少 CMD 指令"
fi

# 检查包管理
echo ""
echo "📦 检查包管理:"

if grep -q "apt-get" Dockerfile; then
    echo "✅ 使用 apt-get"
    APT_LINES=$(grep -c "apt-get" Dockerfile)
    echo "   - apt-get 指令数量: $APT_LINES"

    if grep -q "apt-get update" Dockerfile; then
        echo "   - 有更新操作"
    fi

    if grep -q "apt-get install" Dockerfile; then
        echo "   - 有安装操作"
    fi

    if grep -q "rm -rf /var/lib/apt/lists" Dockerfile; then
        echo "   - 清理缓存"
    else
        echo "   - ⚠️  建议清理 apt 缓存"
    fi
fi

# 检查 SSH 配置
echo ""
echo "🔐 检查 SSH 配置:"

if grep -q "openssh-server" Dockerfile; then
    echo "✅ 安装 openssh-server"
else
    echo "❌ 没有安装 openssh-server"
fi

if grep -q "ssh-keygen" Dockerfile; then
    echo "✅ 生成 SSH 密钥"
else
    echo "⚠️  建议生成 SSH 密钥"
fi

# 检查用户创建
echo ""
echo "👤 检查用户配置:"

if grep -q "useradd" Dockerfile; then
    echo "✅ 创建用户"
    USERNAME=$(grep "useradd" Dockerfile | grep -o "[a-zA-Z0-9_]*" | tail -1)
    echo "   - 用户名: $USERNAME"
else
    echo "⚠️  建议创建专用用户"
fi

# 检查 Node.js
if grep -q "nodejs\|npm" Dockerfile; then
    echo "✅ 安装 Node.js/npm"
else
    echo "⚠️  建议安装 Node.js"
fi

# 检查 Python
if grep -q "python3\|pip" Dockerfile; then
    echo "✅ 安装 Python/pip"
else
    echo "⚠️  建议安装 Python"
fi

# 检查 Claude Code CLI
if grep -q "claude-code" Dockerfile; then
    echo "✅ 安装 Claude Code CLI"
else
    echo "⚠️  建议安装 Claude Code CLI"
fi

# 检查潜在问题
echo ""
echo "⚠️  检查潜在问题:"

# 检查是否有复杂的脚本创建
if grep -q "cat.*<<'EOF'" Dockerfile; then
    echo "⚠️  发现 heredoc 语法，可能导致构建问题"
fi

if grep -q "printf.*\\\\n" Dockerfile; then
    echo "⚠️  发现复杂的 printf 语法，可能导致构建问题"
fi

# 检查 USER 指令逻辑
if [ $USER_COUNT -gt 1 ]; then
    echo "📊 多个 USER 指令，检查逻辑:"
    grep -n "^USER" Dockerfile
    echo "   ⚠️  确保 ssh-keygen 在 root 用户下运行"
    echo "   ⚠️  确保 sshd 在 root 用户下启动"
fi

echo ""
echo "🎯 构建命令:"
echo "   docker build -t devbox-test ."
echo ""
echo "🚀 运行命令:"
echo "   docker run -d -p 2222:22 --name devbox-test devbox-test"
echo ""
echo "🔌 连接命令:"
echo "   ssh devuser@localhost -p 2222"
echo "   # 密码: devuser"

echo ""
echo "✅ 快速检查完成！"