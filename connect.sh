#!/bin/bash

# DevBox 连接脚本
echo "🔗 连接到 DevBox..."

# 检查容器是否运行
if ! docker-compose ps | grep -q "Up"; then
    echo "❌ DevBox 未运行，请先运行 ./start.sh"
    exit 1
fi

# 连接方式选择
case "$1" in
    "ssh")
        echo "🔐 使用 SSH 连接..."
        ssh devuser@localhost -p 2222
        ;;
    "ssh-key")
        echo "🔐 使用 SSH 密钥连接..."
        ssh -i ./ssh/id_rsa devuser@localhost -p 2222
        ;;
    "dev")
        echo "👨‍💻 进入开发用户环境..."
        docker-compose exec devbox sudo -u devuser /bin/bash
        ;;
    "root")
        echo "🔒 进入 root 环境..."
        docker-compose exec devbox /bin/bash
        ;;
    *)
        echo "请选择连接方式："
        echo "  1) SSH 连接（密码）"
        echo "  2) SSH 连接（密钥）"
        echo "  3) 开发用户环境"
        echo "  4) Root 环境"
        echo ""
        read -p "请输入选择 (1-4): " choice

        case $choice in
            1)
                ssh devuser@localhost -p 2222
                ;;
            2)
                ssh -i ./ssh/id_rsa devuser@localhost -p 2222
                ;;
            3)
                docker-compose exec devbox sudo -u devuser /bin/bash
                ;;
            4)
                docker-compose exec devbox /bin/bash
                ;;
            *)
                echo "❌ 无效选择"
                exit 1
                ;;
        esac
        ;;
esac