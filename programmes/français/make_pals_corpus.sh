#!/usr/bin/env bash

# Placement à la racine
cd "$(dirname "$0")/../.." || exit 1

FOLDER=$1
URL_FILE=$2

if [ $# -ne 2 ]; then
    echo "Usage : dossier cible (pals), fichier_url"
    exit 1
fi

N=1

while read -r URL; do

    # Si fichier sources ! existe, arrête
    [[ -f dumps-text/français/fr-$N.txt ]] || break
    [[ -f contextes/français/contxt_fr-$N.txt ]] || break

    # Nettoyage si déjà écrit
    echo "" > "$FOLDER/dump-pals/dump-pals-fr-$N.txt"
    echo "" > "$FOLDER/contextes-pals/contextes-pals-fr-$N.txt"

    
    # Dumps
    tr -cs "[:alpha:]." "\n" < dumps-text/français/fr-$N.txt | sed 's/\./\n/g'  >> "$FOLDER/dump-pals/dump-pals-fr-$N.txt"

    # Contextes + Retrait marqueurs autour ..état.. dans contextes
   sed 's/\.\.\([^.]*\)\.\./\1/g' contextes/français/contxt_fr-$N.txt \
  | tr -cs "[:alpha:]." "\n" | sed 's/\./\n/g' >> "$FOLDER/contextes-pals/contextes-pals-fr-$N.txt"

    ((N++))

done < "$URL_FILE"
