#!/bin/bash

# DevBox 增强工具测试脚本
echo "🧪 测试增强开发工具安装..."

set -e

# 检查是否在容器内
if [ ! -f "/.dockerenv" ]; then
    echo "⚠️  这个脚本应该在 Docker 容器内运行"
    echo "请先运行: ./start.sh 然后 ./connect.sh"
    exit 1
fi

# 获取当前用户
CURRENT_USER=${DEV_USER:-devuser}
echo "👤 测试用户: $CURRENT_USER"
echo ""

echo "📊 测试结果:"
echo "================================"

# 测试 Go
echo -n "🐹 Go: "
if command -v go &> /dev/null; then
    GO_VERSION=$(go version | cut -d' ' -f3)
    echo "✅ $GO_VERSION"
else
    echo "❌ 未安装"
fi

# 测试 Rust
echo -n "🦀 Rust: "
if command -v rustc &> /dev/null; then
    RUST_VERSION=$(rustc --version | cut -d' ' -f2)
    echo "✅ $RUST_VERSION"
else
    echo "❌ 未安装"
fi

# 测试 Cargo
echo -n "📦 Cargo: "
if command -v cargo &> /dev/null; then
    CARGO_VERSION=$(cargo --version | cut -d' ' -f2)
    echo "✅ $CARGO_VERSION"
else
    echo "❌ 未安装"
fi

# 测试 GitHub CLI
echo -n "🐙 GitHub CLI: "
if command -v gh &> /dev/null; then
    GH_VERSION=$(gh --version | head -1 | cut -d' ' -f3)
    echo "✅ $GH_VERSION"
else
    echo "❌ 未安装"
fi

# 测试 Neovim
echo -n "🔧 Neovim: "
if command -v nvim &> /dev/null; then
    NVIM_VERSION=$(nvim --version | head -1 | cut -d' ' -f2)
    echo "✅ $NVIM_VERSION"
else
    echo "❌ 未安装"
fi

# 测试 ripgrep
echo -n "🔍 ripgrep: "
if command -v rg &> /dev/null; then
    RG_VERSION=$(rg --version | head -1 | cut -d' ' -f2)
    echo "✅ $RG_VERSION"
else
    echo "❌ 未安装"
fi

# 测试 fd
echo -n "📁 fd: "
if command -v fd &> /dev/null; then
    FD_VERSION=$(fd --version | cut -d' ' -f2)
    echo "✅ $FD_VERSION"
else
    echo "❌ 未安装"
fi

# 测试 bat
echo -n "🦇 bat: "
if command -v bat &> /dev/null; then
    BAT_VERSION=$(bat --version | cut -d' ' -f2)
    echo "✅ $BAT_VERSION"
else
    echo "❌ 未安装"
fi

# 测试 exa
echo -n "📂 exa: "
if command -v exa &> /dev/null; then
    EXA_VERSION=$(exa --version | cut -d' ' -f2)
    echo "✅ $EXA_VERSION"
else
    echo "❌ 未安装"
fi

# 测试 btop
echo -n "📈 btop: "
if command -v btop &> /dev/null; then
    BTOP_VERSION=$(btop --version | cut -d' ' -f2)
    echo "✅ $BTOP_VERSION"
else
    echo "❌ 未安装"
fi

# 测试 fzf
echo -n "🔍 fzf: "
if command -v fzf &> /dev/null; then
    FZF_VERSION=$(fzf --version | cut -d' ' -f1)
    echo "✅ $FZF_VERSION"
else
    echo "❌ 未安装"
fi

# 测试 zoxide
echo -n "🚀 zoxide: "
if command -v zoxide &> /dev/null; then
    ZOXIDE_VERSION=$(zoxide --version | cut -d' ' -f2)
    echo "✅ $ZOXIDE_VERSION"
else
    echo "❌ 未安装"
fi

# 测试 starship
echo -n "⭐ starship: "
if command -v starship &> /dev/null; then
    STARSHIP_VERSION=$(starship --version | cut -d' ' -f2)
    echo "✅ $STARSHIP_VERSION"
else
    echo "❌ 未安装"
fi

# 测试 jq
echo -n "📋 jq: "
if command -v jq &> /dev/null; then
    JQ_VERSION=$(jq --version | cut -d' ' -f2)
    echo "✅ $JQ_VERSION"
else
    echo "❌ 未安装"
fi

# 测试 yq
echo -n "📋 yq: "
if command -v yq &> /dev/null; then
    YQ_VERSION=$(yq --version | cut -d' ' -f2)
    echo "✅ $YQ_VERSION"
else
    echo "❌ 未安装"
fi

echo ""
echo "🎯 功能测试:"
echo "================================"

# 测试别名
echo -n "🔗 别名配置: "
if alias ll &> /dev/null; then
    echo "✅ 已配置"
else
    echo "❌ 未配置"
fi

# 测试 Go 路径
echo -n "🛣️  Go 路径: "
if echo $PATH | grep -q "/usr/local/go/bin"; then
    echo "✅ 已配置"
else
    echo "❌ 未配置"
fi

# 测试 Cargo 路径
echo -n "🛣️  Cargo 路径: "
if echo $PATH | grep -q ".cargo/bin"; then
    echo "✅ 已配置"
else
    echo "❌ 未配置"
fi

# 测试 starship 初始化
echo -n "🚀 Starship: "
if echo $SHELL | grep -q "starship"; then
    echo "✅ 已配置"
else
    echo "⚠️ 需要重新登录"
fi

# 测试 zoxide 初始化
echo -n "🚀 Zoxide: "
if type __zoxide_zi &> /dev/null; then
    echo "✅ 已配置"
else
    echo "⚠️ 需要重新登录"
fi

echo ""
echo "📁 配置文件测试:"
echo "================================"

# 测试 Neovim 配置
echo -n "🔧 Neovim 配置: "
if [ -f "/home/$CURRENT_USER/.config/nvim/init.vim" ]; then
    echo "✅ 已创建"
else
    echo "❌ 未创建"
fi

# 测试 Starship 配置
echo -n "⭐ Starship 配置: "
if [ -f "/home/$CURRENT_USER/.config/starship.toml" ]; then
    echo "✅ 已创建"
else
    echo "❌ 未创建"
fi

# 测试 Go 目录
echo -n "📂 Go 目录: "
if [ -d "/home/$CURRENT_USER/go" ]; then
    echo "✅ 已创建"
else
    echo "❌ 未创建"
fi

# 测试 Cargo 目录
echo -n "📂 Cargo 目录: "
if [ -d "/home/$CURRENT_USER/.cargo" ]; then
    echo "✅ 已创建"
else
    echo "❌ 未创建"
fi

echo ""
echo "🎉 测试完成！"
echo ""
echo "📝 提示:"
echo "   - 如果某些工具显示需要重新登录，请运行 'source ~/.bashrc' 或重新连接"
echo "   - 要测试新的别名和功能，请重新启动 shell"
echo "   - 使用 'nvim' 来体验现代化的 Vim 编辑器"
echo "   - 使用 'z 目录名' 来快速跳转到常用目录"
echo "   - 使用 'rg 搜索词' 来进行超快速代码搜索"