#!/usr/bin/env bash

FINAL_FILENAME="guide-photovoltaique"
FINAL_MARKDOWN_FILENAME="${FINAL_FILENAME}.md"

GITHUB_PAGES_FILENAME="gh-pages-index.md"

# $1: title
convert_markdown_title_to_html_internal_anchor() {
  echo -n "$1" | sed -E 's/^#{1,6}\s+//g' | jq -sRr @uri
}

# $1: title
convert_markdown_title_to_title_with_internal_anchor() {
  local anchor_name

  anchor_name="$(convert_markdown_title_to_html_internal_anchor "$1")"

  echo "${1}<a name=\"${anchor_name}\"></a>"
}

# $1: title
convert_markdown_title_to_index() {
  # First get level of title
  local title_level
  local title_name
  local anchor_name

  title_level="$(echo -n "$1" | sed -E 's/(#{1,6})(.*)/\1/g' | wc -c)"
  title_name="$(echo -n "$1" | sed -E 's/#{1,6}\s+//g')"
  anchor_name="$(convert_markdown_title_to_html_internal_anchor "$1")"

  for (( c=1; c<=title_level-1; c++)); do
    echo -n '  '
  done
  echo "* [${title_name}](#${anchor_name})"
}

# $1: file to read
convert_all_title() {
    (
    IFS=$'\n'
    for line in $(grep -E '^#{1,6}' "$1"); do
        convert_markdown_title_to_index "${line}"
    done
    )
}

# $1: file to read
add_to_each_title_an_internal_anchor() {
  local is_title

  while IFS= read -r line; do
      is_title="$(echo "${line}" | grep -E '^#{1,6}')"

      if [ -n "${is_title}" ]; then
          convert_markdown_title_to_title_with_internal_anchor "${line}"
      else
          echo "${line}"
      fi
  done < "${file}"
}

IS_PANDOC_INSTALLED="$(pandoc --version 2>/dev/null | wc -l)"
IS_PDFLATEX_INSTALLED="$(pdflatex --version 2>/dev/null | wc -l)"
IS_JQ_INSTALLED="$(jq --version 2>/dev/null | wc -l)"

if [ "${IS_PANDOC_INSTALLED}" -lt 1 ] || [ "${IS_PDFLATEX_INSTALLED}" -lt 1 ] || [ "${IS_JQ_INSTALLED}" -lt 1 ]; then
  echo "** ERROR **" >&2
  echo "You must install pandoc and jq" >&2
fi

# List markdown file
FILES_LIST="$(ls -v [0-9]*.md)"
GENERATED_DATE="$(date '+%d/%m/%Y %H:%M:%S') - $(git describe --tags --abbrev=0)"

echo "1 - Site internet"

echo "  1.1 - Génération de la table de matière"

# Table of content for website
for file in ${FILES_LIST}; do
  convert_all_title "$file" >> "${GITHUB_PAGES_FILENAME}"
done

echo '' >> "${GITHUB_PAGES_FILENAME}" 

echo "  1.2 - Concaténation de tous les fichiers"

for file in ${FILES_LIST}; do
  add_to_each_title_an_internal_anchor "${file}" >> "${GITHUB_PAGES_FILENAME}"
  echo '' >> "${GITHUB_PAGES_FILENAME}" 
done

echo "2 - PDF"

echo "  2.1 - Création du fichier '${FINAL_MARKDOWN_FILENAME}'"

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

echo "  2.2 - Concaténation de tous les fichiers"

for file in ${FILES_LIST}; do
  cat "${file}" >> "${FINAL_MARKDOWN_FILENAME}"
  echo ''>> "${FINAL_MARKDOWN_FILENAME}"
  {
    echo '\pagebreak'
    echo ''
  } >> "${FINAL_MARKDOWN_FILENAME}"
done

echo "  2.3 - Génération du PDF"

pandoc \
       -V geometry:margin=1.5cm \
       -V block-headings \
       --table-of-contents \
       -t pdf \
       -f markdown \
       -o "${FINAL_FILENAME}.pdf" \
       "${FINAL_MARKDOWN_FILENAME}"

rm -rf "${FINAL_MARKDOWN_FILENAME}"
