#!/bin/bash
# validate.sh
# 設定ファイル及び環境の検証スクリプト

set -euo pipefail

echo "=== 設定 & 環境 検証 ==="

errors=0

# .env ファイル確認
if [ ! -f ".env" ]; then
    echo "✗ .env ファイルが見つかりません"
    ((errors++))
else
    echo "✓ .env ファイルが存在します"
fi

# Python 仮想環境確認
if [ -d "venv" ]; then
    echo "✓ Python 仮想環境が存在します"
else
    echo "✗ Python 仮想環境が見つかりません (setup.sh を実行してください)"
    ((errors++))
fi

# Docker確認（オプション）
if command -v docker &> /dev/null; then
    echo "✓ Docker がインストール済みです"
else
    echo "⚠ Docker がインストールされていません (オプション)"
fi

# Git リポジトリ確認
if [ -d ".git" ]; then
    echo "✓ Git リポジトリです"
else
    echo "⚠ Git リポジトリではありません"
fi

echo ""
if [ $errors -eq 0 ]; then
    echo "✓ すべての検証に合格しました"
    exit 0
else
    echo "✗ $errors 件のエラーがあります"
    exit 1
fi
