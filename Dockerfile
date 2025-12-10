# Dockerfile
# Copilot 完全自動化ガイド - OCR 環境
# マルチステージビルド対応
# 作成日: 2025-12-10
# 言語: UTF-8

# ========================================
# ステージ 1: ビルドステージ
# ========================================
FROM python:3.11-slim as builder

LABEL maintainer="Copilot Automation <info@example.com>"
LABEL description="OCR Processing Environment for Copilot Automation"
LABEL version="1.0.0"

# 作業ディレクトリ設定
WORKDIR /build

# ビルド依存関係インストール
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    gcc \
    g++ \
    git \
    && rm -rf /var/lib/apt/lists/*

# Python 依存関係ダウンロード
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip setuptools wheel && \
    pip download --no-cache-dir \
    --dest /pip-packages \
    -r requirements.txt

# ========================================
# ステージ 2: ランタイムステージ（本番環境）
# ========================================
FROM python:3.11-slim

# メタデータ
ARG BUILD_DATE
ARG VCS_REF
LABEL org.label-schema.build-date=$BUILD_DATE
LABEL org.label-schema.vcs-ref=$VCS_REF
LABEL org.opencontainers.image.source="https://github.com/your-org/copilot-automation-guide"

# 非ルートユーザー作成（セキュリティ）
RUN groupadd -r appuser && useradd -r -g appuser appuser

# 作業ディレクトリ
WORKDIR /app

# システムパッケージをインストール（OCR+日本語対応）
RUN apt-get update && apt-get install -y --no-install-recommends \
    tesseract-ocr \
    tesseract-ocr-jpn \
    tesseract-ocr-eng \
    libtesseract-dev \
    leptonica-progs \
    libmagic1 \
    fonts-noto-cjk \
    && rm -rf /var/lib/apt/lists/*

# Python pip キャッシュ最適化
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install --upgrade pip setuptools wheel

# 依存関係インストール（キャッシュマウント使用）
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install --no-cache-dir \
    pytesseract==0.3.10 \
    pillow==10.0.0 \
    opencv-python==4.8.0.76 \
    numpy==1.24.3 \
    pandas==2.0.3 \
    pydantic==2.0.0 \
    python-dotenv==1.0.0 \
    requests==2.31.0

# requirements.txt がある場合はインストール
COPY requirements.txt .
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install --no-cache-dir -r requirements.txt || echo "requirements.txt not critical"

# アプリケーション コピー（.dockerignore で不要ファイル除外）
COPY --chown=appuser:appuser . .

# ディレクトリ作成とパーミッション設定
RUN mkdir -p /app/input /app/output /app/logs && \
    chown -R appuser:appuser /app && \
    chmod 755 /app/input /app/output /app/logs && \
    chmod 644 /app/*.py || true

# 非ルートユーザーに切り替え（セキュリティベストプラクティス）
USER appuser

# ヘルスチェック（コンテナの健全性監視）
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD python -c "import pytesseract; pytesseract.get_tesseract_version()" || exit 1

# デフォルトコマンド
ENTRYPOINT ["python"]
CMD ["main.py"]

# ========================================
# ステージ 3: テストステージ（オプション）
# ========================================
FROM python:3.11-slim as test

WORKDIR /app

# テストツール
RUN apt-get update && apt-get install -y --no-install-recommends \
    pytest \
    pytest-cov \
    && rm -rf /var/lib/apt/lists/*

# 依存関係コピー
COPY --from=builder /pip-packages /pip-packages
RUN pip install /pip-packages/* && \
    pip install pytest pytest-cov

# テストコード
COPY . .

# テスト実行
CMD ["pytest", "-v", "--cov=.", "tests/"]
