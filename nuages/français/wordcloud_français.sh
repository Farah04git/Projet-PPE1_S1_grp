#!/usr/bin/env bash

CORPUS="./"nuages/français/dumps_FR.txt
NUAGE_IMG="./nuages/français/nuage_français.png"
STOPWORDS="./nuages/français/stopwords-fr.txt"

if [ ! - "$CORPUS" ]; then
    echo "Erreur : le dossier '$CORPUS' n'existe pas."
    exit 1
fi

if [ ! -f "$STOPWORDS" ]; then
    echo "Erreur : le fichier stopwords '$STOPWORDS' n'existe pas."
    exit 1
fi



# Générer le nuage de mots
wordcloud_cli \
    --text "$CORPUS" \
    --imagefile "$NUAGE_IMG" \
    --stopwords "$STOPWORDS" \
    --mask "./nuages/français/fr_vector.jpg" \
    --width 800 \
    --height 600 \
    --background "white"

echo ">>> Nuage de mots généré : $NUAGE_IMG"

# Ouvrir l'image automatiquement
open "$NUAGE_IMG" 2>/dev/null || xdg-open "$NUAGE_IMG" 2>/dev/null
