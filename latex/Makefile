# -*- Makefile -*-
# 日本語対応 LaTeX ビルド用 Makefile
# latexmk + uplatex + dvipdfmx を使用（推奨）

MAIN = guide.tex
PDF = guide.pdf
AUXFILES = aux log out bbl blg toc lot lof fls fdb_latexmk dvi

.PHONY: all pdf clean distclean latexmk help

all: latexmk

# latexmkを使ってビルド（uplatex指定）
latexmk:
	@echo "Building $(PDF) using latexmk with uplatex..."
	latexmk -pdfdvi -e '$latex=q/uplatex/' $(MAIN)
	@echo "$(PDF) built successfully with latexmk."

# 手動ビルド（uplatex + dvipdfmx）
pdf: $(PDF)

$(PDF): $(MAIN)
	@echo "Building $(PDF) using uplatex..."
	uplatex -interaction=nonstopmode $(MAIN)
	@echo "Converting DVI to PDF using dvipdfmx..."
	dvipdfmx $(MAIN:.tex=.dvi)
	@echo "$(PDF) built successfully."

clean:
	@echo "Cleaning intermediate files..."
	@for ext in $(AUXFILES); do \
		rm -f *.$$ext; \
	done
	@echo "Cleaned."

distclean: clean
	@echo "Removing PDF..."
	rm -f $(PDF)
	@echo "Distclean complete."

help:
	@echo "Targets:"
	@echo "  make            - Build PDF using latexmk (recommended)"
	@echo "  make pdf        - Build PDF manually (uplatex + dvipdfmx)"
	@echo "  make clean      - Remove intermediate files"
	@echo "  make distclean  - Remove all files including PDF"