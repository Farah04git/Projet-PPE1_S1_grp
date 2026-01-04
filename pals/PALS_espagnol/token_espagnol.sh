#!/bin/bash

# ------------------------
# Tokenisation du corpus espagnol
# 1 mot par ligne
# lignes vides = frontières de phrases
# ------------------------

INPUT="corpus_espagnol_clean.txt"
OUTPUT="corpus_espagnol_token.txt"

# Vérification
if [ ! -f "$INPUT" ]; then
    echo "Erreur : $INPUT introuvable"
    exit 1
fi

echo "Tokenisation du corpus en cours..."

cat "$INPUT" |
sed 's/[^A-Za-zÁÉÍÓÚÜÑáéíóúüñ ]/ /g' |
sed 's/  */ /g' |
sed 's/^ //; s/ $//' |
awk '
NF==0 { print "" }
NF>0 {
    for (i=1; i<=NF; i++) print tolower($i)
    print ""
}
' > "$OUTPUT"

echo "Corpus tokenisé généré : $OUTPUT"
