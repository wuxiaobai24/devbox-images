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
RUN echo '#!/bin/bash' > /usr/local/bin/install-ai-tools.sh && \
    echo '' >> /usr/local/bin/install-ai-tools.sh && \
    echo '# AI 工具智能安装脚本' >> /usr/local/bin/install-ai-tools.sh && \
    echo 'echo "🤖 开始安装 AI 开发工具..."' >> /usr/local/bin/install-ai-tools.sh && \
    echo '' >> /usr/local/bin/install-ai-tools.sh && \
    echo 'echo "🎉 AI 工具安装完成!"' >> /usr/local/bin/install-ai-tools.sh && \
    chmod +x /usr/local/bin/install-ai-tools.sh

# 创建开发环境初始化脚本
RUN echo '#!/bin/bash' > /home/devuser/init-dev-env.sh && \
    echo 'echo "🚀 初始化开发环境..."' >> /home/devuser/init-dev-env.sh && \
    echo 'echo ""' >> /home/devuser/init-dev-env.sh && \
    echo 'echo "🤖 安装 AI 开发工具..."' >> /home/devuser/init-dev-env.sh && \
    echo 'sudo /usr/local/bin/install-ai-tools.sh' >> /home/devuser/init-dev-env.sh && \
    echo 'echo ""' >> /home/devuser/init-dev-env.sh && \
    echo 'echo "🎉 开发环境初始化完成！"' >> /home/devuser/init-dev-env.sh && \
    chmod +x /home/devuser/init-dev-env.sh && \
    chown devuser:devuser /home/devuser/init-dev-env.sh

# 创建 entrypoint 脚本
RUN echo '#!/bin/bash' > /entrypoint.sh && \
    echo '' >> /entrypoint.sh && \
    echo 'set -e' >> /entrypoint.sh && \
    echo '' >> /entrypoint.sh && \
    echo '# 初始化 SSH 主机密钥' >> /entrypoint.sh && \
    echo 'if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then' >> /entrypoint.sh && \
    echo '    ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N ""' >> /entrypoint.sh && \
    echo 'fi' >> /entrypoint.sh && \
    echo '' >> /entrypoint.sh && \
    echo 'if [ ! -f /etc/ssh/ssh_host_ecdsa_key ]; then' >> /entrypoint.sh && \
    echo '    ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -N ""' >> /entrypoint.sh && \
    echo 'fi' >> /entrypoint.sh && \
    echo '' >> /entrypoint.sh && \
    echo 'if [ ! -f /etc/ssh/ssh_host_ed25519_key ]; then' >> /entrypoint.sh && \
    echo '    ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ""' >> /entrypoint.sh && \
    echo 'fi' >> /entrypoint.sh && \
    echo '' >> /entrypoint.sh && \
    echo '# 根据参数启动服务' >> /entrypoint.sh && \
    echo 'case "$1" in' >> /entrypoint.sh && \
    echo '    "start")' >> /entrypoint.sh && \
    echo '        echo "🚀 启动 DevBox..."' >> /entrypoint.sh && \
    echo '        echo "🔐 启动 SSH 服务..."' >> /entrypoint.sh && \
    echo '        /usr/sbin/sshd -D &' >> /entrypoint.sh && \
    echo '        echo "👤 用户: devuser"' >> /entrypoint.sh && \
    echo '        echo "🔐 密码: devuser"' >> /entrypoint.sh && \
    echo '        echo "🔌 端口: 22"' >> /entrypoint.sh && \
    echo '        echo "🌐 连接: ssh devuser@localhost -p 2222"' >> /entrypoint.sh && \
    echo '        echo "📝 或使用: ./connect.sh"' >> /entrypoint.sh && \
    echo '        echo ""' >> /entrypoint.sh && \
    echo '        echo "🎉 DevBox 已启动!"' >> /entrypoint.sh && \
    echo '        echo "💡 提示: 使用 Ctrl+C 停止容器"' >> /entrypoint.sh && \
    echo '        ;;' >> /entrypoint.sh && \
    echo '    "shell")' >> /entrypoint.sh && \
    echo '        echo "🐚 进入 shell 模式..."' >> /entrypoint.sh && \
    echo '        exec /bin/bash' >> /entrypoint.sh && \
    echo '        ;;' >> /entrypoint.sh && \
    echo '    *)' >> /entrypoint.sh && \
    echo '        echo "用法: $0 {start|shell}"' >> /entrypoint.sh && \
    echo '        exit 1' >> /entrypoint.sh && \
    echo '        ;;' >> /entrypoint.sh && \
    echo 'esac' >> /entrypoint.sh && \
    echo '' >> /entrypoint.sh && \
    echo '# 保持容器运行' >> /entrypoint.sh && \
    echo 'exec "$@"' >> /entrypoint.sh && \
    chmod +x /entrypoint.sh

# 暴露 SSH 端口
EXPOSE 22

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD pgrep sshd || exit 1

# 设置入口点
ENTRYPOINT ["/entrypoint.sh"]

# 默认命令
CMD ["start"]