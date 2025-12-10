#!/bin/bash
# setup.sh
# プロジェクト初期セットアップスクリプト

set -euo pipefail

echo "=== プロジェクト セットアップ ==="

# Python 仮想環境
if ! [ -d "venv" ]; then
    echo "Python 仮想環境を作成中..."
    python3 -m venv venv
fi

source venv/bin/activate || . venv/Scripts/activate

# 依存関係インストール
echo "依存関係をインストール中..."
pip install --upgrade pip
if [ -f "requirements.txt" ]; then
    pip install -r requirements.txt
fi

# Git フック（オプション）
if [ -d ".git" ]; then
    echo "Git フックをセットアップ中..."
    git config core.hooksPath scripts
fi

echo "✓ セットアップ完了"
echo ""
echo "次のステップ:"
echo "1. .env ファイルを config/.env.example からコピーして編集"
echo "2. docker build -t myapp:latest ."
echo "3. bash scripts/validate.sh"
