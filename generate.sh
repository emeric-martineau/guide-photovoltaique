#!/usr/bin/env bash

FINAL_FILENAME="guide-photovoltaique"

IS_PANDOC_INSTALLED="$(pandoc --version 2>/dev/null | wc -l)"
IS_PDFLATEX_INSTALLED="$(pdflatex --version 2>/dev/null | wc -l)"
IS_JQ_INSTALLED="$(jq --version 2>/dev/null | wc -l)"

if [ "${IS_PANDOC_INSTALLED}" -lt 1 ] || [ "${IS_PDFLATEX_INSTALLED}" -lt 1 ] || [ "${IS_JQ_INSTALLED}" -lt 1 ]; then
  echo "** ERROR **" >&2
  echo "You must install pandoc and jq" >&2
fi

echo "1 - Site internet"

echo "  1.1 - Génération de la table de matière"


ADOC_FILE_LIST="$(ls -1 *.adoc | paste -sd "," -)"

./generate_website_menu.rb --template _layouts/menu.rhtml --output _includes/menu.html --file "${ADOC_FILE_LIST}"

echo "  1.2 - Génération du site web"

bundle install
bundle exec jekyll build

echo "2 - PDF"

asciidoctor-pdf --out-file guide-photovoltaique.pdf -d book index-pdf.asciidoc
