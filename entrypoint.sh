#!/bin/bash

set -e

# 初始化 SSH 主机密钥
if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
    ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N ''
fi

if [ ! -f /etc/ssh/ssh_host_ecdsa_key ]; then
    ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -N ''
fi

if [ ! -f /etc/ssh/ssh_host_ed25519_key ]; then
    ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ''
fi

# 确保 devuser 用户存在
if ! id devuser &>/dev/null; then
    useradd -m -s /bin/bash devuser
    echo "devuser:devuser" | chpasswd
    usermod -aG sudo devuser
    mkdir -p /home/devuser/.ssh
    chown -R devuser:devuser /home/devuser
fi

# 设置正确的权限
chmod 700 /home/devuser/.ssh
chmod 600 /home/devuser/.ssh/authorized_keys 2>/dev/null || true
chown devuser:devuser /home/devuser/.ssh/authorized_keys 2>/dev/null || true

# 创建项目目录
mkdir -p /home/devuser/projects
chown devuser:devuser /home/devuser/projects

# 初始化开发环境（如果还没有初始化）
if [ ! -f /home/devuser/.dev_env_initialized ]; then
    echo "首次启动，初始化开发环境..."
    sudo -u devuser /home/devuser/init-dev-env.sh || true
    touch /home/devuser/.dev_env_initialized
    echo "开发环境初始化完成"
fi

# 启动 SSH 服务
echo "启动 SSH 服务..."
/usr/sbin/sshd -D &

# 等待 SSH 服务启动
sleep 2

# 检查 SSH 服务状态
if pgrep sshd > /dev/null; then
    echo "SSH 服务已启动"
    echo "可以通过以下方式连接："
    echo "  SSH: ssh devuser@localhost -p 2222"
    echo "  密码: devuser"
else
    echo "SSH 服务启动失败"
    exit 1
fi

# 根据参数执行不同操作
case "$1" in
    "start")
        echo "DevBox 已启动，按 Ctrl+C 停止"
        # 保持容器运行
        tail -f /dev/null
        ;;
    "shell")
        echo "进入容器 shell..."
        exec /bin/bash
        ;;
    "dev")
        echo "进入开发环境..."
        exec sudo -u devuser /bin/bash
        ;;
    *)
        echo "未知命令: $1"
        echo "可用命令: start, shell, dev"
        exit 1
        ;;
esac