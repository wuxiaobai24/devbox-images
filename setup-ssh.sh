#!/bin/bash

# SSH 配置设置脚本
echo "设置 SSH 配置..."

# 创建 SSH 目录
mkdir -p ssh

# 生成 SSH 密钥对（如果不存在）
if [ ! -f ssh/id_rsa ]; then
    ssh-keygen -t rsa -b 4096 -f ssh/id_rsa -N "" -C "devuser@devbox"
    echo "已生成新的 SSH 密钥对"
fi

# 复制公钥到 authorized_keys
cp ssh/id_rsa.pub ssh/authorized_keys

# 设置正确的权限
chmod 600 ssh/id_rsa
chmod 644 ssh/id_rsa.pub
chmod 600 ssh/authorized_keys

echo "SSH 配置完成"
echo "私钥位置: ssh/id_rsa"
echo "公钥位置: ssh/id_rsa.pub"
echo "请将私钥添加到你的 SSH 配置中"