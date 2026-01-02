#!/usr/bin/env bash

# se placer à la racine du projet
cd "$(dirname "$0")/../.." || exit 1

FOLDER=$1
URL_FILE=$2

if [ $# -ne 2 ]; then
    echo "Usage : $0 dossier fichier_url"
    exit 1
fi

N=1

while read -r URL; do

    # sécurité : arrêter si les fichiers source n'existent plus
    [[ -f dumps-text/français/fr-$N.txt ]] || break
    [[ -f contextes/français/contxt_fr-$N.txt ]] || break

    : > "$FOLDER/dump-pals/dump-pals-fr-$N.txt"
    : > "$FOLDER/contextes-pals/contextes-pals-fr-$N.txt"

    tr -cs "[:alpha:]." "\n" < dumps-text/français/fr-$N.txt \
      | sed 's/\./\n/g' \
      >> "$FOLDER/dump-pals/dump-pals-fr-$N.txt"

    tr -cs "[:alpha:]." "\n" < contextes/français/contxt_fr-$N.txt \
      | sed 's/\./\n/g' \
      >> "$FOLDER/contextes-pals/contextes-pals-fr-$N.txt"

    ((N++))

done < "$URL_FILE"
