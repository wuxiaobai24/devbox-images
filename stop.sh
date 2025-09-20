#!/bin/bash

# DevBox 停止脚本
echo "🛑 停止 DevBox 开发环境..."

# 停止容器
if docker-compose ps | grep -q "Up"; then
    echo "🔄 停止容器..."
    docker-compose down
    echo "✅ DevBox 已停止"
else
    echo "ℹ️  DevBox 未运行"
fi

# 可选：清理未使用的镜像和卷
if [ "$1" = "--clean" ]; then
    echo "🧹 清理未使用的资源..."
    docker system prune -f
    echo "✅ 清理完成"
fi