#!/bin/bash

# ------------------------
# Script : Nuage de mots espagnol avec stopwords
# ------------------------

# dossiers et fichiers
DUMP_DIR="../dumps-text/espagnol"
CORPUS="./corpus_espagnol.txt"
NUAGE_IMG="./nuages/espagnol/nuage_espagnol.png"
STOPWORDS="./stopwords-es.txt"

# ------------------------
# Vérifications
# ------------------------
if [ ! -d "$DUMP_DIR" ]; then
    echo "Erreur : le dossier '$DUMP_DIR' n'existe pas."
    exit 1
fi

if ! ls "$DUMP_DIR"/es-*.txt 1> /dev/null 2>&1; then
    echo "Erreur : aucun fichier es-*.txt trouvé dans '$DUMP_DIR'."
    exit 1
fi

if [ ! -f "$STOPWORDS" ]; then
    echo "Erreur : le fichier stopwords '$STOPWORDS' n'existe pas."
    exit 1
fi

# ------------------------
# Fusionner tous les fichiers en un corpus
# ------------------------
cat "$DUMP_DIR"/es-*.txt > "$CORPUS"
echo ">>> Corpus fusionné créé : $CORPUS"

# ------------------------
# Générer le nuage de mots
# ------------------------
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
