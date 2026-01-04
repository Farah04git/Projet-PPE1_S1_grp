#!/usr/bin/env bash

SCRIPT_PY="./pals/cooccurrents.py"
DUMPS="./pals/PALS_français/dumps_FR.txt"
OUTPUT_HTML="./pals/PALS_français/état_cooc_dumps.html"

REGEX="état"

# Vérification fichiers
if [ ! -f "$DUMPS" ]; then
    echo "Erreur : le dossier '$CORPUS' est introuvable."
    exit 1
fi

if [ ! -f "$SCRIPT_PY" ]; then
    echo "Erreur : le script python '$CORPUS' est introuvable."
    exit 1
fi

# Création fichier temp
TMP_FILE="./pals/PALS_français/temp_cooc.txt"

# Nombre de co-occurrents affichés
N=50

# Usage script Python cooccurents
python3 "$SCRIPT_PY" \
    --target "$REGEX" \
    "$DUMPS" \
    -N $N \
    -s i \
    > "$TMP_FILE"

echo "=== DEBUG : Contenu de TMP_FILE ==="
cat "$TMP_FILE"
echo "=== FIN DEBUG ==="




cat <<EOT > "$OUTPUT_HTML"
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Co-occurrents de "état"</title>

<style>
body {
    font-family: Arial, Helvetica, sans-serif;
}

table {
    border-collapse: collapse;
    width: 100%;
    font-family: Arial, Helvetica, sans-serif;
}

th, td {
    border: 1px solid #999;
    padding: 6px;
    text-align: left;
}

th {
    background-color: #f0f0f0;
    font-weight: bold;
}
</style>
</head>

<body>
<h2>Tableau des co-occurrents du mot <em>état</em> et de ses variations</h2>

<table>
<tr>
    <th>Token</th>
    <th>Corpus size</th>
    <th>All contexts size</th>
    <th>Frequency</th>
    <th>Co-frequency</th>
    <th>Specificity</th>
</tr>
EOT

# Lecture des résultats + suppression entête
tail -n +2 "$TMP_FILE" | while IFS=$'\t' read -r TOKEN CORPUS_SIZE ALLCTX FREQ COFREQ SPEC; do
    echo "<tr>
        <td>$TOKEN</td>
        <td>$CORPUS_SIZE</td>
        <td>$ALLCTX</td>
        <td>$FREQ</td>
        <td>$COFREQ</td>
        <td>$SPEC</td>
    </tr>" >> "$OUTPUT_HTML"
done

# Fermeture du tableau HTML
echo "</table></body></html>" >> "$OUTPUT_HTML"

# suppresion temp
rm "$TMP_FILE"
