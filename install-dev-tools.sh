#!/bin/bash

# 开发工具安装脚本
echo "安装开发工具..."

# 安装 Go
GO_VERSION="1.21.0"
cd /tmp
wget -q https://golang.org/dl/go${GO_VERSION}.linux-amd64.tar.gz
tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz
rm go${GO_VERSION}.linux-amd64.tar.gz

# 设置 Go 环境变量
echo 'export PATH=$PATH:/usr/local/go/bin' >> /etc/profile
echo 'export GOPATH=/home/devuser/go' >> /etc/profile
echo 'export PATH=$PATH:$GOPATH/bin' >> /etc/profile

# 安装 Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source /home/devuser/.cargo/env

# 安装 Docker CLI
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
rm get-docker.sh

# 安装 kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl

# 安装 helm
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | tee /usr/share/keyrings/helm.gpg > /dev/null
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | tee /etc/apt/sources.list.d/helm-stable-debian.list
apt-get update
apt-get install -y helm

# 安装 Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# 安装 AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
rm -rf awscliv2.zip aws

# 安装额外的开发工具
apt-get update
apt-get install -y \
    jq \
    yq \
    fzf \
    ripgrep \
    bat \
    exa \
    neofetch \
    ncdu \
    btop \
    zoxide \
    starship \
    git-delta \
    lazygit \
    neovim

# 清理
apt-get clean
rm -rf /var/lib/apt/lists/*

# 配置 starship
echo 'eval "$(starship init bash)"' >> /etc/bash.bashrc
echo 'eval "$(starship init zsh)"' >> /etc/zsh/zshrc

# 安装 zsh 插件
git clone https://github.com/zsh-users/zsh-autosuggestions /home/devuser/.oh-my-zsh/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting /home/devuser/.oh-my-zsh/plugins/zsh-syntax-highlighting

# 更新 .zshrc 配置
cat >> /home/devuser/.zshrc << 'EOF'

# 启用插件
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

# 设置命令别名
alias ll='exa -alh'
alias la='exa -a'
alias lt='exa -alh --tree'
alias cat='bat'
alias grep='rg'
alias find='fd'
alias ps='procs'
alias top='btop'

# 启用 zoxide
eval "$(zoxide init zsh)"

# 启用 starship
eval "$(starship init zsh)"
EOF

# 设置正确的权限
chown -R devuser:devuser /home/devuser

echo "开发工具安装完成！"