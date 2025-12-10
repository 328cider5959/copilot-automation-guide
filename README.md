# Copilot 完全自動化ガイド 最終版

[![CI/CD](https://github.com/your-org/copilot-automation-guide/actions/workflows/build.yml/badge.svg)](https://github.com/your-org/copilot-automation-guide/actions)
[![Docker Image](https://img.shields.io/badge/docker-GHCR-blue)](https://ghcr.io/your-org/copilot-automation)
[![Power Automate](https://img.shields.io/badge/Power%20Automate-Connected-green)](https://powerautomate.microsoft.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

## 📋 目次

- [概要](#概要)
- [特徴](#特徴)
- [インストール](#インストール)
- [使い方](#使い方)
- [ワークフロー図](#ワークフロー図)
- [Copilot プロンプト集](#copilot-プロンプト集)
- [English](#english)

## 概要

このプロジェクトは、**GitHub Copilot、GitHub Actions、Docker、Power Automate** を組み合わせた完全自動化ガイドです。LaTeX で PDF ドキュメント生成、OCR 処理、CI/CD パイプラインの構築を実現します。

### 対象ユーザー
- DevOps エンジニア
- 自動化担当者
- Copilot を活用したい開発者
- LaTeX 初心者から上級者まで

## 特徴

✅ **完全自動化パイプライン**
- GitHub Actions による CI/CD 自動化
- LaTeX から PDF 自動生成
- Docker コンテナ化と GHCR へのプッシュ
- Power Automate 連携による業務自動化

✅ **セキュリティ重視**
- GitHub Secrets によるシークレット管理
- Docker マルチステージビルド
- 依存関係の脆弱性スキャン

✅ **本番環境対応**
- 並列ジョブ実行
- キャッシュメカニズム
- エラーハンドリング完備

✅ **日本語対応**
- LaTeX 日本語フォント対応
- UTF-8 完全互換
- 日本語コメント付きコード

## インストール

### 前提条件

- **Git** 2.20+
- **Docker** 20.10+
- **Python** 3.9+
- **GitHub アカウント**（リポジトリ作成用）
- **Power Automate** アカウント（自動化用）

### 1. リポジトリクローン

```bash
git clone https://github.com/your-org/copilot-automation-guide.git
cd copilot-automation-guide
```

### 2. 必要なツールをインストール

```bash
# Python 依存関係
pip install -r requirements.txt

# Docker イメージビルド（オプション）
docker build -t copilot-automation:latest .
```

### 3. GitHub シークレット設定

リポジトリの **Settings → Secrets and variables → Actions** から以下を設定:

| シークレット名 | 値 | 説明 |
|---------------|-----|------|
| `GITHUB_TOKEN` | 自動 | GitHub アクション用トークン |
| `PAT_TOKEN` | Personal Access Token | GHCR プッシュ用 |
| `POWER_AUTOMATE_WEBHOOK` | Webhook URL | Power Automate トリガー URL |

### 4. Power Automate フロー設定

1. [Power Automate](https://powerautomate.microsoft.com) にアクセス
2. `power-automate/flow.json` をインポート
3. OneDrive 接続を設定

## 使い方

### LaTeX から PDF 生成

```bash
cd latex
pdflatex -interaction=nonstopmode guide.tex
pdflatex -interaction=nonstopmode guide.tex  # 目次生成用に 2 回実行
```

### スターターキット生成

```bash
bash scripts/generate-starter-kit.sh
```

出力：`starter-kit.zip` （`starter-kit/` フォルダを圧縮）

### Docker コンテナ実行

```bash
# OCR 処理実行
docker run --rm \
  -v $(pwd)/input:/app/input \
  -v $(pwd)/output:/app/output \
  copilot-automation:latest \
  python main.py

# 結果は output/ に保存
```

### GitHub Actions 手動トリガー

```bash
# リリース作成時に自動実行
git tag v1.0.0
git push origin v1.0.0
```

または Workflow dispatch でリモートからトリガー:

```
GitHub.com → Actions → Build and Deploy → Run workflow
```

## ワークフロー図

```
┌─────────────────────────────────────────────────────────────┐
│                    GitHub Actions Workflow                  │
└─────────────────────────────────────────────────────────────┘
         │
         ├─→ [Build LaTeX PDF] ──→ PDF ✓
         │
         ├─→ [Create Starter Kit] ──→ starter-kit.zip ✓
         │
         ├─→ [Upload Release] ──→ GitHub Release ✓
         │
         ├─→ [Build Docker Image] ──→ GHCR ✓
         │
         └─→ [Trigger Power Automate]
                    │
                    ├─→ OneDrive から Release ZIP 取得
                    ├─→ OCR 処理実行
                    └─→ CSV を OneDrive 保存 ✓

┌─────────────────────────────────────────────────────────────┐
│                  Parallel Job Execution                      │
├─────────────────────────────────────────────────────────────┤
│ Job 1: LaTeX Build        │ Job 2: Docker Build             │
│ ├─ Cache Dependencies     │ ├─ Cache Layers                 │
│ ├─ pdflatex (2x)         │ ├─ Build & Test                 │
│ └─ Upload Artifact       │ └─ Push to GHCR                 │
└─────────────────────────────────────────────────────────────┘
```

## Copilot プロンプト集

実際のプロジェクトで使用可能なプロンプト例：

### 1. LaTeX ドキュメント最適化

```
GitHub Copilot にこう聞く：
"このLaTeXファイルの日本語フォント設定を改善し、
 listings環境でコード表示が正しく行われるようにしてください。
 UTF-8対応で、目次の自動生成も追加してください。"
```

### 2. GitHub Actions ワークフロー

```
"複数の並列ジョブを持つ GitHub Actions ワークフローを作成してください。
 LaTeX PDF 生成、Docker イメージビルド、リリースアップロード、
 Power Automate トリガーを実行し、それぞれキャッシュを有効化してください。"
```

### 3. Docker マルチステージビルド

```
"Python 3.11 ベースで OCR 機能を持つ Docker イメージを作成してください。
 Tesseract、OpenCV、Pillow をインストールし、
 本番環境用に最適化（軽量化）してください。"
```

### 4. Power Automate フロー

```
"GitHub Release から ZIP ファイルをダウンロード、
 本体内のテキストファイルを OCR で処理し、
 結果を CSV に変換して OneDrive に保存する
 Power Automate フローを JSON 形式で作成してください。"
```

### 5. bash スクリプト作成

```
"starter-kit フォルダを ZIP ファイル化するbashスクリプトを作成してください。
 コメント付き、エラーハンドリング完備、
 Windows PowerShell でも動作するようにしてください。"
```

## セキュリティベストプラクティス

✅ **実装済みセキュリティ対策**

1. **シークレット管理**
   - `${{ secrets.* }}` で環境変数隠蔽
   - Personal Access Token (PAT) による認証
   - 定期的なトークンローテーション推奨

2. **コンテナセキュリティ**
   - マルチステージビルド（本番サイズ最小化）
   - `RUN --mount=type=cache` で依存関係キャッシュ
   - Alpine ベースイメージ使用可能

3. **アーティファクト管理**
   - 署名付きリリース
   - SBOM (Software Bill of Materials) 生成
   - スキャンとレポート自動化

4. **アクセス制御**
   - GitHub Environments による環境分離
   - OIDC による認証（キー不要）
   - 最小権限原則 (Least Privilege)

## 構成ファイル一覧

```
copilot-automation-guide/
├── README.md                          # このファイル
├── LICENSE                            # MIT ライセンス
├── .gitignore                         # Git 除外設定
├── requirements.txt                   # Python 依存関係
├── Dockerfile                         # Docker イメージ定義
│
├── .github/
│   └── workflows/
│       └── build.yml                  # CI/CD パイプライン
│
├── latex/
│   ├── guide.tex                      # LaTeX メインドキュメント
│   ├── preamble.tex                   # プリアンブル（フォント設定等）
│   └── sections/                      # 各セクション
│       ├── 01-overview.tex
│       ├── 02-starter-kit.tex
│       ├── 03-zip-script.tex
│       ├── 04-github-actions.tex
│       ├── 05-dockerfile.tex
│       ├── 06-power-automate.tex
│       ├── 07-security.tex
│       ├── 08-manual.tex
│       └── 09-workflow.tex
│
├── starter-kit/                       # スターターキット（ZIP化対象）
│   ├── sample-config.yaml
│   ├── templates/
│   └── docs/
│
├── power-automate/
│   ├── flow.json                      # Power Automate フロー定義
│   └── README.md                      # セットアップガイド
│
└── scripts/
    └── generate-starter-kit.sh        # ZIP 生成スクリプト
```

## トラブルシューティング

### LaTeX コンパイルエラー

```bash
# エラー: "File `cjk.sty' not found"
# 解決策: TeX Live で CJK パッケージをインストール
tlmgr install cjk
```

### Docker ビルド失敗

```bash
# キャッシュをクリア
docker system prune -a

# ビルド再実行
docker build --no-cache -t copilot-automation:latest .
```

### Power Automate 接続エラー

1. Webhook URL が有効か確認
2. OneDrive 接続を再認証
3. アクションの出力をデバッグモードで確認

## ライセンス

このプロジェクトは [MIT License](LICENSE) の下に公開されています。

## 貢献

改善提案やバグ報告は [Issues](https://github.com/your-org/copilot-automation-guide/issues) でお願いします。

---

# English

## Overview

This project is a **Complete Automation Guide** combining **GitHub Copilot, GitHub Actions, Docker, and Power Automate**. It enables LaTeX PDF generation, OCR processing, and CI/CD pipeline construction.

## Features

✅ **Fully Automated Pipeline**
- CI/CD automation with GitHub Actions
- Automatic PDF generation from LaTeX
- Docker containerization and GHCR push
- Power Automate integration for business automation

✅ **Security-First**
- GitHub Secrets management
- Docker multi-stage build
- Dependency vulnerability scanning

✅ **Production-Ready**
- Parallel job execution
- Caching mechanisms
- Complete error handling

## Quick Start

```bash
git clone https://github.com/your-org/copilot-automation-guide.git
cd copilot-automation-guide
docker build -t copilot-automation:latest .
docker run --rm copilot-automation:latest
```

## Key Components

- **GitHub Actions Workflow** (`build.yml`): Orchestrates all build and deployment tasks
- **LaTeX Document** (`guide.tex`): Complete automation guide with code examples
- **Dockerfile**: Python + Tesseract OCR environment
- **Power Automate Flow**: JSON definition for business process automation
- **Starter Kit Script**: bash script to generate deployment package

## Documentation

See [Copilot プロンプト集](#copilot-プロンプト集) for ChatGPT/Copilot prompts.

## License

MIT License - See [LICENSE](LICENSE) file for details.

---

**最終更新**: 2025-12-10  
**バージョン**: 1.0.0  
**言語**: 日本語 / English
