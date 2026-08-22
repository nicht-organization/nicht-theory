#!/usr/bin/env bash
# ==============================================================================
# Nicht-Theory — Monograph Local Clean & Double-Build Script
# ==============================================================================
set -euo pipefail

echo "=== 1. Hard Cleanup of Build Artifacts ==="
rm -f latex/*.aux latex/*.log latex/*.out latex/*.toc latex/*.synctex.gz latex/*.fls latex/*.fdb_latexmk latex/*.bbl latex/*.bcf latex/*.blg 2>/dev/null || true

echo "=== 2. Compiling Master Monograph (Pass 1 & Pass 2) ==="

if [ -d "latex" ]; then
    cd latex
fi

TARGET="master_monograph.tex"

if [ ! -f "$TARGET" ]; then
    echo "--> ERROR: $TARGET not found in $(pwd)!"
    exit 1
fi

echo "--> Pass 1/2: Generating initial layout and table of contents..."
pdflatex -interaction=nonstopmode "$TARGET" > /dev/null 2>&1 || true

echo "--> Pass 2/2: Resolving cross-references and hyperref targets..."
if pdflatex -interaction=nonstopmode "$TARGET" > /dev/null 2>&1; then
    echo "========================================"
    echo "--> SUCCESS: master_monograph.pdf compiled cleanly!"
    echo "========================================"
else
    if [ -f "master_monograph.pdf" ]; then
        echo "--> WARNING: master_monograph.pdf generated with minor warnings."
    else
        echo "--> ERROR: master_monograph.pdf failed to compile!"
        exit 1
    fi
fi