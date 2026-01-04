#!/bin/bash

INPUT="./corpus_espagnol_clean.txt"
OUTPUT="./corpus_espagnol_strict.txt"

cat "$INPUT" | tr '[:upper:]' '[:lower:]' \
    | sed 's/http[^ ]*//g' \
    | sed 's/www\.[^ ]*//g' \
    | sed 's/[0-9]\+//g' \
    | sed 's/[^a-záéíóúüñ ]//g' \
    | sed 's/  */ /g' \
    | sed '/^$/d' \
    > "$OUTPUT"

echo "Corpus strict généré : $OUTPUT"
