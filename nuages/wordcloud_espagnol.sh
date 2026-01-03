#!/bin/bash

# ------------------------
# Script : Nuage de mots espagnol
# ------------------------

# dossiers

DUMP_DIR="../dumps-text/espagnol"
NUAGES_DIR="../../nuages"

# fichier temporaire fusionné (corpus)

CORPUS="$NUAGES_DIR/corpus_espagnol.txt"

# image finale

NUAGE_IMG="$NUAGES_DIR/nuage_espagnol.png"


# Vérifications

if [ ! -d "$DUMP_DIR" ]; then
    echo "Erreur : le dossier '$DUMP_DIR' n'existe pas."
    exit 1
fi

mkdir -p "$NUAGES_DIR"

if ! ls "$DUMP_DIR"/es-*.txt 1> /dev/null 2>&1; then
    echo "Erreur : aucun fichier es-*.txt trouvé dans '$DUMP_DIR'."
    exit 1
fi

# Fusionner tous les fichiers en un seul corpus

cat "$DUMP_DIR"/es-*.txt > "$CORPUS"
echo ">>> Corpus fusionné créé : $CORPUS"

# Générer le nuage de mots

wordcloud_cli --text "$CORPUS" --imagefile "$NUAGE_IMG"
echo ">>> Nuage de mots généré : $NUAGE_IMG"

# Ouvrir l'image automatiquement
open "$NUAGE_IMG" 2>/dev/null || xdg-open "$NUAGE_IMG" 2>/dev/null
