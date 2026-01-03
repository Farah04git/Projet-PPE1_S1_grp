#!/usr/bin/env bash

DUMP_DIR="./dumps-text/français"
OUTPUT_PATH="./concordances/français"
CONTEXT=10

REGEX='[eéèêEÉÈÊ][tT][aàAÀ][tT]s?(-[A-Za-zàâäéèêëïîôöùûüÿçÀÂÄÉÈÊËÏÎÔÖÙÛÜŸÇ]+)?'


# Traiter tous les fichiers dumps

for file in "$DUMP_DIR"/*.txt; do
    base=$(basename "$file" .txt)
    OUT_HTML="$OUTPUT_PATH/concordancier-$base.html"


# Tableau HTML concordancier

    TAB_CONC=$(
    echo "<!DOCTYPE html>"
    echo "<html>"
    echo "<head>"
    echo "<meta charset=\"utf-8\">"
    echo "<meta name="viewport" content="width=device-width, initial-scale=1">"
    echo "<title>Concordances</title>"
    echo '<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bulma@0.9.4/css/bulma.min.css">'
    echo "</head>"
    echo "<body>"
    echo '<section class="section">'
    echo '<div class="container">'
    echo '<nav class="breadcrumb" aria-label="breadcrumbs">'
    echo "<h1 class="title is-1">Concordances : $URL</h1>"
    echo '<table class="table is-striped is-hoverable is-fullwidth">'
    echo "<thead>"
    echo '<tr><th>Contexte gauche</th><th>Mot</th><th>Contexte droit</th></tr>'
    echo "</thead>"
    echo "<tbody>"
)

    echo "$TAB_CONC" > "$OUT_HTML"

    # Lecture de tt dans une seule variable, et normalisation pour enlever symboles parasites
    line=$(tr '\n' ' ' < "$file" | sed -E "s/-{2,}/ /g; s/[^[:alpha:]àâäéèêëïîôöùûüÿçÀÂÄÉÈÊËÏÎÔÖÙÛÜŸÇ'’-]/ /g; s/[[:space:]]+/ /g; s/^ | $//g")



    while [[ $line =~ $REGEX ]]; do
        mot_etat="${BASH_REMATCH[0]}"

        # Sépare gauche et droite
        left_part="${line%%$mot_etat*}"  # tt avant le mot
        right_part="${line#*$mot_etat}"  # tt après le mot



        # Champs gauche et droite
        left=$(echo "$left_part" | awk -v n=$CONTEXT '{start=NF-n+1; if(start<1) start=1; for(i=start;i<=NF;i++) printf "%s ", $i}')
        right=$(echo "$right_part" | awk -v n=$CONTEXT '{end=(NF<n?NF:n); for(i=1;i<=end;i++) printf "%s ", $i}')

        # Ajout de la ligne au tableau
        echo "<tr><td>${left}</td><td><strong>${mot_etat}</strong></td><td>${right}</td></tr>" >> "$OUT_HTML"


        # eviter boucle : supprime première occurence
        line="${line#*$mot_etat}"
    done

    # Fin HTML
    echo '</tbody>' >> "$OUT_HTML"
    echo '</table>' >> "$OUT_HTML"
    echo '</div>' >> "$OUT_HTML"
    echo '</section>' >> "$OUT_HTML"
    echo '</body>' >> "$OUT_HTML"
    echo '</html>' >> "$OUT_HTML"


done