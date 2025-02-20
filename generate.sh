#!/usr/bin/env bash

FINAL_FILENAME="guide-photovoltaique"

echo "1 - Site internet"

echo "  1.1 - Génération de la table de matière"


ADOC_FILE_LIST="$(ls -1 *.adoc | paste -sd "," -)"

./generate_website_menu.rb --template _layouts/menu.rhtml --output _includes/menu.html --file "${ADOC_FILE_LIST}"

echo "  1.2 - Génération du site web"

bundle install
bundle exec jekyll build

echo "2 - PDF"

CURRENT_TAG="$(git describe --tags --abbrev=0)"
GENERATED_DATE="$(date '+%d/%m/%Y %H:%M:%S')"

asciidoctor-pdf \
  --out-file guide-photovoltaique.pdf \
  --doctype book \
  --attribute "scm-tag=${CURRENT_TAG}" \
  --attribute "generated-date=${GENERATED_DATE}" \
  index-pdf.asciidoc
