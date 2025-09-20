#!/usr/bin/env python3
"""
Dockerfile 构建过程模拟器
在没有 Docker 环境的情况下验证 Dockerfile 的逻辑
"""

import re
import sys
from pathlib import Path

class DockerfileSimulator:
    def __init__(self, dockerfile_path="Dockerfile"):
        self.dockerfile_path = dockerfile_path
        self.layers = []
        self.current_user = "root"
        self.workdir = "/"
        self.env_vars = {}
        self.exposed_ports = []
        self.volumes = []
        self.cmd = None
        self.entrypoint = None

    def parse_dockerfile(self):
        """解析 Dockerfile"""
        with open(self.dockerfile_path, 'r', encoding='utf-8') as f:
            content = f.read()

        # 移除注释
        lines = []
        for line in content.split('\n'):
            if line.strip().startswith('#'):
                continue
            if line.strip():
                lines.append(line.strip())

        # 处理多行指令
        instructions = []
        current_instruction = ""

        for line in lines:
            if line.endswith('\\'):
                current_instruction += line[:-1] + ' '
            else:
                current_instruction += line
                if current_instruction.strip():
                    instructions.append(current_instruction.strip())
                current_instruction = ""

        return instructions

    def simulate_instruction(self, instruction):
        """模拟单个指令的执行"""
        if instruction.startswith('FROM'):
            return self._simulate_from(instruction)
        elif instruction.startswith('RUN'):
            return self._simulate_run(instruction)
        elif instruction.startswith('ENV'):
            return self._simulate_env(instruction)
        elif instruction.startswith('WORKDIR'):
            return self._simulate_workdir(instruction)
        elif instruction.startswith('USER'):
            return self._simulate_user(instruction)
        elif instruction.startswith('EXPOSE'):
            return self._simulate_expose(instruction)
        elif instruction.startswith('CMD'):
            return self._simulate_cmd(instruction)
        elif instruction.startswith('ENTRYPOINT'):
            return self._simulate_entrypoint(instruction)
        elif instruction.startswith('COPY'):
            return self._simulate_copy(instruction)
        elif instruction.startswith('ADD'):
            return self._simulate_add(instruction)
        else:
            return f"⚠️  未识别的指令: {instruction[:20]}..."

    def _simulate_from(self, instruction):
        """模拟 FROM 指令"""
        image = instruction.split()[1]
        self.layers.append(f"FROM {image}")
        return f"📦 使用基础镜像: {image}"

    def _simulate_run(self, instruction):
        """模拟 RUN 指令"""
        cmd = instruction[3:].strip()

        # 检查常见的潜在问题
        issues = []

        # 检查是否有用户切换问题
        if 'ssh-keygen' in cmd and self.current_user != 'root':
            issues.append("⚠️  ssh-keygen 应该在 root 用户下运行")

        # 检查是否有多条命令
        if '&&' in cmd:
            cmd_count = cmd.count('&&') + 1
            issues.append(f"📊 包含 {cmd_count} 个命令")

        # 检查包管理
        if 'apt-get' in cmd:
            if 'update' in cmd and 'install' in cmd:
                issues.append("📦 同时更新和安装包")
            if 'rm -rf /var/lib/apt/lists/*' in cmd:
                issues.append("✅ 清理 apt 缓存")

        # 检查权限问题
        if 'chmod' in cmd and self.current_user != 'root':
            issues.append("⚠️  在非 root 用户下修改权限")

        result = f"🔧 RUN: {cmd[:50]}{'...' if len(cmd) > 50 else ''}"
        if issues:
            result += "\n   " + "\n   ".join(issues)

        self.layers.append(f"RUN ({self.current_user}) {cmd[:30]}...")
        return result

    def _simulate_env(self, instruction):
        """模拟 ENV 指令"""
        env_part = instruction[3:].strip()
        if '=' in env_part:
            key, value = env_part.split('=', 1)
            self.env_vars[key] = value
            return f"🌍 设置环境变量: {key}={value[:20]}{'...' if len(value) > 20 else ''}"
        return f"⚠️  ENV 指令格式错误: {env_part}"

    def _simulate_workdir(self, instruction):
        """模拟 WORKDIR 指令"""
        path = instruction[8:].strip()
        self.workdir = path
        return f"📁 设置工作目录: {path}"

    def _simulate_user(self, instruction):
        """模拟 USER 指令"""
        user = instruction[4:].strip()
        old_user = self.current_user
        self.current_user = user
        return f"👤 切换用户: {old_user} → {user}"

    def _simulate_expose(self, instruction):
        """模拟 EXPOSE 指令"""
        port = instruction[6:].strip()
        self.exposed_ports.append(port)
        return f"🔌 暴露端口: {port}"

    def _simulate_cmd(self, instruction):
        """模拟 CMD 指令"""
        cmd = instruction[3:].strip()
        self.cmd = cmd
        return f"🚀 设置默认命令: {cmd}"

    def _simulate_entrypoint(self, instruction):
        """模拟 ENTRYPOINT 指令"""
        entrypoint = instruction[9:].strip()
        self.entrypoint = entrypoint
        return f"🎯 设置入口点: {entrypoint}"

    def _simulate_copy(self, instruction):
        """模拟 COPY 指令"""
        parts = instruction[4:].strip().split()
        if len(parts) >= 2:
            src, dest = parts[0], parts[-1]
            return f"📋 复制文件: {src} → {dest}"
        return f"⚠️  COPY 指令格式错误"

    def _simulate_add(self, instruction):
        """模拟 ADD 指令"""
        parts = instruction[3:].strip().split()
        if len(parts) >= 2:
            src, dest = parts[0], parts[-1]
            return f"📦 添加文件: {src} → {dest}"
        return f"⚠️  ADD 指令格式错误"

    def simulate_build(self):
        """模拟完整的构建过程"""
        print("🐳 Dockerfile 构建过程模拟")
        print("=" * 50)

        try:
            instructions = self.parse_dockerfile()
        except FileNotFoundError:
            print("❌ Dockerfile 不存在")
            return False

        print(f"📄 解析到 {len(instructions)} 个指令")
        print()

        for i, instruction in enumerate(instructions, 1):
            print(f"步骤 {i}/{len(instructions)}:")
            try:
                result = self.simulate_instruction(instruction)
                print(result)
            except Exception as e:
                print(f"❌ 执行失败: {e}")
                return False
            print()

        print("📊 构建摘要:")
        print(f"   - 图层数量: {len(self.layers)}")
        print(f"   - 最终用户: {self.current_user}")
        print(f"   - 工作目录: {self.workdir}")
        print(f"   - 环境变量: {len(self.env_vars)} 个")
        print(f"   - 暴露端口: {', '.join(self.exposed_ports)}")
        print(f"   - 默认命令: {self.cmd or '无'}")
        print(f"   - 入口点: {self.entrypoint or '无'}")

        # 检查潜在问题
        issues = []

        # 检查用户切换逻辑
        if self.current_user != 'root' and self.cmd and 'sshd' in self.cmd:
            issues.append("⚠️  SSH 服务应该在 root 用户下启动")

        # 检查端口暴露
        if not self.exposed_ports:
            issues.append("⚠️  没有暴露端口")

        # 检查基础工具
        essential_tools = ['openssh-server', 'sudo', 'curl']
        found_tools = []
        for instruction in instructions:
            if instruction.startswith('RUN'):
                for tool in essential_tools:
                    if tool in instruction:
                        found_tools.append(tool)

        missing_tools = set(essential_tools) - set(found_tools)
        if missing_tools:
            issues.append(f"⚠️  可能缺少工具: {', '.join(missing_tools)}")

        if issues:
            print("\n⚠️  潜在问题:")
            for issue in issues:
                print(f"   {issue}")
        else:
            print("\n✅ 没有发现明显问题")

        print("\n🎉 模拟构建完成！")
        return True

if __name__ == "__main__":
    simulator = DockerfileSimulator()
    success = simulator.simulate_build()
    sys.exit(0 if success else 1)