#!/bin/bash

# ------------------------
# Script pour nettoyer le corpus espagnol
# ------------------------

INPUT="./corpus_espagnol.txt"
OUTPUT="./corpus_espagnol_clean.txt"

# Vérification
if [ ! -f "$INPUT" ]; then
    echo "Erreur : fichier '$INPUT' introuvable."
    exit 1
fi

# Nettoyage
cat "$INPUT" \
| tr '[:upper:]' '[:lower:]' \
| sed 's/[^a-záéíóúüñ ]//g' \
| tr -s ' ' \
| sed '/^$/d' \
> "$OUTPUT"

echo ">>> Corpus nettoyé généré : $OUTPUT"
