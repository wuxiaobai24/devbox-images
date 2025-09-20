#!/bin/bash

# AI 工具智能安装脚本 - 修正版
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
echo "🔗 安装 Claude Code Router (@musistudio/claude-code-router)..."

# 安装 Claude Code Router
install_claude_router() {
    echo "尝试安装 Claude Code Router..."

    # 检查是否已存在
    if npm list -g @musistudio/claude-code-router &> /dev/null; then
        echo "✅ Claude Code Router 已安装"
        return 0
    fi

    # 通过 npm 安装
    if sudo npm install -g @musistudio/claude-code-router; then
        echo "✅ Claude Code Router 安装成功"
        return 0
    fi

    echo "❌ Claude Code Router 安装失败"
    return 1
}

if install_claude_router; then
    echo "🎉 Claude Code Router 安装成功!"

    # 验证安装
    if command -v ccr &> /dev/null; then
        echo "📋 Claude Code Router 版本信息:"
        ccr --version || echo "版本信息获取失败，但安装成功"
    fi
else
    echo "⚠️  Claude Code Router 安装失败，请手动安装"
    echo "手动安装: npm install -g @musistudio/claude-code-router"
fi

echo ""
echo "😊 安装 Happy (@slopus/happy) - Claude Code Mobile/Web Client..."

# 安装 Happy (Claude Code Client)
install_happy() {
    echo "尝试安装 Happy..."

    # 检查是否已存在
    if command -v happy &> /dev/null; then
        echo "✅ Happy 已安装"
        return 0
    fi

    # 尝试从 GitHub 安装
    cd /opt
    if [ ! -d "happy" ]; then
        echo "克隆 Happy 仓库..."
        if sudo git clone https://github.com/slopus/happy.git; then
            cd happy
            echo "安装 Happy 依赖..."
            if sudo npm install; then
                echo "✅ Happy 依赖安装成功"

                # 创建全局符号链接
                if [ -f "bin/happy" ]; then
                    sudo ln -sf /opt/happy/bin/happy /usr/local/bin/happy
                    echo "✅ Happy 全局链接创建成功"
                    return 0
                elif [ -f "src/index.js" ]; then
                    # 创建启动脚本
                    sudo cat > /usr/local/bin/happy << 'EOF'
#!/usr/bin/env node
const path = require('path');
process.chdir('/opt/happy');
require(path.join(__dirname, '../happy/src/index.js'));
EOF
                    sudo chmod +x /usr/local/bin/happy
                    echo "✅ Happy 启动脚本创建成功"
                    return 0
                fi
            fi
        fi
    else
        echo "Happy 仓库已存在，尝试更新..."
        cd happy
        sudo git pull
        if sudo npm install; then
            echo "✅ Happy 更新成功"
            return 0
        fi
    fi

    # 如果源码安装失败，检查是否有 npm 包
    echo "尝试通过 npm 安装 Happy..."
    if sudo npm install -g @slopus/happy 2>/dev/null || sudo npm install -g happy-client 2>/dev/null; then
        echo "✅ Happy 通过 npm 安装成功"
        return 0
    fi

    echo "❌ Happy 安装失败"
    return 1
}

if install_happy; then
    echo "🎉 Happy 安装成功!"

    # 验证安装
    if command -v happy &> /dev/null; then
        echo "📋 Happy 版本信息:"
        happy --version || echo "版本信息获取失败，但安装成功"
    fi
else
    echo "⚠️  Happy 安装失败，请手动安装"
    echo "手动安装: git clone https://github.com/slopus/happy.git && cd happy && npm install"
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
alias hc='happy'
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
alias hc='happy'
EOF

echo "✅ 环境配置完成"

echo ""
echo "🎉 AI 工具安装完成!"
echo ""
echo "📋 安装摘要:"
echo "   Claude Code CLI: $(command -v claude-code &> /dev/null && echo '✅ 已安装' || echo '❌ 未安装')"
echo "   Claude Code Router: $(command -v ccr &> /dev/null && echo '✅ 已安装' || echo '❌ 未安装')"
echo "   Happy: $(command -v happy &> /dev/null && echo '✅ 已安装' || echo '❌ 未安装')"
echo ""
echo "🔧 使用方法:"
echo "   claude-code --help      # Claude Code CLI 帮助"
echo "   ccr --help              # Claude Code Router 帮助"
echo "   happy --help           # Happy Claude Code Client 帮助"
echo ""
echo "📝 项目信息:"
echo "   Claude Code Router: https://github.com/musistudio/claude-code-router"
echo "   Happy: https://github.com/slopus/happy (Claude Code Mobile/Web Client)"
echo ""
echo "⚠️  注意:"
echo "   - 某些工具可能需要 API 密钥才能正常工作"
echo "   - 首次使用时可能需要进行身份验证"
echo "   - Happy 是 Claude Code 的移动端/Web 客户端"
echo ""
echo "🔄 请重新登录或运行 'source ~/.bashrc' 使配置生效"