#!/bin/bash

CORPUS="test.txt"
MOT="sino"
SORTIE="test_clean.txt"

# Supprimer les lignes contenant exactement le mot (insensible à la casse),
# en ignorant les espaces et retours chariot Windows
sed "s/^[[:space:]]*//; s/[[:space:]]*$//" "$CORPUS" | grep -vi -x "$MOT" > "$SORTIE"

echo "Le mot '$MOT' a été supprimé de toutes les lignes. Résultat : $SORTIE"
