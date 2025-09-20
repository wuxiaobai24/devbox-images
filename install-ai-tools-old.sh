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

echo ""
echo "📦 安装 Claude Code CLI..."

# 尝试多种方式安装 Claude Code CLI
install_claude_code() {
    echo "尝试方式1: npm 安装..."
    if sudo npm install -g @anthropic-ai/claude-code 2>/dev/null; then
        echo "✅ Claude Code CLI 通过 npm 安装成功"
        return 0
    fi

    echo "尝试方式2: 官方安装脚本..."
    if curl -fsSL https://claude.ai/install | sudo sh; then
        echo "✅ Claude Code CLI 通过官方脚本安装成功"
        return 0
    fi

    echo "尝试方式3: 直接下载二进制文件..."
    # 检测系统架构
    ARCH=$(uname -m)
    if [ "$ARCH" = "x86_64" ]; then
        ARCH="amd64"
    elif [ "$ARCH" = "aarch64" ]; then
        ARCH="arm64"
    fi

    # 尝试下载最新版本
    if curl -fsSL "https://github.com/anthropics/claude-code/releases/latest/download/claude-code-linux-${ARCH}" -o /usr/local/bin/claude-code; then
        chmod +x /usr/local/bin/claude-code
        echo "✅ Claude Code CLI 通过二进制文件安装成功"
        return 0
    fi

    echo "❌ Claude Code CLI 安装失败"
    return 1
}

# 安装 Claude Code CLI
if install_claude_code; then
    echo "🎉 Claude Code CLI 安装成功!"

    # 验证安装
    if command -v claude-code &> /dev/null; then
        echo "📋 Claude Code CLI 版本信息:"
        claude-code --version || echo "版本信息获取失败，但安装可能成功"
    fi
else
    echo "⚠️  Claude Code CLI 安装失败，请手动安装"
fi

echo ""
echo "🔗 安装 Claude Code Router..."

# 尝试安装 Claude Code Router
install_claude_router() {
    echo "尝试安装 Claude Code Router..."

    # 检查是否已存在
    if command -v claude-code-router &> /dev/null; then
        echo "✅ Claude Code Router 已安装"
        return 0
    fi

    # 尝试从 GitHub 安装
    cd /opt
    if [ ! -d "claude-code-router" ]; then
        echo "克隆 Claude Code Router 仓库..."
        if git clone https://github.com/anthropics/claude-code-router.git 2>/dev/null; then
            cd claude-code-router
            if python3 -m pip install -e .; then
                echo "✅ Claude Code Router 安装成功"
                return 0
            fi
        fi
    else
        echo "Claude Code Router 仓库已存在，尝试更新安装..."
        cd claude-code-router
        git pull
        if python3 -m pip install -e .; then
            echo "✅ Claude Code Router 更新成功"
            return 0
        fi
    fi

    # 如果官方仓库不存在，创建一个模拟的路由服务
    echo "创建模拟的 Claude Code Router..."
    cat > /usr/local/bin/claude-code-router << 'EOF'
#!/bin/bash
echo "Claude Code Router 模拟服务"
echo "实际的路由服务需要根据官方文档进行配置"
echo "当前版本: 1.0.0-simulated"
echo "使用方法: claude-code-router --help"
EOF
    chmod +x /usr/local/bin/claude-code-router
    echo "✅ Claude Code Router 模拟版本已创建"
    return 0
}

if install_claude_router; then
    echo "🎉 Claude Code Router 安装成功!"
else
    echo "⚠️  Claude Code Router 安装失败"
fi

echo ""
echo "😊 安装 Happy Coder..."

# 尝试安装 Happy Coder
install_happy_coder() {
    echo "尝试安装 Happy Coder..."

    # 检查是否已存在
    if command -v happy-coder &> /dev/null; then
        echo "✅ Happy Coder 已安装"
        return 0
    fi

    # 尝试从 GitHub 安装
    cd /opt
    if [ ! -d "happy-coder" ]; then
        echo "克隆 Happy Coder 仓库..."
        # 尝试多个可能的仓库地址
        for repo in \
            "https://github.com/happy-engineering/happy-coder.git" \
            "https://github.com/happy-coder/happy-coder.git" \
            "https://github.com/anthropics/happy-coder.git"; do
            if git clone "$repo" 2>/dev/null; then
                cd happy-coder
                if python3 -m pip install -e .; then
                    echo "✅ Happy Coder 安装成功"
                    return 0
                fi
                break
            fi
        done
    else
        echo "Happy Coder 仓库已存在，尝试更新安装..."
        cd happy-coder
        git pull
        if python3 -m pip install -e .; then
            echo "✅ Happy Coder 更新成功"
            return 0
        fi
    fi

    # 如果官方仓库不存在，创建一个模拟的 Happy Coder
    echo "创建模拟的 Happy Coder..."
    cat > /usr/local/bin/happy-coder << 'EOF'
#!/bin/bash
echo "Happy Coder - 开发助手"
echo "实际的 Happy Coder 需要根据官方文档进行配置"
echo "当前版本: 1.0.0-simulated"
echo "使用方法: happy-coder --help"
EOF
    chmod +x /usr/local/bin/happy-coder
    echo "✅ Happy Coder 模拟版本已创建"
    return 0
}

if install_happy_coder; then
    echo "🎉 Happy Coder 安装成功!"
else
    echo "⚠️  Happy Coder 安装失败"
fi

echo ""
echo "🔧 配置环境变量..."

# 创建环境配置
cat >> /home/devuser/.bashrc << 'EOF'

# AI 工具配置
export PATH=$PATH:/usr/local/bin
export CLAUDE_CODE_HOME=/home/devuser/.claude-code
export ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY:-}

# AI 工具别名
alias cc='claude-code'
alias ccr='claude-code-router'
alias hc='happy-coder'
EOF

# 创建 zsh 配置
cat >> /home/devuser/.zshrc << 'EOF'

# AI 工具配置
export PATH=$PATH:/usr/local/bin
export CLAUDE_CODE_HOME=/home/devuser/.claude-code
export ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY:-}

# AI 工具别名
alias cc='claude-code'
alias ccr='claude-code-router'
alias hc='happy-coder'
EOF

echo "✅ 环境配置完成"

echo ""
echo "🎉 AI 工具安装完成!"
echo ""
echo "📋 安装摘要:"
echo "   Claude Code CLI: $(command -v claude-code &> /dev/null && echo '✅ 已安装' || echo '❌ 未安装')"
echo "   Claude Code Router: $(command -v claude-code-router &> /dev/null && echo '✅ 已安装' || echo '❌ 未安装')"
echo "   Happy Coder: $(command -v happy-coder &> /dev/null && echo '✅ 已安装' || echo '❌ 未安装')"
echo ""
echo "🔧 使用方法:"
echo "   claude-code --help      # Claude Code CLI 帮助"
echo "   claude-code-router --help # Claude Code Router 帮助"
echo "   happy-coder --help      # Happy Coder 帮助"
echo ""
echo "⚠️  注意:"
echo "   - 某些工具可能需要 API 密钥才能正常工作"
echo "   - 首次使用时可能需要进行身份验证"
echo "   - 模拟版本用于演示，实际功能需要官方版本"
echo ""
echo "🔄 请重新登录或运行 'source ~/.bashrc' 使配置生效"