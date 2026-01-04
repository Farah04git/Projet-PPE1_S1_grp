#!/bin/bash

# ==================================================
# Script : filtrage des stopwords espagnols
# ==================================================

DIR="$(cd "$(dirname "$0")" && pwd)"

CORPUS_IN="$DIR/corpus_espagnol_token.txt"
STOPWORDS="$DIR/stopwords-es.txt"
CORPUS_OUT="$DIR/corpus_espagnol_final.txt"

# Vérifications
if [ ! -f "$CORPUS_IN" ]; then
    echo "Corpus introuvable"
    exit 1
fi

if [ ! -f "$STOPWORDS" ]; then
    echo "Fichier stopwords introuvable"
    exit 1
fi

echo "Filtrage des stopwords en cours..."

# Filtrage
grep -vwF -f "$STOPWORDS" "$CORPUS_IN" > "$CORPUS_OUT"

echo "Corpus filtré généré : $CORPUS_OUT"
