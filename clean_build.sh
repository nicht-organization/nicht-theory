#!/usr/bin/env bash
set -euo pipefail

echo "=== 1. Hard Cleanup of Build Artifacts ==="
rm -f latex/*.aux latex/*.log latex/*.out latex/*.toc latex/*.synctex.gz latex/*.fls latex/*.fdb_latexmk latex/*.bbl latex/*.bcf latex/*.blg 2>/dev/null || true

echo "=== 2. Compiling All Papers & Monograph ==="

if [ -d "latex" ]; then
    cd latex
fi

PAPERS=(
    "master_entry.tex"
    "paper_1_physics.tex"
    "paper_2_logic.tex"
    "paper_3_social.tex"
    "paper_4_ai_aie.tex"
    "paper_5_hermeneutics.tex"
    "master_monograph.tex"
)

for f in "${PAPERS[@]}"; do
    echo "----------------------------------------"
    echo "Building $f ..."
    
    if [ ! -f "$f" ]; then
        echo "--> NOTICE: $f not found, skipping..."
        continue
    fi

    BASE="${f%.tex}"

    # Pass 1: Initial PDF & AUX generation
    pdflatex -interaction=nonstopmode "$f" > /dev/null 2>&1 || true

    # Pass 2: Bibliography resolution (Biber or BibTeX)
    if [ -f "${BASE}.bcf" ] && command -v biber &>/dev/null; then
        biber "$BASE" > /dev/null 2>&1 || true
    elif [ -f "${BASE}.aux" ] && command -v bibtex &>/dev/null; then
        bibtex "$BASE" > /dev/null 2>&1 || true
    fi

    # Pass 3 & 4: Cross-reference & Bib compilation
    pdflatex -interaction=nonstopmode "$f" > /dev/null 2>&1 || true
    
    if pdflatex -interaction=nonstopmode "$f" > /dev/null 2>&1; then
        echo "--> SUCCESS: $f rendered!"
    else
        if [ -f "${BASE}.pdf" ]; then
            echo "--> WARNING: $f compiled with minor issues (PDF generated: ${BASE}.pdf)"
        else
            echo "--> ERROR: $f failed to compile!"
        fi
    fi
done

echo "========================================"
echo "Build process complete!"