#!/usr/bin/env bash

FINAL_FILENAME="guide-photovoltaique"

echo "1 - Site internet"

echo "  1.1 - Génération de la table de matière"


ADOC_FILE_LIST="$(ls -1 *.adoc | paste -sd "," -)"

./generate_website_menu.rb --output _includes/menu.html --file "${ADOC_FILE_LIST}"

echo "  1.2 - Génération du site web"

rm -rf _site

bundle install
bundle exec jekyll build

echo "  1.3 - Minimification du site"

for ext in html js css; do
  html-minifier \
    --collapse-whitespace \
    --remove-comments \
    --remove-optional-tags \
    --remove-redundant-attributes \
    --remove-script-type-attributes \
    --remove-tag-whitespace \
    --use-short-doctype \
    --minify-css true \
    --minify-js true \
    --file-ext "${ext}" \
    --input-dir _site/ \
    --output-dir _site2/
done

cp -rf _site2/* _site/

rm -rf _site2

echo "2 - PDF"

CURRENT_TAG="$(git describe --tags --abbrev=0)"
GENERATED_DATE="$(date '+%d/%m/%Y %H:%M:%S')"

asciidoctor-pdf \
  --out-file guide-photovoltaique.pdf \
  --doctype book \
  --attribute "scm-tag=${CURRENT_TAG}" \
  --attribute "generated-date=${GENERATED_DATE}" \
  index-pdf.asciidoc
