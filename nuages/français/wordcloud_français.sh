#!/usr/bin/env bash

DUMP_DIR="./dumps-text/français"
CORPUS="./corpus_français.txt"
NUAGE_IMG="./nuages/français/nuage_français.png"
STOPWORDS="./nuages/français/stopwords-fr.txt"

if [ ! -d "$DUMP_DIR" ]; then
    echo "Erreur : le dossier '$DUMP_DIR' n'existe pas."
    exit 1
fi

if ! ls "$DUMP_DIR"/fr-*.txt 1> /dev/null 2>&1; then
    echo "Erreur : aucun fichier fr-*.txt trouvé dans '$DUMP_DIR'."
    exit 1
fi

if [ ! -f "$STOPWORDS" ]; then
    echo "Erreur : le fichier stopwords '$STOPWORDS' n'existe pas."
    exit 1
fi

# Fusion de tous les dumps dans un corpus
cat "$DUMP_DIR"/fr-*.txt > "$CORPUS"
echo ">>> Corpus fusionné créé : $CORPUS"

# Générer le nuage de mots
wordcloud_cli \
    --text "$CORPUS" \
    --imagefile "$NUAGE_IMG" \
    --stopwords "$STOPWORDS" \
    --width 800 \
    --height 600 \
    --background "white"

echo ">>> Nuage de mots généré : $NUAGE_IMG"

# Ouvrir l'image automatiquement
open "$NUAGE_IMG" 2>/dev/null || xdg-open "$NUAGE_IMG" 2>/dev/null
