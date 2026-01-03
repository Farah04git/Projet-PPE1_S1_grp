#!/bin/bash

# ------------------------
# Script pour l'espagnol
# ------------------------

URL_FILE=$1

# regex pour reconnaître les occurrences des versions du mot "estado"
REGEX="[Ee]stado|[Ee]stados"

# chemins relatifs fixes (depuis programmes/espagnol)
DIR_BASE="../.."
DIR_ASPI="$DIR_BASE/aspirations/espagnol"
DIR_CONTXT="$DIR_BASE/contextes/espagnol"
DIR_DUMP="$DIR_BASE/dumps-text/espagnol"
DIR_CONCORD="$DIR_BASE/concordances/espagnol"
DIR_HTML_OUT="$DIR_BASE/tableaux/estado_espagnol.html"

# appel à un user agent pour simuler le navigateur et éviter les blocages
USER_AGENT="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"

# ------------------------
# Vérification de l'argument
# ------------------------
if [ $# -ne 1 ]; then
    echo "Usage : ce programme nécessite 1 argument : urls.txt"
    exit 1
fi

if [ ! -f "$URL_FILE" ]; then
    echo "Erreur : le fichier '$URL_FILE' n'a pas été trouvé"
    exit 1
fi

# ------------------------
# Création des dossiers si inexistants
# ------------------------

mkdir -p "$DIR_ASPI" "$DIR_CONTXT" "$DIR_DUMP" "$DIR_CONCORD" "$(dirname "$DIR_HTML_OUT")"

# ------------------------
# Création du tableau HTML espagnol
# ------------------------

TAB_HTML=$(
    echo "<!DOCTYPE html>"
    echo "<html>"
    echo "<head>"
    echo "<title>Projet de groupe PPE-25/26, espagnol</title>"
    echo "<link rel=\"stylesheet\" href=\"https://cdn.jsdelivr.net/npm/bulma@1.0.2/css/bulma.min.css\">"
    echo "</head>"
    echo "<style>"
    echo ".content{overflow:scroll}"
    echo "</style>"
    echo "<body>"
    echo "<h2 class=\"title\">Tableau <code>espagnol</code></h2>"
    echo "<table class=\"table\">"
    echo "<tr>"
    echo "<td>num Ligne</td>"
    echo "<td>URL</td>"
    echo "<td>Code HTTP</td>"
    echo "<td>Encodage</td>"
    echo "<td>Nombre d'occurences</td>"
    echo "<td>Page HTML brute</td>"
    echo "<td>Dump textuel</td>"
    echo "<td>Contextes (1 ligne)</td>"
    echo "<td>Concordancier HTML</td>"
    echo "</tr>"
)

echo "$TAB_HTML" > "$DIR_HTML_OUT"

# ------------------------
# Lecture et aspirations
# ------------------------

ID=1  # compteur pour numéroter les fichiers

while read -r URL; do

    # fichier temporaire pour stocker la page HTML brute
    TEMP_HTML="/tmp/raw_$ID.html"

    # ------------------------
    # Requête HTTP pour récupérer la page
    # -s : silencieux
    # -L : suivre les redirections
    # -A : user-agent
    # -o : sortie dans TEMP_HTML
    # -w "%{http_code}" : récupère le code HTTP
    # ------------------------

    HTTP_CODE=$(curl -s -L -A "$USER_AGENT" -o "$TEMP_HTML" -w "%{http_code}" "$URL")

    FILE_ASPI="$DIR_ASPI/es-$ID.html"
    FILE_DUMP="$DIR_DUMP/es-$ID.txt"
    FILE_CONTEXTES="$DIR_CONTXT/contxt_es-$ID.txt"
    FILE_CONCORD="$DIR_CONCORD/concordancier-es-$ID.html"

    # ------------------------
    # Gestion des erreurs
    # ------------------------

    if [[ "$HTTP_CODE" != "200" ]]; then
        echo "Erreur : $URL non traité (HTTP $HTTP_CODE)"
        # on va créer des fichiers vides pour ne pas casser le script
        touch "$FILE_ASPI" "$FILE_DUMP" "$FILE_CONTEXTES" "$FILE_CONCORD"
        ENCODING="N/A"
        TOTAL_OCCURENCES=0
    else

        # ------------------------
        # si jamais, on copie la page HTML brute
        # ------------------------

        cp "$TEMP_HTML" "$FILE_ASPI"

        # ------------------------
        # Détection de l'encodage
        # ------------------------
        ENCODING=$(file --mime-encoding --brief "$FILE_ASPI")
        echo "L'encodage est le suivant : $ENCODING"

        # -----------------------------
        # Création du dump textuel
        # -----------------------------
        links -dump "$FILE_ASPI" > "$FILE_DUMP"

        # suppression des caractères non souhaités
        sed -i '' "s/[^[:alnum:][:space:]ñÑáéíóúüÁÉÍÓÚÜ¿¡–—]//g" "$FILE_DUMP"

        # -----------------------------
        # Comptage des occurences de la regex
        # -----------------------------
        TOTAL_OCCURENCES=$(grep -Eio "$REGEX" "$FILE_DUMP" | wc -l)

        # -----------------------------
        # Extraction des contextes
        # -----------------------------

        grep -E -C 1 "$REGEX" "$FILE_DUMP" | sed -E "s/($REGEX)/..\1../gi" > "$FILE_CONTEXTES"
    fi

# -----------------------------
# Génération du concordancier HTML
# -----------------------------

echo "<html>
<head>
<meta charset=\"UTF-8\" />
<title>Concordances – estado</title>
<link rel=\"stylesheet\" href=\"https://cdn.jsdelivr.net/npm/bulma@1.0.2/css/bulma.min.css\">
</head>
<body>
<div class=\"container\">
<h2 class=\"title\">Concordances autour de <em>estado</em></h2>

<table class=\"table is-striped is-narrow is-fullwidth\">
<thead>
<tr>
<th class=\"has-text-right\">Contexte gauche</th>
<th class=\"has-text-centered\">Cible</th>
<th>Contexte droit</th>
</tr>
</thead>
<tbody>" > "$FILE_CONCORD"

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


echo "</tbody>
</table>
</div>
</body>
</html>" >> "$FILE_CONCORD"

    # -----------------------------
    # Ajout de la ligne dans le tableau HTML
    # -----------------------------

    echo "<tr>" >> "$DIR_HTML_OUT"
    echo "<td>$ID</td>" >> "$DIR_HTML_OUT"
    echo "<td><a href=\"$URL\">Lien internet</a></td>" >> "$DIR_HTML_OUT"
    echo "<td>$HTTP_CODE</td>" >> "$DIR_HTML_OUT"
    echo "<td>$ENCODING</td>" >> "$DIR_HTML_OUT"
    echo "<td>$TOTAL_OCCURENCES</td>" >> "$DIR_HTML_OUT"
    echo "<td><a href=\".$FILE_ASPI\">HTML brute</a></td>" >> "$DIR_HTML_OUT"
    echo "<td><a href=\".$FILE_DUMP\">dump</a></td>" >> "$DIR_HTML_OUT"
    echo "<td><a href=\".$FILE_CONTEXTES\">contxt</a></td>" >> "$DIR_HTML_OUT"
    echo "<td><a href=\".$FILE_CONCORD\">concordancier</a></td>" >> "$DIR_HTML_OUT"
    echo "</tr>" >> "$DIR_HTML_OUT"

    ID=$((ID + 1))

done < "$URL_FILE"

# -----------------------------
# Fermeture du tableau HTML
# -----------------------------

echo "</table>" >> "$DIR_HTML_OUT"
echo "</body></html>" >> "$DIR_HTML_OUT"

echo ">>> Script terminé, tableau généré : $DIR_HTML_OUT"
