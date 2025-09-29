#!/bin/bash

# DevBox 增强开发工具安装脚本
echo "🚀 安装增强开发工具..."

set -e

# 检查是否在容器内
if [ ! -f "/.dockerenv" ]; then
    echo "⚠️  这个脚本应该在 Docker 容器内运行"
    echo "请先运行: ./start.sh 然后 ./connect.sh"
    exit 1
fi

# 检查用户权限
if [ "$EUID" -eq 0 ]; then
    echo "🔧 以 root 权限运行安装..."
else
    echo "👤 需要管理员权限，使用 sudo..."
    if ! sudo -n true 2>/dev/null; then
        echo "❌ 需要管理员权限，请使用 sudo 运行或配置 sudo 免密码"
        exit 1
    fi
fi

# 获取当前用户
CURRENT_USER=${DEV_USER:-devuser}
echo "👤 为用户 $CURRENT_USER 安装工具..."

echo ""
echo "📦 更新包管理器..."
sudo apt-get update

echo ""
echo "🔨 安装编译工具和依赖..."
sudo apt-get install -y \
    build-essential \
    cmake \
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
    curl \
    wget \
    git \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release \
    unzip \
    zip \
    tar \
    gzip \
    jq \
    yq \
    bat \
    exa \
    btop \
    htop \
    procps \
    neovim \
    tmux \
    zsh \
    fzf \
    ripgrep \
    fd-find \
    socat \
    netcat-openbsd \
    nmap \
    tcpdump \
    dnsutils \
    iputils-ping \
    net-tools \
    lsof \
    strace \
    gdb \
    locales \
    man-db \
    less \
    tree \
    multitail \
    pv \
    zstd \
    7zip \
    p7zip-full

echo ""
echo "🐹 安装 Go..."
# 安装最新版 Go
GO_VERSION=$(curl -s https://go.dev/VERSION?m=text | head -1)
cd /tmp
wget -q "https://go.dev/dl/${GO_VERSION}.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "${GO_VERSION}.linux-amd64.tar.gz"
rm "${GO_VERSION}.linux-amd64.tar.gz"

# 创建 Go 目录
sudo -u "$CURRENT_USER" mkdir -p /home/$CURRENT_USER/go/{bin,src,pkg}

echo ""
echo "🦀 安装 Rust..."
# 安装 Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sudo -u "$CURRENT_USER" sh -s -- -y
source /home/$CURRENT_USER/.cargo/env

echo ""
echo "🐙 安装 GitHub CLI..."
# 安装 GitHub CLI
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt-get update
sudo apt-get install -y gh

echo ""
echo "🚀 安装 zoxide..."
# 安装 zoxide
curl -sSf https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash

echo ""
echo "📁 创建符号链接和配置..."
# 为 fd-find 创建 fd 符号链接
if [ -f /usr/bin/fdfind ] && [ ! -f /usr/local/bin/fd ]; then
    sudo ln -sf /usr/bin/fdfind /usr/local/bin/fd
fi

# 配置用户环境
echo "配置用户环境..."

# 更新 .bashrc
cat >> /home/$CURRENT_USER/.bashrc << 'EOF'

# DevBox 增强工具配置
export PATH=$PATH:/usr/local/go/bin
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
export PATH=$PATH:$HOME/.cargo/bin

# 评估 zoxide
eval "$(zoxide init bash)"

# 设置默认编辑器
export EDITOR=nvim
export VISUAL=nvim

# 别名
alias ll='exa -alh --git'
alias la='exa -ah --git'
alias lt='exa --tree --level=3'
alias cat='bat --style=plain --paging=never'
alias grep='rg'
alias find='fd'
alias top='btop'
alias htop='btop'
alias vim='nvim'
alias vi='nvim'

# Go 相关别名
alias gobuild='go build -v'
alias gotest='go test -v'
alias gorun='go run'
alias gofmt='go fmt ./...'

# Git 相关别名
alias gs='git status'
alias gl='git log --oneline --graph --decorate'
alias ga='git add'
alias gc='git commit -v'
alias gp='git push'
alias gd='git diff'
alias gb='git branch'
alias gco='git checkout'

# GitHub CLI 别名
alias ghpr='gh pr create'
alias ghprv='gh pr view'
alias ghprs='gh pr list'
alias ghissues='gh issue list'
EOF

# 更新 .zshrc
cat >> /home/$CURRENT_USER/.zshrc << 'EOF'

# DevBox 增强工具配置
export PATH=$PATH:/usr/local/go/bin
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
export PATH=$PATH:$HOME/.cargo/bin

# 评估 zoxide
eval "$(zoxide init zsh)"

# 设置默认编辑器
export EDITOR=nvim
export VISUAL=nvim

# 别名
alias ll='exa -alh --git'
alias la='exa -ah --git'
alias lt='exa --tree --level=3'
alias cat='bat --style=plain --paging=never'
alias grep='rg'
alias find='fd'
alias top='btop'
alias htop='btop'
alias vim='nvim'
alias vi='nvim'

# Go 相关别名
alias gobuild='go build -v'
alias gotest='go test -v'
alias gorun='go run'
alias gofmt='go fmt ./...'

# Git 相关别名
alias gs='git status'
alias gl='git log --oneline --graph --decorate'
alias ga='git add'
alias gc='git commit -v'
alias gp='git push'
alias gd='git diff'
alias gb='git branch'
alias gco='git checkout'

# GitHub CLI 别名
alias ghpr='gh pr create'
alias ghprv='gh pr view'
alias ghprs='gh pr list'
alias ghissues='gh issue list'
EOF

# 配置 nvim
sudo -u "$CURRENT_USER" mkdir -p /home/$CURRENT_USER/.config/nvim
cat > /home/$CURRENT_USER/.config/nvim/init.vim << 'EOF'
" 基础配置
set number
set relativenumber
set expandtab
set shiftwidth=4
set tabstop=4
set smarttab
set autoindent
set smartindent
set cursorline
set showmatch
set laststatus=2
set showcmd
set wildmenu
set hlsearch
set incsearch
set ignorecase
set smartcase

" 启用语法高亮
syntax enable
filetype plugin indent on

" 设置主题
colorscheme desert

" 设置 Leader 键
let mapleader = " "

" 快捷键
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>
nnoremap <leader>so :source ~/.config/nvim/init.vim<CR>

" 分屏快捷键
nnoremap <leader>v :vsplit<CR>
nnoremap <leader>h :split<CR>
nnoremap <leader>nh :nohlsearch<CR>

" 缓冲区快捷键
nnoremap <leader>bn :bnext<CR>
nnoremap <leader>bp :bprev<CR>
nnoremap <leader>bd :bdelete<CR>

" 启用鼠标
set mouse=a

" 复制到系统剪贴板
set clipboard=unnamedplus

" 显示空白字符
set list
set listchars=tab:→\ ,space:·,trail:·,extends:>,precedes:<

" 自动保存
set autowrite
set autowriteall

" 搜索时忽略大小写
set ignorecase
set smartcase

" 增量搜索
set incsearch

" 高亮搜索结果
set hlsearch

" 自动缩进
set autoindent
set smartindent

" 设置制表符宽度
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab

" 显示行号
set number
set relativenumber

" 显示光标行
set cursorline

" 显示匹配的括号
set showmatch

" 设置状态栏
set laststatus=2

" 设置命令行高度
set cmdheight=1

" 设置历史记录
set history=1000

" 设置备份文件
set backup
set backupdir=~/.config/nvim/backup
set directory=~/.config/nvim/tmp

" 创建备份目录
if !isdirectory($HOME."/.config/nvim/backup")
    call mkdir($HOME."/.config/nvim/backup", "p", 0700)
endif

if !isdirectory($HOME."/.config/nvim/tmp")
    call mkdir($HOME."/.config/nvim/tmp", "p", 0700)
endif
EOF

# 设置正确的权限
sudo chown -R "$CURRENT_USER:$CURRENT_USER" /home/$CURRENT_USER/.config
sudo chown -R "$CURRENT_USER:$CURRENT_USER" /home/$CURRENT_USER/go
sudo chown -R "$CURRENT_USER:$CURRENT_USER" /home/$CURRENT_USER/.cargo

echo ""
echo "🎨 配置 Starship 提示符..."
# 安装 starship
curl -sS https://starship.rs/install.sh | sudo sh -s -- -y

# 配置 starship
cat >> /home/$CURRENT_USER/.bashrc << 'EOF'
eval "$(starship init bash)"
EOF

cat >> /home/$CURRENT_USER/.zshrc << 'EOF'
eval "$(starship init zsh)"
EOF

# 创建 starship 配置
sudo -u "$CURRENT_USER" mkdir -p /home/$CURRENT_USER/.config
cat > /home/$CURRENT_USER/.config/starship.toml << 'EOF'
[character]
success_symbol = "[➜](bold green)"
error_symbol = "[➜](bold red)"

[directory]
truncation_length = 3
truncation_symbol = "…/"

[git_branch]
symbol = "🌱 "

[git_commit]
commit_hash_length = 7
tag_symbol = "🏷️ "

[git_status]
ahead = "⇡"
behind = "⇣"
diverged = "⇕"
conflicted = "❗"
untracked = "📁"
modified = "📝"
staged = "📌"
renamed = "📛"
deleted = "🗑️"

[nodejs]
symbol = "📦 "

[python]
symbol = "🐍 "

[golang]
symbol = "🐹 "

[rust]
symbol = "🦀 "

[package]
symbol = "📦 "

[docker_context]
symbol = "🐳 "

[time]
disabled = false
format = "🕐 %T "
utc_time_offset = "+8"

[username]
style_user = "bold yellow"
format = "👤 [$user]($style) "

[hostname]
ssh_only = false
format = "🖥️ [$hostname]($style) "
style = "bold dimmed white"

EOF

echo ""
echo "🎉 增强开发工具安装完成！"
echo ""
echo "📋 安装摘要:"
echo "   Go: ✅ 已安装"
echo "   Rust: ✅ 已安装"
echo "   GitHub CLI: ✅ 已安装"
echo "   Neovim: ✅ 已安装"
echo "   ripgrep: ✅ 已安装"
echo "   fd: ✅ 已安装"
echo "   jq: ✅ 已安装"
echo "   yq: ✅ 已安装"
echo "   bat: ✅ 已安装"
echo "   exa: ✅ 已安装"
echo "   btop: ✅ 已安装"
echo "   fzf: ✅ 已安装"
echo "   zoxide: ✅ 已安装"
echo "   starship: ✅ 已安装"
echo ""
echo "🔧 新增功能:"
echo "   - 智能命令别名"
echo "   - 增强的 shell 提示符"
echo "   - Neovim 配置"
echo "   - Go 开发环境"
echo "   - Rust 开发环境"
echo ""
echo "🔄 请重新登录或运行 'source ~/.bashrc' 使配置生效"
echo ""
echo "🎯 试试这些新命令:"
echo "   ll - 漂亮的文件列表"
echo "   cat - 语法高亮的 cat"
echo "   fd - 现代化的 find"
echo "   rg - 超快的 grep"
echo "   z - 智能目录跳转"
echo "   nvim - 现代化的 vim"
echo "   gh - GitHub CLI"