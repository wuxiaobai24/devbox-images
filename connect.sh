#!/bin/bash

# DevBox 连接脚本
echo "🔗 连接到 DevBox..."

# 检查容器是否运行
if ! docker-compose ps | grep -q "Up"; then
    echo "❌ DevBox 未运行，请先运行 ./start.sh"
    exit 1
fi

# 获取环境变量或使用默认值
DEV_USER=${DEV_USER:-devuser}
DEV_PASSWORD=${DEV_PASSWORD:-devuser}

# 连接方式选择
case "$1" in
    "ssh")
        echo "🔐 使用 SSH 连接..."
        echo "用户名: $DEV_USER"
        echo "密码: $DEV_PASSWORD"

        # 使用 sshpass 自动输入密码（如果安装了）
        if command -v sshpass &> /dev/null; then
            sshpass -p "$DEV_PASSWORD" ssh "$DEV_USER"@localhost -p 2222
        else
            ssh "$DEV_USER"@localhost -p 2222
        fi
        ;;
    "ssh-key")
        echo "🔐 使用 SSH 密钥连接..."
        ssh -i ./ssh/id_rsa "$DEV_USER"@localhost -p 2222
        ;;
    "dev")
        echo "👨‍💻 进入开发用户环境..."
        docker-compose exec devbox sudo -u "$DEV_USER" /bin/bash
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
                echo "用户名: $DEV_USER"
                echo "密码: $DEV_PASSWORD"

                # 使用 sshpass 自动输入密码（如果安装了）
                if command -v sshpass &> /dev/null; then
                    sshpass -p "$DEV_PASSWORD" ssh "$DEV_USER"@localhost -p 2222
                else
                    ssh "$DEV_USER"@localhost -p 2222
                fi
                ;;
            2)
                ssh -i ./ssh/id_rsa "$DEV_USER"@localhost -p 2222
                ;;
            3)
                docker-compose exec devbox sudo -u "$DEV_USER" /bin/bash
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