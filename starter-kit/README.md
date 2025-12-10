# スターターキット

プロジェクト立ち上げに必要なテンプレートと設定ファイルを含みます。

## 内容

- **config/**: GitHub Actions、Docker Compose、環境変数テンプレート
- **templates/**: Issue、PR、Dockerfile、ワークフロー テンプレート
- **scripts/**: セットアップ、検証、デプロイスクリプト
- **docs/**: 詳細なドキュメント
- **examples/**: Python、bash、YAML の実装例

## クイックスタート

```bash
# ZIP から展開
unzip starter-kit_YYYYMMDD_HHMMSS.zip

# セットアップ実行
bash scripts/setup.sh

# 環境設定
cp config/.env.example .env
# .env を編集して実際の値を設定

# 検証
bash scripts/validate.sh
```

## 詳細

各ディレクトリの説明は `scripts/README.md` と `docs/GETTING_STARTED.md` を参照してください。
