#!/bin/bash

# ------------------------
# Script : Nuage de mots espagnol
# ------------------------

# dossier des fichiers texte
DUMP_DIR="../../dumps-text/espagnol"

# fichier temporaire fusionné
CORPUS="$DUMP_DIR/corpus_espagnol.txt"

# image finale
NUAGE_IMG="$DUMP_DIR/nuage_espagnol.png"

# fusionner tous les fichiers en un seul
cat "$DUMP_DIR"/es-*.txt > "$CORPUS"

# générer le nuage de mots
wordcloud_cli --text "$CORPUS" --imagefile "$NUAGE_IMG"

# ouvrir l'image
open "$NUAGE_IMG" 2>/dev/null || xdg-open "$NUAGE_IMG" 2>/dev/null
