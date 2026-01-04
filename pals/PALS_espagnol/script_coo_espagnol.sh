#!/bin/bash

# ==========================================================
# Script : co-occurrents du mot "estado"
# Corpus : corpus_espagnol_token.txt
# Sortie : estado_cooc.html
# ==========================================================

# Dossier où se trouve ce script (sécurité des chemins)
DIR="$(cd "$(dirname "$0")" && pwd)"

# Corpus tokenisé et nettoyé
CORPUS="$DIR/corpus_espagnol.txt"

# Fichier HTML de sortie
OUTPUT_HTML="$DIR/estado_cooc.html"

# Script Python cooccurrents.py (dans le dossier PALS)
COOC_PATH="$DIR/../cooccurrents.py"

# Nombre de co-occurrents affichés
N=50

# ----------------------------------------------------------
# Vérifications
# ----------------------------------------------------------
if [ ! -f "$CORPUS" ]; then
    echo "Erreur : corpus introuvable ($CORPUS)"
    exit 1
fi

if [ ! -f "$COOC_PATH" ]; then
    echo "Erreur : cooccurrents.py introuvable ($COOC_PATH)"
    exit 1
fi

# ----------------------------------------------------------
# Exécution de cooccurrents.py
# ----------------------------------------------------------
TMP_FILE="$DIR/temp_cooc.txt"

python3 "$COOC_PATH" \
    --target "estado" \
    "$CORPUS" \
    -N $N \
    -s i \
    > "$TMP_FILE"

# ----------------------------------------------------------
# Création du fichier HTML
# ----------------------------------------------------------
cat <<EOT > "$OUTPUT_HTML"
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Co-occurrents de "estado"</title>

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
<h2>Tableau des co-occurrents du mot <em>estado</em></h2>

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

# ----------------------------------------------------------
# Lecture des résultats
# - tail -n +2 : supprime l’en-tête généré par le script Python
# ----------------------------------------------------------
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

# ----------------------------------------------------------
# Nettoyage
# ----------------------------------------------------------
rm "$TMP_FILE"

echo "Tableau généré avec succès : $OUTPUT_HTML"
