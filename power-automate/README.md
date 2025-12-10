# Power Automate フロー セットアップガイド

## 概要

このフロー定義は、GitHub Release から ZIP ファイルをダウンロード、OCR 処理を実行し、
結果を CSV 形式で OneDrive に保存します。

## セットアップ手順

### 1. Power Automate へのインポート

1. [Power Automate](https://powerautomate.microsoft.com) にログイン
2. **My flows** → **Create** → **Cloud flow** → **Instant cloud flow** → **Request**
3. フロー名: `Copilot Automation - Release OCR Pipeline`
4. **Create** をクリック

### 2. JSON エディタからインポート

1. **Editor** ボタンをクリック
2. 左ペインで **Code view** に切り替え
3. `flow.json` の内容をコピーして貼り付け
4. **Save**

### 3. コネクション設定

以下のコネクションを認証します：

#### GitHub コネクション

```json
{
  "type": "Http",
  "inputs": {
    "uri": "https://api.github.com/repos/...",
    "headers": {
      "Authorization": "token YOUR_GITHUB_TOKEN"
    }
  }
}
```

**設定方法:**
1. GitHub Personal Access Token (PAT) を生成
   - Settings → Developer settings → Personal access tokens
   - Scopes: `repo` (フルコントロール), `read:org`
2. Token をコピー
3. Power Automate フロー内で参照設定

#### OneDrive コネクション

1. **Add an action** → **OneDrive for Business**
2. **Save file** アクション選択
3. 認証を行う（Office 365 アカウント）

#### Outlook コネクション（Email 通知用）

1. **Add an action** → **Outlook.com** または **Office 365 Outlook**
2. **Send an email** アクション選択
3. 認証を行う（Office 365 アカウント）

### 4. パラメータ設定

フロー実行時に以下のパラメータが必要です：

| パラメータ | 説明 | 例 |
|-----------|------|-----|
| `tag` | GitHub Release タグ | `v1.0.0` |
| `repository` | リポジトリ名 | `owner/repo` |
| `releaseUrl` | Release URL | `https://github.com/owner/repo/releases/tag/v1.0.0` |
| `github_token` | GitHub Personal Access Token | `ghp_xxxxx` |

### 5. Webhook URL 取得

フロー保存後、トリガーセクションから **Webhook URL** をコピー：

```
https://prod-xx.westus.logic.azure.com/workflows/xxxxx/triggers/manual/paths/invoke?api-version=2016-06-01&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=xxxxx
```

このURL を GitHub Actions `secrets.POWER_AUTOMATE_WEBHOOK` に設定します。

## 実行フロー

### 正常系

```
トリガー (HTTP Request)
  ↓
変数初期化
  ↓
GitHub API: Release 情報取得
  ↓
ZIP ファイルを OneDrive に保存
  ↓
OCR 処理実行 (Docker)
  ↓
結果を CSV に変換
  ↓
CSV を OneDrive に保存
  ↓
成功メール送信 ✓
```

### エラー時

```
エラー発生
  ↓
エラーログ記録
  ↓
エラーメール送信（管理者へ）
  ↓
プロセス終了 ✗
```

## 必要な環境変数

`.env` ファイルまたは GitHub Secrets に設定:

```bash
# GitHub
GITHUB_TOKEN=ghp_xxxxxxxxxxxxx
GITHUB_REPO=owner/repo-name

# Power Automate
POWER_AUTOMATE_WEBHOOK=https://prod-xx.westus.logic.azure.com/...

# Docker / OCR サービス
DOCKER_OCR_ENDPOINT=https://your-docker-service.azurewebsites.net/api/ocr
DOCKER_API_KEY=xxxxxxxxxxxxx

# Email 通知
NOTIFICATION_EMAIL=user@example.com
ADMIN_EMAIL=admin@example.com
SENDER_EMAIL=noreply@example.com

# Logging
LOGGING_ENDPOINT=https://your-logging-service.azurewebsites.net/logs

# API
MICROSOFT_GRAPH_TOKEN=xxxxxxxxxxxxx
```

## トラブルシューティング

### エラー: "認証に失敗しました"

**原因**: GitHub Token が無効または期限切れ

**解決策**:
1. GitHub で新しい Personal Access Token を生成
2. GitHub Actions Secret `GITHUB_TOKEN` を更新
3. Power Automate フロー内で Token を再設定

### エラー: "OneDrive ファイル保存に失敗"

**原因**: OneDrive の接続切断またはディレクトリ非存在

**解決策**:
1. Power Automate で OneDrive コネクションを再認証
2. `/Copilot/Downloads` と `/Copilot/Results` フォルダが存在確認
3. フォルダなければ手動作成

### エラー: "OCR 処理がタイムアウト"

**原因**: Docker サービスが応答しない、処理が長時間

**解決策**:
1. Docker コンテナのヘルスを確認
2. `"timeout": "PT3600S"` をアクションに設定（1 時間）
3. ログを確認: `docker logs <container-id>`

### メール送信されない

**原因**: Outlook コネクション認証不足

**解決策**:
1. **Settings** → **Connections** で Outlook 再認証
2. フロー内の Outlook アクションで認証を確認
3. Email アドレスが正しく設定されているか確認

## セキュリティ考慮事項

✓ **実装済み:**
- GitHub Token は Power Automate Secret に保存
- Email には直接トークン表示なし
- エラーログにセンシティブ情報を記録しない
- OneDrive 上のファイルはアクセス制限

⚠ **推奨事項:**
- GitHub Token を 90 日ごとにローテーション
- OneDrive フォルダのアクセス権限を最小化
- OCR サービスエンドポイントに SSL/TLS 使用
- ログは定期的にアーカイブ・削除

## テスト方法

### 手動テスト

1. Power Automate フロー画面で **Test** をクリック
2. **Manually trigger a cloud flow** を選択
3. テストデータを入力:
   ```json
   {
     "tag": "v1.0.0",
     "repository": "owner/repo",
     "releaseUrl": "https://github.com/owner/repo/releases/tag/v1.0.0",
     "github_token": "your_token_here"
   }
   ```
4. **Test** をクリック
5. Run history で実行結果確認

### 本番テスト

GitHub Actions で実際のリリース作成時にトリガー:

```bash
git tag v1.0.0
git push origin v1.0.0
```

Power Automate の **Run history** でフロー実行を監視

## 参考リンク

- [Power Automate Documentation](https://docs.microsoft.com/en-us/power-automate/)
- [GitHub API Reference](https://docs.github.com/en/rest)
- [OneDrive API](https://docs.microsoft.com/en-us/onedrive/developer/)
- [Logic Apps Connector Reference](https://docs.microsoft.com/en-us/connectors/)

---

**作成日**: 2025-12-10  
**バージョン**: 1.0.0  
**言語**: 日本語
