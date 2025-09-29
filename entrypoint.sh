#!/bin/bash

set -e

# 获取环境变量或使用默认值
DEV_USER=${DEV_USER:-devuser}
DEV_PASSWORD=${DEV_PASSWORD:-devuser}

echo "🚀 初始化 DevBox 开发环境..."
echo "用户名: $DEV_USER"
echo "密码: $DEV_PASSWORD"

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

# 动态创建或更新用户
if ! id "$DEV_USER" &>/dev/null; then
    echo "创建用户: $DEV_USER"
    useradd -m -s /bin/bash "$DEV_USER"
    echo "$DEV_USER:$DEV_PASSWORD" | chpasswd
    usermod -aG sudo "$DEV_USER"
    mkdir -p /home/$DEV_USER/.ssh
    chown -R "$DEV_USER:$DEV_USER" /home/$DEV_USER
else
    echo "用户 $DEV_USER 已存在，更新密码..."
    echo "$DEV_USER:$DEV_PASSWORD" | chpasswd
fi

# 重命名默认用户目录（如果存在且与当前用户不同）
if [ "$DEV_USER" != "devuser" ] && [ -d "/home/devuser" ]; then
    if [ ! -d "/home/$DEV_USER" ]; then
        echo "重命名用户目录: /home/devuser -> /home/$DEV_USER"
        mv /home/devuser /home/$DEV_USER
        chown -R "$DEV_USER:$DEV_USER" /home/$DEV_USER
    fi
fi

# 设置正确的权限
chmod 700 /home/$DEV_USER/.ssh
chmod 600 /home/$DEV_USER/.ssh/authorized_keys 2>/dev/null || true
chown "$DEV_USER:$DEV_USER" /home/$DEV_USER/.ssh/authorized_keys 2>/dev/null || true

# 创建项目目录
mkdir -p /home/$DEV_USER/projects
chown "$DEV_USER:$DEV_USER" /home/$DEV_USER/projects

# 配置用户环境
echo "配置用户环境..."

# 配置 npm 全局路径
sudo -u "$DEV_USER" mkdir -p /home/$DEV_USER/.npm-global
sudo -u "$DEV_USER" npm config set prefix /home/$DEV_USER/.npm-global

# 配置 Neovim
echo "配置 Neovim..."
sudo -u "$DEV_USER" mkdir -p /home/$DEV_USER/.config/nvim
cat > /home/$DEV_USER/.config/nvim/init.vim << 'NEOVIM_EOF'
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
NEOVIM_EOF

# 配置 Starship
echo "配置 Starship..."
sudo -u "$DEV_USER" mkdir -p /home/$DEV_USER/.config
cat > /home/$DEV_USER/.config/starship.toml << 'STARSHIP_EOF'
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
STARSHIP_EOF

# 更新 .bashrc
cat >> /home/$DEV_USER/.bashrc << EOF

# DevBox 增强配置
export PATH=\$PATH:/home/$DEV_USER/.npm-global/bin
export PATH=\$PATH:/usr/local/go/bin
export GOPATH=\$HOME/go
export PATH=\$PATH:\$GOPATH/bin
export PATH=\$PATH:\$HOME/.cargo/bin
export CLAUDE_CODE_HOME=/home/$DEV_USER/.claude-code
export DEV_USER=$DEV_USER
export EDITOR=nvim
export VISUAL=nvim

# 评估 zoxide
eval "\$(zoxide init bash)"

# 评估 starship
eval "\$(starship init bash)"

# AI 工具别名
alias cc='claude-code'
alias ccr='claude-code-router'
alias hc='happy'

# 文件操作别名
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

# 更新 .profile
cat >> /home/$DEV_USER/.profile << EOF

# DevBox 增强配置
export PATH=\$PATH:/home/$DEV_USER/.npm-global/bin
export PATH=\$PATH:/usr/local/go/bin
export GOPATH=\$HOME/go
export PATH=\$PATH:\$GOPATH/bin
export PATH=\$PATH:\$HOME/.cargo/bin
export CLAUDE_CODE_HOME=/home/$DEV_USER/.claude-code
export DEV_USER=$DEV_USER
export EDITOR=nvim
export VISUAL=nvim
EOF

# 如果用户不是默认的 devuser，也需要更新 devuser 的配置
if [ "$DEV_USER" != "devuser" ] && [ -d "/home/devuser" ]; then
    cat >> /home/devuser/.bashrc << EOF

# DevBox 配置
export PATH=\$PATH:/home/devuser/.npm-global/bin
export CLAUDE_CODE_HOME=/home/devuser/.claude-code
EOF
fi

# 初始化开发环境（如果还没有初始化）
if [ ! -f "/home/$DEV_USER/.dev_env_initialized" ]; then
    echo "首次启动，初始化开发环境..."

    # 安装 oh-my-zsh（如果用户没有安装）
    if [ ! -d "/home/$DEV_USER/.oh-my-zsh" ]; then
        echo "安装 oh-my-zsh..."
        sudo -u "$DEV_USER" sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || echo "oh-my-zsh installation failed"
    fi

    # 配置 zsh
    if [ -f "/home/$DEV_USER/.zshrc" ]; then
        cat >> /home/$DEV_USER/.zshrc << EOF

# DevBox 增强配置
export PATH=\$PATH:/home/$DEV_USER/.npm-global/bin
export PATH=\$PATH:/usr/local/go/bin
export GOPATH=\$HOME/go
export PATH=\$PATH:\$GOPATH/bin
export PATH=\$PATH:\$HOME/.cargo/bin
export CLAUDE_CODE_HOME=/home/$DEV_USER/.claude-code
export DEV_USER=$DEV_USER
export EDITOR=nvim
export VISUAL=nvim

# 评估 zoxide
eval "\$(zoxide init zsh)"

# 评估 starship
eval "\$(starship init zsh)"

# AI 工具别名
alias cc='claude-code'
alias ccr='claude-code-router'
alias hc='happy'

# 文件操作别名
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
    fi

    touch "/home/$DEV_USER/.dev_env_initialized"
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
    echo "  SSH: ssh $DEV_USER@localhost -p 2222"
    echo "  密码: $DEV_PASSWORD"
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
        exec sudo -u "$DEV_USER" /bin/bash
        ;;
    *)
        echo "未知命令: $1"
        echo "可用命令: start, shell, dev"
        exit 1
        ;;
esac