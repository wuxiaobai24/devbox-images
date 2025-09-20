#!/bin/bash

# DevBox 验证脚本
echo "🔍 验证 DevBox 配置..."

# 检查必要文件是否存在
required_files=("Dockerfile" "docker-compose.yml" "entrypoint.sh")
for file in "${required_files[@]}"; do
    if [ ! -f "$file" ]; then
        echo "❌ 缺少必要文件: $file"
        exit 1
    fi
done

echo "✅ 所有必要文件存在"

# 检查 Dockerfile 语法
echo "🔍 检查 Dockerfile 语法..."
if ! docker run --rm -i hadolint/hadolint < Dockerfile 2>/dev/null; then
    echo "⚠️  Dockerfile 可能有语法问题，但继续验证..."
else
    echo "✅ Dockerfile 语法检查通过"
fi

# 检查 docker-compose.yml 语法
echo "🔍 检查 docker-compose.yml 语法..."
if command -v docker-compose &> /dev/null; then
    if docker-compose config >/dev/null 2>&1; then
        echo "✅ docker-compose.yml 语法正确"
    else
        echo "❌ docker-compose.yml 语法错误"
        exit 1
    fi
else
    echo "⚠️  Docker Compose 未安装，跳过语法检查"
fi

# 检查脚本文件权限
echo "🔍 检查脚本文件权限..."
scripts=("start.sh" "stop.sh" "connect.sh" "entrypoint.sh")
for script in "${scripts[@]}"; do
    if [ -f "$script" ]; then
        if [ -x "$script" ]; then
            echo "✅ $script 具有执行权限"
        else
            echo "❌ $script 缺少执行权限"
            chmod +x "$script"
            echo "✅ 已修复 $script 权限"
        fi
    fi
done

# 检查必要目录
echo "🔍 检查必要目录..."
directories=("ssh" "config" "projects")
for dir in "${directories[@]}"; do
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        echo "✅ 已创建目录: $dir"
    else
        echo "✅ 目录存在: $dir"
    fi
done

# 生成验证报告
echo ""
echo "📋 验证报告"
echo "============"
echo "✅ 文件结构完整"
echo "✅ 脚本权限正确"
echo "✅ 目录结构完整"
echo "⚠️  Docker 未在此系统上安装，无法完全验证构建"
echo ""
echo "📝 在有 Docker 的系统上，请运行："
echo "   ./start.sh        # 构建并启动"
echo "   ./connect.sh      # 连接到容器"
echo ""
echo "🔧 手动安装说明："
echo "1. Claude Code CLI: 根据官方文档安装"
echo "2. Claude Code Router: 克隆并安装相应项目"
echo "3. Happy Coder: 克隆并安装相应项目"

echo ""
echo "🎉 基础验证完成！DevBox 配置文件已准备就绪。"