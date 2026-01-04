#!/bin/bash

# ------------------------
# Script : Co-occurrents espagnol
# ------------------------

# dossier des dumps
DUMP_DIR="../../dumps-text/espagnol"
# dossier d'output
OUTPUT_DIR="."
# fichier HTML de sortie
OUTPUT_HTML="$OUTPUT_DIR/estado_cooc.html"

# mot cible
TARGET="estado"

# vérification des fichiers
if [ ! -d "$DUMP_DIR" ]; then
    echo "Erreur : $DUMP_DIR introuvable"
    exit 1
fi
if ! ls "$DUMP_DIR"/es-*.txt 1> /dev/null 2>&1; then
    echo "Erreur : aucun fichier es-*.txt dans $DUMP_DIR"
    exit 1
fi

# vérification du script cooccurrents.py
if [ ! -f "../../cooccurrents.py" ]; then
    echo "Erreur : ../../cooccurrents.py introuvable. Vérifie le chemin."
    exit 1
fi

# ------------------------
# Génération du tableau HTML
# ------------------------
cat <<EOT > "$OUTPUT_HTML"
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Tableau co-occurrents – $TARGET</title>
<style>
table { border-collapse: collapse; width: 100%; }
th, td { border: 1px solid #999; padding: 0.5em; }
th { font-weight: bold; background-color: #f2f2f2; }
.token { font-weight: bold; }
</style>
</head>
<body>
<h2>Tableau des co-occurrents pour le mot <em>$TARGET</em></h2>
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

# ------------------------
# Exécution de cooccurrents.py
# ------------------------
COOC_OUTPUT=$(python3 ../../cooccurrents.py --target "$TARGET.*" "$DUMP_DIR"/es-*.txt -N 20 -s i --match-mode regex)

# ------------------------
# Traitement ligne par ligne
# ------------------------
echo "$COOC_OUTPUT" | while read -r line; do
    # ignorer les lignes vides ou les en-têtes
    [[ -z "$line" ]] && continue
    [[ "$line" =~ ^token ]] && continue

    # extraire les 5 dernières colonnes (numériques)
    nums=$(echo "$line" | awk '{print $(NF-4), $(NF-3), $(NF-2), $(NF-1), $NF}')
    # extraire le token (tout ce qui reste au début)
    token=$(echo "$line" | awk '{for(i=1;i<=NF-5;i++) printf "%s%s",$i,(i<NF-5?" ":"")}')
    
    corpus_size=$(echo $nums | awk '{print $1}')
    all_ctx=$(echo $nums | awk '{print $2}')
    freq=$(echo $nums | awk '{print $3}')
    co_freq=$(echo $nums | awk '{print $4}')
    spec=$(echo $nums | awk '{print $5}')

    # ajouter la ligne au tableau HTML
    echo "<tr>
<td class=\"token\">$token</td>
<td>$corpus_size</td>
<td>$all_ctx</td>
<td>$freq</td>
<td>$co_freq</td>
<td>$spec</td>
</tr>" >> "$OUTPUT_HTML"
done

# ------------------------
# Fermeture tableau
# ------------------------
echo "</table></body></html>" >> "$OUTPUT_HTML"

echo ">>> Tableau cooccurrents généré dans le dossier PALS_espagnol : $OUTPUT_HTML"
