# Guide sans prétention du photovoltaïque

Code source permettant de participer et générer le `Guide sans prétention du photovoltaïque`.

Ce document est licencié sous Attribution-NonCommercial-ShareAlike 4.0 International © 2024 by Emeric MARTINEAU.

Vous pouvez avoir une copie de cette licence sur http://creativecommons.org/licenses/by-nc-sa/4.0/.

Vous êtes autorisé à :

 * Partager — copier, distribuer et communiquer le matériel par tous moyens et sous tous formats
 * Adapter — remixer, transformer et créer à partir du matériel
 * L'Offrant ne peut retirer les autorisations concédées par la licence tant que vous appliquez les termes de cette licence.

Selon les conditions suivantes :

 * Attribution — Vous devez créditer l'œuvre, intégrer un lien vers la licence et indiquer si des modifications ont été effectuées à l'œuvre. Vous devez indiquer ces informations par tous les moyens raisonnables, sans toutefois suggérer que l'Offrant vous soutient ou soutient la façon dont vous avez utilisé son œuvre.
 * Pas d'Utilisation Commerciale — Vous n'êtes pas autorisé à faire un usage commercial de cette œuvre, tout ou partie du matériel la composant.
 * Partage dans les Mêmes Conditions — Dans le cas où vous effectuez un remix, que vous transformez, ou créez à partir du matériel composant l'œuvre originale, vous devez diffuser l'œuvre modifiée dans les même conditions, c'est à dire avec la même licence avec laquelle l'œuvre originale a été diffusée.
 * Pas de restrictions complémentaires — Vous n'êtes pas autorisé à appliquer des conditions légales ou des mesures techniques qui restreindraient légalement autrui à utiliser l'œuvre dans les conditions décrites par la licence.

## Consignes de développement

Le mieux est d'avoir [Docker](https://docker.io) installé sur son PC.
Ensuite, dans le répertoire racine des sources, builder l'image avec la commande ci-dessous :
```
docker image build . -t guide-photovoltaique:latest
```

Ensuite toujours dans le même répertoire, lancez le container :
```
docker container run \
  -it \
  --rm \
  -v "${PWD}:/data" \
  -u $(id -u ${USER}):$(id -g ${USER}) \
  guide-photovoltaique:latest

I have no name!@4711b393b7a1:/data$
```

### Génération du PDF

Exécutez le commande suivante dans le container :
```
asciidoctor-pdf --out-file guide-photovoltaique.pdf -d book index-pdf.asciidoc
```

### Génération du site web

Exécutez les commandes suivantes dans le container :
```
rm -rf _site

./generate.sh
```

### Minimifier le site

```
EXT_FILE='js'

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
  --file-ext "${EXT_FILE}" \
  --input-dir _site/ \
  --output-dir _site2/
```
