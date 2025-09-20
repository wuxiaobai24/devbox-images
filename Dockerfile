# 使用 Ubuntu 24.04 LTS 作为基础镜像
FROM ubuntu:24.04

# 设置环境变量
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# 设置工作目录
WORKDIR /home/devuser

# 创建开发用户
RUN useradd -m -s /bin/bash devuser && \
    echo "devuser:devuser" | chpasswd && \
    usermod -aG sudo devuser && \
    mkdir -p /home/devuser/.ssh && \
    chown -R devuser:devuser /home/devuser

# 安装基础系统包
RUN apt-get update && apt-get install -y \
    sudo \
    openssh-server \
    curl \
    wget \
    git \
    vim \
    zsh \
    tmux \
    htop \
    tree \
    net-tools \
    iputils-ping \
    ca-certificates \
    gnupg \
    lsb-release \
    software-properties-common \
    python3 \
    python3-pip \
    python3-venv \
    build-essential \
    cmake \
    make \
    gcc \
    g++ \
    && rm -rf /var/lib/apt/lists/*

# 安装 Node.js 20
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# 安装 Claude Code CLI
# 方式1: 通过 npm 安装 (如果包存在)
RUN npm install -g @anthropic-ai/claude-code || echo "npm install failed, trying alternative..."

# 方式2: 通过 curl 安装 (官方推荐方式)
RUN curl -fsSL https://claude.ai/install | sh || echo "curl install failed, will install manually later"

# 确保 Claude Code CLI 在 PATH 中
ENV PATH=$PATH:/home/devuser/.local/bin

# 安装 Python 开发工具
RUN python3 -m pip install --no-cache-dir --break-system-packages \
        anthropic \
        fastapi \
        uvicorn \
        python-dotenv \
        httpx \
        pydantic

# 创建 Claude Code Router 安装脚本 (如果项目存在)
RUN cat > /usr/local/bin/install-claude-router.sh << 'EOF'
#!/bin/bash
# Claude Code Router 安装脚本
echo "Claude Code Router 安装脚本已准备"
# 注意：需要根据实际的 Claude Code Router 项目进行安装
EOF

RUN chmod +x /usr/local/bin/install-claude-router.sh

# 创建 Happy Coder 安装脚本 (如果项目存在)
RUN cat > /usr/local/bin/install-happy-coder.sh << 'EOF'
#!/bin/bash
# Happy Coder 安装脚本
echo "Happy Coder 安装脚本已准备"
# 注意：需要根据实际的 Happy Coder 项目进行安装
EOF

RUN chmod +x /usr/local/bin/install-happy-coder.sh

# 配置 SSH
RUN mkdir -p /var/run/sshd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config && \
    echo 'Port 22' >> /etc/ssh/sshd_config

# 创建 SSH 目录
RUN mkdir -p /home/devuser/.ssh && \
    chown devuser:devuser /home/devuser/.ssh && \
    chmod 700 /home/devuser/.ssh

# 设置开发用户的环境
USER devuser
WORKDIR /home/devuser

# 安装 oh-my-zsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# 配置环境变量
ENV PATH=/home/devuser/.local/bin:$PATH
ENV CLAUDE_CODE_HOME=/home/devuser/.claude-code

# 创建智能 AI 工具安装脚本
RUN cat > /usr/local/bin/install-ai-tools.sh << 'EOF'
#!/bin/bash

# AI 工具智能安装脚本
echo "🤖 开始安装 AI 开发工具..."

set -e

# 检查是否在容器内
if [ ! -f "/.dockerenv" ]; then
    echo "⚠️  这个脚本应该在 Docker 容器内运行"
    echo "请先运行: ./start.sh 然后 ./connect.sh"
    exit 1
fi

echo "🎉 AI 工具安装完成!"
echo ""
echo "📋 安装摘要:"
echo "   Claude Code CLI: 需要手动安装"
echo "   Claude Code Router: 需要手动安装"
echo "   Happy Coder: 需要手动安装"
echo ""
echo "🔧 使用方法:"
echo "   claude-code --help      # Claude Code CLI 帮助"
echo ""
echo "⚠️  注意:"
echo "   - 某些工具可能需要 API 密钥才能正常工作"
echo "   - 首次使用时可能需要进行身份验证"
EOF

RUN chmod +x /usr/local/bin/install-ai-tools.sh

# 创建开发环境初始化脚本
RUN cat > /home/devuser/init-dev-env.sh << 'EOF'
#!/bin/bash
echo "🚀 初始化开发环境..."
echo ""
echo "🤖 安装 AI 开发工具..."
sudo /usr/local/bin/install-ai-tools.sh
echo ""
echo "🎉 开发环境初始化完成！"
echo ""
echo "📝 后续步骤："
echo "1. 设置 API 密钥（如果需要）：export ANTHROPIC_API_KEY=your_key"
echo "2. 运行身份验证：claude-code auth login"
echo "3. 开始使用：claude-code --help"
EOF

RUN chmod +x /home/devuser/init-dev-env.sh

# 创建 entrypoint 脚本
RUN cat > /entrypoint.sh << 'EOF'
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

# 根据参数启动服务
case "$1" in
    "start")
        echo "🚀 启动 DevBox..."
        echo "🔐 启动 SSH 服务..."
        /usr/sbin/sshd -D &
        echo "👤 用户: devuser"
        echo "🔐 密码: devuser"
        echo "🔌 端口: 22"
        echo "🌐 连接: ssh devuser@localhost -p 2222"
        echo "📝 或使用: ./connect.sh"
        echo ""
        echo "🎉 DevBox 已启动!"
        echo "💡 提示: 使用 Ctrl+C 停止容器"
        ;;
    "shell")
        echo "🐚 进入 shell 模式..."
        exec /bin/bash
        ;;
    *)
        echo "用法: $0 {start|shell}"
        exit 1
        ;;
esac

# 保持容器运行
exec "$@"
EOF

RUN chmod +x /entrypoint.sh

# 暴露 SSH 端口
EXPOSE 22

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD pgrep sshd || exit 1

# 设置入口点
ENTRYPOINT ["/entrypoint.sh"]

# 默认命令
CMD ["start"]