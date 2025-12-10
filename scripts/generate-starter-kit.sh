#!/bin/bash
# -*- coding: utf-8 -*-
# generate-starter-kit.sh
# 目的: starter-kit フォルダを ZIP ファイルにパッケージング
# 特徴:
#   - .gitignore を参照して不要ファイルを除外
#   - UTF-8 (日本語) 対応
#   - エラーハンドリング付き
# 作成日: 2025-12-10
# 対応: bash 4.0+, Windows (WSL/Git Bash)

set -euo pipefail

# ===================================
# 設定
# ===================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
STARTER_KIT_DIR="$PROJECT_ROOT/starter-kit"
OUTPUT_DIR="$PROJECT_ROOT/output"
GITIGNORE_FILE="$PROJECT_ROOT/.gitignore"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
ZIP_NAME="starter-kit_${TIMESTAMP}.zip"
ZIP_PATH="$OUTPUT_DIR/$ZIP_NAME"

# ===================================
# 色付き出力（ANSI カラーコード）
# ===================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ===================================
# ロギング関数
# ===================================
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_debug() {
    if [ "${DEBUG:-0}" = "1" ]; then
        echo -e "${CYAN}[DEBUG]${NC} $1"
    fi
}

# ===================================
# エラーハンドラー
# ===================================
trap 'on_error $?' EXIT

on_error() {
    local error_code=$1
    if [ $error_code -ne 0 ]; then
        log_error "スクリプト実行中にエラーが発生しました (Exit code: $error_code)"
        exit $error_code
    fi
}

# ===================================
# 前提条件チェック
# ===================================
check_prerequisites() {
    log_info "前提条件をチェック中..."
    
    # zip コマンド確認
    if ! command -v zip &> /dev/null; then
        log_error "zip コマンドが見つかりません。インストールしてください。"
        exit 1
    fi
    log_debug "zip コマンド: $(command -v zip)"
    
    # スターターキット ディレクトリ確認
    if [ ! -d "$STARTER_KIT_DIR" ]; then
        log_error "スターターキット ディレクトリ $STARTER_KIT_DIR が見つかりません。"
        exit 1
    fi
    log_debug "スターターキット ディレクトリ: $STARTER_KIT_DIR"
    
    # bash バージョン確認（4.0+）
    if [ "${BASH_VERSINFO[0]}" -lt 4 ]; then
        log_warning "bash 4.0 以上推奨 (現在: $BASH_VERSION)"
    fi
    
    log_success "前提条件チェック完了"
}

# ===================================
# 出力ディレクトリ作成
# ===================================
prepare_output_dir() {
    log_info "出力ディレクトリを準備中..."
    
    if [ ! -d "$OUTPUT_DIR" ]; then
        mkdir -p "$OUTPUT_DIR"
        log_debug "出力ディレクトリを作成: $OUTPUT_DIR"
    fi
    
    # ディレクトリの書き込み権限確認
    if [ ! -w "$OUTPUT_DIR" ]; then
        log_error "出力ディレクトリに書き込み権限がありません: $OUTPUT_DIR"
        exit 1
    fi
    
    log_success "出力ディレクトリ準備完了: $OUTPUT_DIR"
}

# ===================================
# ファイル検証
# ===================================
validate_files() {
    log_info "スターターキット内のファイルを検証中..."
    
    # 推奨ファイル/ディレクトリ
    local required_files=(
        "README.md"
        "config"
        "templates"
        "scripts"
        "docs"
        "examples"
    )
    
    local missing_count=0
    
    for file in "${required_files[@]}"; do
        if [ ! -e "$STARTER_KIT_DIR/$file" ]; then
            log_warning "推奨ファイル/ディレクトリが見つかりません: $file"
            ((missing_count++))
        else
            log_debug "✓ $file"
        fi
    done
    
    if [ $missing_count -gt 0 ]; then
        log_warning "$missing_count 個の推奨ファイルが見つかりません (続行します)"
    fi
    
    log_success "ファイル検証完了"
}

# ===================================
# .gitignore からパターンを読み込み
# ===================================
read_gitignore_patterns() {
    # .gitignore ファイルから除外パターンを読み込み、zip の -x オプション形式に変換
    local patterns=()
    
    if [ -f "$GITIGNORE_FILE" ]; then
        log_debug ".gitignore を読み込み: $GITIGNORE_FILE"
        
        # コメント行と空行を除外して読み込み
        while IFS= read -r line; do
            # コメント行と空行をスキップ
            [[ "$line" =~ ^[[:space:]]*# ]] && continue
            [[ -z "$line" ]] && continue
            
            # パターンを starter-kit/ 相対パスに変換
            # 例: ".DS_Store" -> "starter-kit/.DS_Store"
            local pattern="starter-kit/$line"
            patterns+=("$pattern")
            log_debug "除外パターン: $pattern"
        done < "$GITIGNORE_FILE"
    else
        log_warning ".gitignore が見つかりません: $GITIGNORE_FILE"
    fi
    
    # 配列を返す（bash では参照渡し使用）
    echo "${patterns[@]}"
}

# ===================================
# ZIP ファイル生成（.gitignore 参照版）
# ===================================
create_zip() {
    log_info "ZIP ファイルを生成中..."
    log_info "対象ディレクトリ: $STARTER_KIT_DIR"
    log_info "出力先: $ZIP_PATH"
    
    # 既存の ZIP を削除
    if [ -f "$ZIP_PATH" ]; then
        log_warning "既存 ZIP を削除: $ZIP_PATH"
        rm -f "$ZIP_PATH"
    fi
    
    # .gitignore からパターンを読み込み
    local exclude_patterns=()
    local gitignore_patterns=$(read_gitignore_patterns)
    
    # gitignore パターンを配列に追加
    if [ -n "$gitignore_patterns" ]; then
        while IFS= read -r pattern; do
            [ -z "$pattern" ] && continue
            exclude_patterns+=("$pattern")
        done <<< "$gitignore_patterns"
    fi
    
    # 追加の硬いコーディング除外パターン（重要なもの）
    local hardcoded_patterns=(
        "starter-kit/.git/*"
        "starter-kit/.gitignore"
        "starter-kit/.DS_Store"
        "starter-kit/__pycache__/*"
        "starter-kit/*.pyc"
    )
    
    for pattern in "${hardcoded_patterns[@]}"; do
        # 既に含まれていなければ追加
        if [[ ! " ${exclude_patterns[@]} " =~ " ${pattern} " ]]; then
            exclude_patterns+=("$pattern")
            log_debug "ハードコード除外パターン追加: $pattern"
        fi
    done
    
    # 除外オプション作成
    local exclude_opts=""
    for pattern in "${exclude_patterns[@]}"; do
        if [ -n "$pattern" ]; then
            exclude_opts="$exclude_opts -x $pattern"
        fi
    done
    
    cd "$PROJECT_ROOT" || { log_error "ディレクトリ移動に失敗"; exit 1; }
    log_debug "作業ディレクトリ: $(pwd)"
    log_info "除外パターン数: ${#exclude_patterns[@]}"
    
    # ZIP コマンド実行（UTF-8 ファイル名対応）
    if zip -r -q -u "$ZIP_PATH" "starter-kit/" $exclude_opts; then
        log_success "ZIP ファイル生成成功"
    else
        log_error "ZIP ファイル生成に失敗しました。"
        exit 1
    fi
    
    if [ -f "$ZIP_PATH" ]; then
        # ファイルサイズ表示
        local size=$(du -h "$ZIP_PATH" | cut -f1)
        log_success "ZIP ファイルサイズ: $size"
        log_debug "完全パス: $ZIP_PATH"
    else
        log_error "ZIP ファイルが生成されませんでした。"
        exit 1
    fi
}

# ===================================
# ZIP 内容確認
# ===================================
verify_zip() {
    log_info "ZIP ファイルの内容を検証中..."
    
    # ファイル数取得
    local file_count=$(unzip -l "$ZIP_PATH" | tail -1 | awk '{print $2}')
    log_info "ZIP に含まれるファイル数: $file_count"
    
    # 重要ファイル確認
    if unzip -l "$ZIP_PATH" | grep -q "README.md"; then
        log_success "✓ README.md が含まれています"
    else
        log_warning "⚠ README.md が見つかりません"
    fi
    
    if unzip -l "$ZIP_PATH" | grep -q "config/"; then
        log_success "✓ config/ ディレクトリが含まれています"
    else
        log_warning "⚠ config/ ディレクトリが見つかりません"
    fi
    
    log_success "ZIP 検証完了"
}

# ===================================
# チェックサム生成
# ===================================
generate_checksum() {
    log_info "チェックサムを生成中..."
    
    local checksum_file="$OUTPUT_DIR/${ZIP_NAME%.zip}.sha256"
    
    if command -v sha256sum &> /dev/null; then
        sha256sum "$ZIP_PATH" > "$checksum_file"
        log_success "SHA256 チェックサム生成: $(basename "$checksum_file")"
        log_debug "チェックサム: $(cut -d' ' -f1 "$checksum_file")"
    elif command -v shasum &> /dev/null; then
        shasum -a 256 "$ZIP_PATH" > "$checksum_file"
        log_success "SHA256 チェックサム生成: $(basename "$checksum_file")"
    else
        log_warning "チェックサム生成ツールが見つかりません。スキップします。"
    fi
}

# ===================================
# サマリー表示
# ===================================
print_summary() {
    log_info ""
    log_info "========================================"
    log_success "スターターキット ZIP 生成 完了！"
    log_info "========================================"
    log_info ""
    log_info "📦 出力ファイル:"
    log_info "   ZIP: $(basename "$ZIP_PATH")"
    
    if [ -f "$OUTPUT_DIR/${ZIP_NAME%.zip}.sha256" ]; then
        log_info "   SHA256: $(basename "$OUTPUT_DIR/${ZIP_NAME%.zip}.sha256")"
    fi
    
    log_info ""
    log_info "📍 出力ディレクトリ: $OUTPUT_DIR"
    log_info "📏 ファイルサイズ: $(du -h "$ZIP_PATH" | cut -f1)"
    log_info "🕐 生成日時: $(date '+%Y-%m-%d %H:%M:%S')"
    log_info ""
    log_info "✓ 次のステップ:"
    log_info "  1. ZIP ファイルを GitHub Release にアップロード"
    log_info "  2. Power Automate で処理を開始"
    log_info "  3. OneDrive で結果を確認"
    log_info ""
    log_info "========================================"
}

# ===================================
# メイン処理
# ===================================
main() {
    echo -e "${CYAN}"
    echo "========================================"
    echo "  Starter Kit ZIP 生成スクリプト"
    echo "========================================"
    echo -e "${NC}"
    
    check_prerequisites
    prepare_output_dir
    validate_files
    create_zip
    verify_zip
    generate_checksum
    print_summary
}

# メイン実行
main "$@"
