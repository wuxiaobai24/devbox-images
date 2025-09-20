#!/bin/bash

echo "🔍 验证 Dockerfile 语法和逻辑..."
echo "================================"

# 检查 Dockerfile 是否存在
if [ ! -f "Dockerfile" ]; then
    echo "❌ Dockerfile 不存在"
    exit 1
fi

echo "✅ Dockerfile 存在"

# 检查基础镜像
BASE_IMAGE=$(grep "^FROM" Dockerfile)
echo "📦 基础镜像: $BASE_IMAGE"

# 检查关键指令
echo ""
echo "🔧 检查关键指令:"

# 检查 FROM
if grep -q "^FROM" Dockerfile; then
    echo "✅ FROM 指令存在"
else
    echo "❌ 缺少 FROM 指令"
fi

# 检查 EXPOSE
if grep -q "^EXPOSE" Dockerfile; then
    echo "✅ EXPOSE 指令存在"
else
    echo "❌ 缺少 EXPOSE 指令"
fi

# 检查 CMD
if grep -q "^CMD" Dockerfile; then
    echo "✅ CMD 指令存在"
else
    echo "❌ 缺少 CMD 指令"
fi

# 检查 USER 指令
if grep -q "^USER" Dockerfile; then
    echo "✅ USER 指令存在"
else
    echo "⚠️  没有 USER 指令（将使用 root）"
fi

# 检查潜在问题
echo ""
echo "⚠️  检查潜在问题:"

# 检查是否有中文字符
if grep -q "[\u4e00-\u9fff]" Dockerfile; then
    echo "⚠️  发现中文字符，可能导致构建问题"
else
    echo "✅ 没有中文字符"
fi

# 检查复杂脚本创建
if grep -q "cat.*<<'EOF'" Dockerfile; then
    echo "⚠️  发现 heredoc 语法，可能导致构建问题"
else
    echo "✅ 没有 heredoc 语法"
fi

# 检查 USER 切换逻辑
USER_COUNT=$(grep -c "^USER" Dockerfile)
echo "📊 USER 指令数量: $USER_COUNT"

if [ $USER_COUNT -gt 1 ]; then
    echo "⚠️  多个 USER 指令，检查逻辑是否正确"
fi

# 检查包管理
if grep -q "apt-get" Dockerfile; then
    echo "✅ 使用 apt-get 包管理"
    if grep -q "rm -rf /var/lib/apt/lists/\*" Dockerfile; then
        echo "✅ 清理 apt 缓存"
    else
        echo "⚠️  建议清理 apt 缓存"
    fi
fi

echo ""
echo "📋 Dockerfile 摘要:"
echo "   - 基础镜像: $(grep "^FROM" Dockerfile | cut -d' ' -f2)"
echo "   - 暴露端口: $(grep "^EXPOSE" Dockerfile | cut -d' ' -f2)"
echo "   - 默认用户: $(tail -5 Dockerfile | grep "^USER" | tail -1 | cut -d' ' -f2 || echo "root")"
echo "   - 工作目录: $(grep "^WORKDIR" Dockerfile | tail -1 | cut -d' ' -f2)"

echo ""
echo "🎉 Dockerfile 验证完成！"
echo ""
echo "💡 建议:"
echo "   - 在有 Docker 环境中运行: docker build -t devbox-test ."
echo "   - 测试运行: docker run -d -p 2222:22 --name devbox-test devbox-test"
echo "   - 连接测试: ssh devuser@localhost -p 2222"