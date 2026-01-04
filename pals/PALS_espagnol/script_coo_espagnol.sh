#!/bin/bash

# ------------------------
# Script simplifié pour co-occurrents du mot "estado"
# ------------------------

# Récupérer le dossier du script pour utiliser des chemins relatifs sûrs
DIR="$(cd "$(dirname "$0")" && pwd)"

# Chemin vers le corpus nettoyé
CORPUS="$DIR/corpus_espagnol_clean.txt"

# Chemin de sortie du tableau HTML
OUTPUT_HTML="$DIR/estado_cooc.html"

# Chemin vers le script Python cooccurrents.py
# Il doit se trouver dans le dossier parent "PALS"
COOC_PATH="$DIR/../cooccurrents.py"

# Nombre de co-occurrents à extraire
N=10

# ------------------------
# Vérifications basiques
# ------------------------
if [ ! -f "$CORPUS" ]; then
    echo "Erreur : corpus '$CORPUS' introuvable."
    exit 1
fi

if [ ! -f "$COOC_PATH" ]; then
    echo "Erreur : '$COOC_PATH' introuvable. Vérifie le chemin."
    exit 1
fi

# ------------------------
# Exécution du script Python
# ------------------------
# On redirige la sortie vers un fichier temporaire
TMP_FILE="$DIR/temp_cooc.txt"
python3 "$COOC_PATH" --target "estado" "$CORPUS" -N $N -s i > "$TMP_FILE"

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
# Lecture du fichier temporaire et création du tableau
# ------------------------
# On lit chaque ligne, séparée par tabulation
while IFS=$'\t' read -r TOKEN CORPUS_SIZE ALLCTX FREQ COFREQ SPEC; do
    # Écriture dans le tableau HTML
    echo "<tr><td>$TOKEN</td><td>$CORPUS_SIZE</td><td>$ALLCTX</td><td>$FREQ</td><td>$COFREQ</td><td>$SPEC</td></tr>" >> "$OUTPUT_HTML"
done < "$TMP_FILE"

# Fermeture du tableau HTML
echo "</table></body></html>" >> "$OUTPUT_HTML"

# ------------------------
# Nettoyage du fichier temporaire
# ------------------------
rm "$TMP_FILE"

echo ">>> Tableau cooccurrents généré : $OUTPUT_HTML"
