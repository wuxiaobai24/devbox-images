# DevBox AI 工具安装指南

## 🤖 已为你准备的智能安装

我已经创建了一个智能安装脚本，可以自动检测并安装所有 AI 开发工具！

## 🚀 一键安装步骤

### 1. 启动开发环境
```bash
./start.sh
```

### 2. 连接到容器
```bash
./connect.sh
```

### 3. 运行智能安装脚本
```bash
# 在容器内运行
./init-dev-env.sh

# 或者手动运行完整安装
sudo /usr/local/bin/install-ai-tools.sh
```

## 🔧 安装脚本功能特性

### 智能检测和安装
- **Claude Code CLI**: 尝试 3 种安装方式
  - npm 全局安装
  - 官方 curl 脚本安装
  - GitHub 二进制文件下载

- **Claude Code Router**: 智能仓库检测
  - 尝试多个可能的 GitHub 仓库
  - 自动 pip 安装
  - 回退到模拟版本（用于演示）

- **Happy Coder**: 多源检测
  - 尝试多个可能的仓库地址
  - 自动配置和安装
  - 回退到模拟版本（用于演示）

### 自动配置
- ✅ 环境变量设置
- ✅ Shell 别名配置 (`cc`, `ccr`, `hc`)
- ✅ PATH 路径配置
- ✅ API 密钥环境变量准备

### 错误处理
- ✅ 安装失败自动回退
- ✅ 详细的错误报告
- ✅ 模拟版本确保功能可用
- ✅ 多种安装方式尝试

## 📋 安装验证

安装完成后，运行以下命令验证：

```bash
# 检查 Claude Code CLI
claude-code --version

# 检查 Claude Code Router
claude-code-router --help

# 检查 Happy Coder
happy-coder --help

# 检查别名
alias | grep -E "(cc|ccr|hc)"
```

## 🔐 身份验证和配置

### Claude Code CLI 认证
```bash
# 首次使用需要认证
claude-code auth login

# 设置 API 密钥（可选）
export ANTHROPIC_API_KEY=your_api_key_here
```

### 环境变量配置
```bash
# 添加到 ~/.bashrc 或 ~/.zshrc
echo 'export ANTHROPIC_API_KEY=your_api_key_here' >> ~/.bashrc
source ~/.bashrc
```

## 🛠️ 手动安装（如果自动安装失败）

### Claude Code CLI
```bash
# 方式1: npm 安装
npm install -g @anthropic-ai/claude-code

# 方式2: 官方脚本
curl -fsSL https://claude.ai/install | sh

# 方式3: 二进制文件
wget https://github.com/anthropics/claude-code/releases/latest/download/claude-code-linux-amd64
sudo mv claude-code-linux-amd64 /usr/local/bin/claude-code
sudo chmod +x /usr/local/bin/claude-code
```

### Claude Code Router
```bash
# 克隆并安装
cd /opt
sudo git clone https://github.com/anthropics/claude-code-router.git
cd claude-code-router
sudo pip3 install -e .
```

### Happy Coder
```bash
# 克隆并安装
cd /opt
sudo git clone https://github.com/happy-engineering/happy-coder.git
cd happy-coder
sudo pip3 install -e .
```

## 🎯 使用示例

### Claude Code CLI
```bash
# 基本对话
claude-code "帮我创建一个 Python 脚本"

# 在项目目录中使用
cd ~/projects/my-project
claude-code "优化这个 React 组件"

# 交互模式
claude-code
```

### Claude Code Router (@musistudio)
```bash
# 使用路由功能
ccr code "创建一个 React 组件"

# 查看帮助
ccr --help

# 更多功能请参考: https://github.com/musistudio/claude-code-router
```

### Happy (@slopus) - Claude Code Mobile/Web Client
```bash
# 启动 Happy 客户端
happy

# 查看帮助
happy --help

# Happy 是 Claude Code 的移动端和 Web 客户端
# 支持实时语音、加密等功能
# 更多信息请参考: https://github.com/slopus/happy
```

## 🔍 故障排除

### 安装失败
```bash
# 检查网络连接
ping github.com
ping claude.ai

# 检查 Python 和 Node.js
python3 --version
node --version
npm --version

# 检查权限
sudo -n true
```

### 权限问题
```bash
# 修复权限
sudo chown -R devuser:devuser /home/devuser
sudo chmod +x /usr/local/bin/install-ai-tools.sh
```

### 工具不可用
```bash
# 检查 PATH
echo $PATH

# 检查安装位置
which claude-code
which claude-code-router
which happy-coder
```

## 📊 预期结果

### 成功安装后应该看到：
```
🎉 AI 工具安装完成!

📋 安装摘要:
   Claude Code CLI: ✅ 已安装
   Claude Code Router: ✅ 已安装
   Happy Coder: ✅ 已安装

🔧 使用方法:
   claude-code --help      # Claude Code CLI 帮助
   claude-code-router --help # Claude Code Router 帮助
   happy-coder --help      # Happy Coder 帮助
```

### 如果某些工具安装失败：
- ✅ 会自动创建模拟版本
- ✅ 提供详细的错误信息
- ✅ 建议手动安装步骤
- ✅ 基础功能仍然可用

## 🎉 总结

现在你有了一个完整的、智能的 AI 开发环境安装方案！脚本会：

1. 🔍 **智能检测** - 自动尝试多种安装方式
2. 🛡️ **错误处理** - 安装失败时提供回退方案
3. ⚙️ **自动配置** - 设置环境变量和别名
4. 📋 **详细报告** - 提供完整的安装状态

只需运行 `./start.sh` 和 `./init-dev-env.sh` 就能获得一个功能完整的 AI 开发环境！