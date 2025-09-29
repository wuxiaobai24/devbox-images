#!/bin/bash

# 批量修改 Git 历史提交中的邮箱地址
echo "📧 修改 Git 历史提交邮箱地址..."
echo "原邮箱: wuxiaobai24@example.com"
echo "新邮箱: wuxiaobai24@foxmail.com"
echo ""

# 确认操作
read -p "确认要修改所有历史提交的邮箱地址吗？(y/N): " confirm
if [[ $confirm != [yY] ]]; then
    echo "操作已取消"
    exit 0
fi

# 创建修改邮箱的脚本
cat > /tmp/change_email_filter.sh << 'EOF'
#!/bin/bash

# 修改作者邮箱
if [ "$GIT_AUTHOR_EMAIL" = "wuxiaobai24@example.com" ]; then
    export GIT_AUTHOR_EMAIL="wuxiaobai24@foxmail.com"
fi

# 修改提交者邮箱
if [ "$GIT_COMMITTER_EMAIL" = "wuxiaobai24@example.com" ]; then
    export GIT_COMMITTER_EMAIL="wuxiaobai24@foxmail.com"
fi
EOF

chmod +x /tmp/change_email_filter.sh

echo "🔄 开始修改历史提交..."
echo "这可能需要一些时间..."

# 执行 rebase 操作
git filter-branch --env-filter '
if [ "$GIT_AUTHOR_EMAIL" = "wuxiaobai24@example.com" ]; then
    export GIT_AUTHOR_EMAIL="wuxiaobai24@foxmail.com"
fi
if [ "$GIT_COMMITTER_EMAIL" = "wuxiaobai24@example.com" ]; then
    export GIT_COMMITTER_EMAIL="wuxiaobai24@foxmail.com"
fi
' -- --all

# 清理
echo "🧹 清理临时文件..."
rm -rf /tmp/change_email_filter.sh
git for-each-ref --format="%(refname)" refs/original/ | xargs -r git update-ref -d

echo "✅ 邮箱地址修改完成！"
echo ""
echo "📋 修改结果："
git log --oneline -5 | while read commit hash message; do
    author=$(git log -1 --format="%an | %ae" $hash)
    echo "  $hash | $author"
done

echo ""
echo "🔍 验证所有提交："
echo "  原邮箱出现次数: $(git log --format="%ae" | grep -c "wuxiaobai24@example.com" || echo "0")"
echo "  新邮箱出现次数: $(git log --format="%ae" | grep -c "wuxiaobai24@foxmail.com" || echo "0")"