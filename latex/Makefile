# -*- Makefile -*-
# LaTeX ビルド用 Makefile
# 用途: guide.tex を PDF にビルドし、中間ファイルを管理する
#
# 使い方:
#   make          - PDF をビルド（pdflatex を2回実行）
#   make clean    - ビルド中間ファイルを削除
#   make distclean - 最終 PDF も含めて全削除
#   make latexmk  - latexmk を使用したビルド（推奨）

# TeX ソースファイル
MAIN = guide.tex

# 出力 PDF
PDF = guide.pdf

# 中間ファイルの拡張子（削除対象）
AUXFILES = aux log out bbl blg toc lot lof

# デフォルトターゲット
.PHONY: all
all: pdf

# pdflatex を2回実行してビルド
# 注意: -interaction=nonstopmode でエラー時も途中で止まらない
.PHONY: pdf
pdf: $(PDF)

$(PDF): $(MAIN)
	@echo "Building $(PDF) using pdflatex (1st pass)..."
	pdflatex -interaction=nonstopmode $(MAIN)
	@echo "Building $(PDF) using pdflatex (2nd pass)..."
	pdflatex -interaction=nonstopmode $(MAIN)
	@echo "$(PDF) built successfully."

# latexmk を使用したビルド（推奨、参照が自動で確定）
.PHONY: latexmk
latexmk:
	@echo "Building $(PDF) using latexmk..."
	latexmk -pdf -interaction=nonstopmode $(MAIN)
	@echo "$(PDF) built successfully with latexmk."

# 中間ファイルを削除（PDF は保持）
.PHONY: clean
clean:
	@echo "Cleaning intermediate files..."
	@for ext in $(AUXFILES); do \
		rm -f *.$$ext; \
	done
	@rm -f $(MAIN:.tex=.fls) $(MAIN:.tex=.fdb_latexmk)
	@echo "Cleaned."

# PDF を含めて全削除
.PHONY: distclean
distclean: clean
	@echo "Removing PDF..."
	rm -f $(PDF)
	@echo "Distclean complete."

# ビルド状態を表示
.PHONY: status
status:
	@echo "Main file: $(MAIN)"
	@echo "Output PDF: $(PDF)"
	@if [ -f $(PDF) ]; then \
		echo "PDF exists: $$(ls -lh $(PDF) | awk '{print $$5, $$6, $$7, $$8}')"; \
	else \
		echo "PDF not found."; \
	fi

# ヘルプ
.PHONY: help
help:
	@echo "LaTeX Build Makefile"
	@echo ""
	@echo "Targets:"
	@echo "  make              - Build PDF (pdflatex x2)"
	@echo "  make latexmk      - Build PDF using latexmk (recommended)"
	@echo "  make clean        - Remove intermediate files (keep PDF)"
	@echo "  make distclean    - Remove all files including PDF"
	@echo "  make status       - Show build status"
	@echo "  make help         - Display this help"
