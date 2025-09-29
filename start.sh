#!/bin/bash

# DevBox 启动脚本
echo "🚀 启动 DevBox 开发环境..."

# 检查 docker 和 docker-compose 是否安装
if ! command -v docker &> /dev/null; then
    echo "❌ Docker 未安装，请先安装 Docker"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose 未安装，请先安装 Docker Compose"
    exit 1
fi

# 获取环境变量或使用默认值
DEV_USER=${DEV_USER:-devuser}
DEV_PASSWORD=${DEV_PASSWORD:-devuser}

echo "📋 配置信息："
echo "   用户名: $DEV_USER"
echo "   密码: $DEV_PASSWORD"
echo ""

# 检查 SSH 密钥配置
if [ ! -f "./ssh/id_rsa" ] || [ ! -f "./ssh/id_rsa.pub" ]; then
    echo "🔑 配置 SSH 密钥..."
    mkdir -p ssh
    chmod 700 ssh

    # 生成 SSH 密钥对
    ssh-keygen -t rsa -b 4096 -f "./ssh/id_rsa" -N "" -C "$DEV_USER@devbox"

    # 复制到 authorized_keys
    cp ./ssh/id_rsa.pub ./ssh/authorized_keys
    chmod 600 ./ssh/authorized_keys

    echo "✅ SSH 密钥已生成"
else
    echo "✅ SSH 密钥已存在"
fi

# 构建并启动容器
echo "🏗️  构建 Docker 镜像..."
DEV_USER="$DEV_USER" DEV_PASSWORD="$DEV_PASSWORD" docker-compose build --no-cache

echo "🔄 启动容器..."
DEV_USER="$DEV_USER" DEV_PASSWORD="$DEV_PASSWORD" docker-compose up -d

# 等待容器启动
echo "⏳ 等待容器启动..."
sleep 10

# 检查容器状态
if docker-compose ps | grep -q "Up"; then
    echo "✅ DevBox 启动成功！"
    echo ""
    echo "📋 连接信息："
    echo "   SSH 端口: 2222"
    echo "   用户名: $DEV_USER"
    echo "   密码: $DEV_PASSWORD"
    echo ""
    echo "🔗 连接方式："
    echo "   SSH: ssh $DEV_USER@localhost -p 2222"
    echo "   或: ssh -i ssh/id_rsa $DEV_USER@localhost -p 2222"
    echo ""
    echo "🛠️  容器管理："
    echo "   查看状态: docker-compose ps"
    echo "   查看日志: docker-compose logs"
    echo "   停止容器: docker-compose down"
    echo "   进入容器: docker-compose exec devbox /bin/bash"
    echo "   进入开发环境: docker-compose exec devbox sudo -u $DEV_USER /bin/bash"
else
    echo "❌ DevBox 启动失败，请检查日志："
    docker-compose logs
    exit 1
fi

echo ""
echo "🎉 DevBox 开发环境已就绪！"