#!/bin/bash

# ------------------------
# Script pour l'espagnol – tableau complet stylé
# ------------------------

URL_FILE=$1
REGEX="[Ee]stado|[Ee]stados"

DIR_BASE="../.."
DIR_ASPI="$DIR_BASE/aspirations/espagnol"
DIR_CONTXT="$DIR_BASE/contextes/espagnol"
DIR_DUMP="$DIR_BASE/dumps-text/espagnol"
DIR_CONCORD="$DIR_BASE/concordances/espagnol"
DIR_HTML_OUT="$DIR_BASE/tableaux/estado_espagnol.html"

USER_AGENT="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"

# ------------------------
# Vérification
# ------------------------
if [ $# -ne 1 ]; then
    echo "Usage : $0 urls.txt"
    exit 1
fi
if [ ! -f "$URL_FILE" ]; then
    echo "Erreur : le fichier '$URL_FILE' n'a pas été trouvé"
    exit 1
fi

mkdir -p "$DIR_ASPI" "$DIR_CONTXT" "$DIR_DUMP" "$DIR_CONCORD" "$(dirname "$DIR_HTML_OUT")"

# ------------------------
# Tableau HTML
# ------------------------
cat <<EOT > "$DIR_HTML_OUT"
<!DOCTYPE html>
<html>
<head>
<title>Projet PPE-25/26 – espagnol</title>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bulma@1.0.2/css/bulma.min.css">
<style>
table { border-collapse: collapse; width: 100%; }
th, td { border: 1px solid #999; padding: 0.5em; }
th { font-weight: bold; }
.error { color: red; font-weight: bold; }
</style>
</head>
<body>
<h2 class="title">Tableau <code>espagnol</code></h2>
<table>
<tr>
<th>num Ligne</th>
<th>URL</th>
<th>Code HTTP</th>
<th>Encodage</th>
<th>Nombre d'occurences</th>
<th>Page HTML brute</th>
<th>Dump textuel</th>
<th>Contextes</th>
<th>Concordancier</th>
</tr>
EOT

# ------------------------
# Lecture des URLs
# ------------------------
ID=1
while read -r URL; do
    TEMP_HTML="/tmp/raw_$ID.html"
    FILE_ASPI="$DIR_ASPI/es-$ID.html"
    FILE_DUMP="$DIR_DUMP/es-$ID.txt"
    FILE_CONTEXTES="$DIR_CONTXT/contexte_es-$ID.txt"
    FILE_CONCORD="$DIR_CONCORD/concordancier-es-$ID.html"

    HTTP_CODE=$(curl -s -L -A "$USER_AGENT" -o "$TEMP_HTML" -w "%{http_code}" "$URL")

    if [[ "$HTTP_CODE" != "200" ]]; then
        echo "Erreur : $URL non traité (HTTP $HTTP_CODE)"
        # fichiers vides mais créés
        cp /dev/null "$FILE_ASPI" "$FILE_DUMP" "$FILE_CONTEXTES" "$FILE_CONCORD"
        ENCODING="N/A"
        TOTAL_OCCURENCES=0
    else
        cp "$TEMP_HTML" "$FILE_ASPI"
        ENCODING=$(file --mime-encoding --brief "$FILE_ASPI")
        links -dump "$FILE_ASPI" > "$FILE_DUMP"
        sed -i '' "s/[^[:alnum:][:space:]ñÑáéíóúüÁÉÍÓÚÜ¿¡–—]//g" "$FILE_DUMP"
        TOTAL_OCCURENCES=$(grep -Eio "$REGEX" "$FILE_DUMP" | wc -l)
        grep -E -C 1 "$REGEX" "$FILE_DUMP" | sed -E "s/($REGEX)/..\1../gi" > "$FILE_CONTEXTES"
    fi

    # ------------------------
    # Concordancier HTML 4 mots avant/après
    # ------------------------
    cat <<EOT > "$FILE_CONCORD"
<html>
<head>
<meta charset="UTF-8" />
<title>Concordances – estado</title>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bulma@1.0.2/css/bulma.min.css">
</head>
<body>
<div class="container">
<h2 class="title">Concordances autour de <em>estado</em></h2>
<table class="table is-striped is-narrow is-fullwidth">
<thead>
<tr>
<th class="has-text-right">Contexte gauche</th>
<th class="has-text-centered">Cible</th>
<th>Contexte droit</th>
</tr>
</thead>
<tbody>
EOT

grep -Eio '([[:alnum:]]+[[:space:]]+){0,4}(estado|estados)([[:space:]]+[[:alnum:]]+){0,4}' "$FILE_DUMP" |
while read -r line; do
    gauche=$(echo "$line" | sed -E 's/(.*)(estado|estados).*/\1/I' | sed -E 's/[[:space:]]+$//')
    cible=$(echo "$line" | grep -Eio '(estado|estados)' | head -n 1)
    droite=$(echo "$line" | sed -E 's/.*(estado|estados)(.*)/\2/I' | sed -E 's/^[[:space:]]+//')
    echo "<tr>
<td class=\"has-text-right\">$gauche</td>
<td class=\"has-text-centered has-text-success\"><strong>$cible</strong></td>
<td>$droite</td>
</tr>" >> "$FILE_CONCORD"
done

echo "</tbody></table></div></body></html>" >> "$FILE_CONCORD"

# ------------------------
# Style ligne principal
# ------------------------
ROW_STYLE=""
if [[ "$HTTP_CODE" != "200" ]] || [[ "$ENCODING" == "unknown-8bit" ]] || [[ "$ENCODING" == "N/A" ]]; then
    ROW_STYLE=" style=\"background-color: #FFFACD;\""  # jaune pastel
fi

# ------------------------
# Ajout ligne tableau principal
# ------------------------
echo "<tr$ROW_STYLE>
<td>$ID</td>
<td><a href=\"$URL\">Lien internet</a></td>
<td>$HTTP_CODE</td>
<td$ENC_STYLE>$ENCODING</td>
<td>$TOTAL_OCCURENCES</td>
<td><a href=\".$FILE_ASPI\">HTML brute</a></td>
<td><a href=\".$FILE_DUMP\">dump</a></td>
<td><a href=\".$FILE_CONTEXTES\">contexte</a></td>
<td><a href=\".$FILE_CONCORD\">concordancier</a></td>
</tr>" >> "$DIR_HTML_OUT"

ID=$((ID+1))
done < "$URL_FILE"

# ------------------------
# Fermeture tableau
# ------------------------
echo "</table></body></html>" >> "$DIR_HTML_OUT"

echo ">>> Script terminé, tableau généré : $DIR_HTML_OUT"
