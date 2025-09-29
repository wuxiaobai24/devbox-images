# 使用 Ubuntu 24.04 LTS 作为基础镜像
FROM ubuntu:24.04

# 设置环境变量
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV DEV_USER=${DEV_USER:-devuser}
ENV DEV_PASSWORD=${DEV_PASSWORD:-devuser}

# 设置工作目录
WORKDIR /tmp

# 创建默认用户（会被 entrypoint.sh 重新配置）
RUN useradd -m -s /bin/bash devuser && \
    echo "devuser:devuser" | chpasswd && \
    usermod -aG sudo devuser && \
    mkdir -p /home/devuser/.ssh && \
    chown -R devuser:devuser /home/devuser

# 安装基础系统包和增强开发工具
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
    # 增强开发工具
    ninja-build \
    pkg-config \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    libxml2-dev \
    libffi-dev \
    liblzma-dev \
    unzip \
    zip \
    tar \
    gzip \
    jq \
    yq \
    bat \
    exa \
    btop \
    procps \
    neovim \
    fzf \
    ripgrep \
    fd-find \
    socat \
    netcat-openbsd \
    nmap \
    tcpdump \
    dnsutils \
    lsof \
    strace \
    gdb \
    locales \
    man-db \
    less \
    multitail \
    pv \
    zstd \
    7zip \
    p7zip-full \
    && rm -rf /var/lib/apt/lists/*

# 安装 Node.js 20
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# 安装 GitHub CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" > /etc/apt/sources.list.d/github-cli.list && \
    apt-get update && \
    apt-get install -y gh && \
    rm -rf /var/lib/apt/lists/*

# 安装 Go
RUN GO_VERSION=$(curl -s https://go.dev/VERSION?m=text | head -1) && \
    cd /tmp && \
    wget -q "https://go.dev/dl/${GO_VERSION}.linux-amd64.tar.gz" && \
    rm -rf /usr/local/go && \
    tar -C /usr/local -xzf "${GO_VERSION}.linux-amd64.tar.gz" && \
    rm "${GO_VERSION}.linux-amd64.tar.gz" && \
    mkdir -p /home/devuser/go/{bin,src,pkg}

# 安装 Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && \
    /home/devuser/.cargo/bin/cargo install --locked cargo-audit cargo-edit

# 安装 Starship 提示符
RUN curl -sS https://starship.rs/install.sh | sh -s -- -y

# 安装 Zoxide
RUN curl -sSf https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash

# 创建符号链接和配置
RUN ln -sf /usr/bin/fdfind /usr/local/bin/fd

# 配置用户环境 (在 entrypoint.sh 中重新配置)
RUN mkdir -p /home/devuser/.npm-global
RUN echo 'export PATH=$PATH:/home/devuser/.npm-global/bin' >> /home/devuser/.bashrc
RUN echo 'export PATH=$PATH:/home/devuser/.npm-global/bin' >> /home/devuser/.profile

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

# 生成 SSH 主机密钥（需要在 root 用户下）
RUN ssh-keygen -A

# 配置环境变量 (会在 entrypoint.sh 中重新配置)
ENV PATH=/home/devuser/.npm-global/bin:$PATH

# 暴露 SSH 端口
EXPOSE 22

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD pgrep sshd || exit 1

# 切换回 root 用户启动 SSH 服务
USER root

# 使用 entrypoint.sh 脚本初始化并启动
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["start"]