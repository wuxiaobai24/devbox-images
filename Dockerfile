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
RUN npm install -g @anthropic-ai/claude-code || echo "Claude Code CLI installation failed"

# 确保 Claude Code CLI 在 PATH 中
ENV PATH=$PATH:/home/devuser/.local/bin

# Python 工具已通过系统包安装，无需额外包

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

# 创建简单的 entrypoint 脚本
RUN echo '#!/bin/bash' > /entrypoint.sh && \
    echo 'set -e' >> /entrypoint.sh && \
    echo '' >> /entrypoint.sh && \
    echo '# 初始化 SSH 主机密钥' >> /entrypoint.sh && \
    echo 'if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then' >> /entrypoint.sh && \
    echo '    ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N ""' >> /entrypoint.sh && \
    echo 'fi' >> /entrypoint.sh && \
    echo '' >> /entrypoint.sh && \
    echo '# 启动 SSH 服务' >> /entrypoint.sh && \
    echo 'echo "Starting SSH service..."' >> /entrypoint.sh && \
    echo '/usr/sbin/sshd -D' >> /entrypoint.sh && \
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