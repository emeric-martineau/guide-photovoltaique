#!/usr/bin/env bash

FINAL_FILENAME="guide-photovoltaique"
FINAL_MARKDOWN_FILENAME="${FINAL_FILENAME}.md"

GITHUB_PAGES_FILENAME="gh-pages-index.md"

IS_PANDOC_INSTALLED="$(pandoc --version 2>/dev/null | wc -l)"
IS_PDFLATEX_INSTALLED="$(pdflatex --version 2>/dev/null | wc -l)"

if [ "${IS_PANDOC_INSTALLED}" -lt 1 ] || [ "${IS_PDFLATEX_INSTALLED}" -lt 1 ]; then
  echo "** ERROR **" >&2
  echo "You must install pandoc" >&2
fi

# List markdown file
FILES_LIST="$(ls -v [0-9]*.md)"
GENERATED_DATE="$(date '+%d-%m-%Y %H:%M:%S')"

echo "1 - Création du fichier '${FINAL_MARKDOWN_FILENAME}'"

cat << EOF > "${FINAL_MARKDOWN_FILENAME}"
---
title: "Guide sans prétention du photovoltaïque"
author:
    - Emeric MARTINEAU
date: ${GENERATED_DATE}
titlepage: true
header-includes: |
  \usepackage{fancyhdr}
  \usepackage{lastpage}
  \pagestyle{fancy}
  \fancyhead[L]{}
  \fancyhead[R]{}
  \fancyfoot[C]{\thepage\ sur \pageref{LastPage}}
  \usepackage{float}
  \let\origfigure\figure
  \let\endorigfigure\endfigure
  \renewenvironment{figure}[1][2] {
      \expandafter\origfigure\expandafter[H]
  } {
      \endorigfigure
  }
---

EOF

echo "2 - Génération de la table de matière"

# For each, generate table of content
for file in ${FILES_LIST}; do
  grep -E '^#{1,6}' "${file}" | \
    sed 's/######/       */g' | \
    sed 's/#####/      */g' | \
    sed 's/####/     */g' | \
    sed 's/###/    */g' | \
    sed 's/##/  */g' | \
    sed 's/#/*/g' | tee -a "${GITHUB_PAGES_FILENAME}" "${FINAL_MARKDOWN_FILENAME}" > /dev/null
done

echo '' | tee -a "${FINAL_MARKDOWN_FILENAME}" "${GITHUB_PAGES_FILENAME}" > /dev/null
echo '\pagebreak' >> "${FINAL_MARKDOWN_FILENAME}"
echo '' >> "${FINAL_MARKDOWN_FILENAME}"

echo "3 - Concaténation de tous les fichiers"

for file in ${FILES_LIST}; do
  cat "${file}" | tee -a "${FINAL_MARKDOWN_FILENAME}" "${GITHUB_PAGES_FILENAME}" > /dev/null
  echo '' | tee -a "${FINAL_MARKDOWN_FILENAME}" "${GITHUB_PAGES_FILENAME}" > /dev/null
  echo '\pagebreak' >> "${FINAL_MARKDOWN_FILENAME}"
  echo '' >> "${FINAL_MARKDOWN_FILENAME}"
done

echo "4 - Génération du PDF"

pandoc \
       -V geometry:margin=1.5cm \
       -V block-headings \
       -t pdf \
       -f markdown \
       -o "${FINAL_FILENAME}.pdf" \
       "${FINAL_MARKDOWN_FILENAME}"

rm -rf "${FINAL_MARKDOWN_FILENAME}"
