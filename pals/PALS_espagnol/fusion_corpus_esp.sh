#!/bin/bash

# ------------------------
# Script : Co-occurrents pour "estado"
# ------------------------

# Chemin sûr du dossier du script (toujours PALS_espagnol)
DIR="$(cd "$(dirname "$0")" && pwd)"

# Chemins
CORPUS="$DIR/corpus_espagnol.txt"
OUTPUT_HTML="$DIR/estado_cooc.html"
COOC_PATH="$DIR/../cooccurrents.py"  # le script python est dans PALS
N=10  # nombre de co-occurrents à extraire

# ------------------------
# Vérification des fichiers
# ------------------------
if [ ! -f "$CORPUS" ]; then
    echo "Erreur : le corpus '$CORPUS' n'existe pas."
    exit 1
fi

if [ ! -f "$COOC_PATH" ]; then
    echo "Erreur : '$COOC_PATH' introuvable. Vérifie le chemin et le nom exact."
    exit 1
fi

# ------------------------
# Exécution de cooccurrents.py
# ------------------------
python3 "$COOC_PATH" --target "estado" "$CORPUS" -N $N -s i > "$DIR/temp_cooc.txt"

# ------------------------
# Génération du tableau HTML
# ------------------------
cat <<EOT > "$OUTPUT_HTML"
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Tableau des co-occurrents pour "estado"</title>
<style>
table { border-collapse: collapse; width: 100%; }
th, td { border: 1px solid #999; padding: 0.5em; }
th { font-weight: bold; background-color: #f0f0f0; }
td { background-color: #fff; }
</style>
</head>
<body>
<h2>Tableau des co-occurrents pour le mot <em>estado</em></h2>
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
# Lecture du fichier temp_cooc.txt
# ------------------------
while read -r line; do
    # Découpe les colonnes depuis la fin pour gérer tokens multi-mots
    SPEC=$(echo "$line" | awk '{print $NF}')
    COFREQ=$(echo "$line" | awk '{print $(NF-1)}')
    FREQ=$(echo "$line" | awk '{print $(NF-2)}')
    ALLCTX=$(echo "$line" | awk '{print $(NF-3)}')
    CORPUS_SIZE=$(echo "$line" | awk '{print $(NF-4)}')
    # Tout ce qui reste avant = token
    TOKEN=$(echo "$line" | awk -v n=5 '{for(i=1;i<=NF-n;i++) printf $i" "; print ""}' | sed 's/ $//')

    echo "<tr><td>$TOKEN</td><td>$CORPUS_SIZE</td><td>$ALLCTX</td><td>$FREQ</td><td>$COFREQ</td><td>$SPEC</td></tr>" >> "$OUTPUT_HTML"
done < "$DIR/temp_cooc.txt"

# Fermeture du tableau HTML
echo "</table></body></html>" >> "$OUTPUT_HTML"

# ------------------------
# Nettoyage
# ------------------------
rm "$DIR/temp_cooc.txt"

echo ">>> Tableau cooccurrents généré : $OUTPUT_HTML"
