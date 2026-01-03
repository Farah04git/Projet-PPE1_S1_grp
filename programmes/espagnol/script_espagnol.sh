#!/bin/bash

# ------------------------
# Script pour l'espagnol
# ------------------------

URL_FILE=$1

# regex pour reconnaître les occurrences des versions du mot "estado"
REGEX="[Ee]stado|[Ee]stados"

# dossiers de sortie
DIR_ASPI="./aspirations/espagnol"
DIR_CONTXT="./contextes/espagnol/"
DIR_DUMP="./dumps-text/espagnol/"
DIR_CONCORD="./concordances/espagnol"
DIR_HTML_OUT="./tableaux/estado_espagnol.html"

# appel à un user agent pour simuler le navigateur et éviter les blocages
USER_AGENT="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"

# ------------------------
# Vérification de l'arguments 
# ------------------------

if [ $# -ne 1 ] ; then
	echo "Usage : ce programme nécessite 1 argument : urls.txt"
	exit 1
fi

if [ ! -f "$URL_FILE" ] ; then
    echo "Erreur : le fichier '$URL_FILE' n'a pas été trouvé"
    exit 1
fi

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
	echo "<h2 class=\"title\" >Tableau <code>espagnol</code></h2>"
	echo "<table class=\"table\" >"
	echo "<tr>"

	# Colones du tableau

	echo "<td>" "num Ligne" "</td>"
	echo "<td>" "URL" "</td>"
	echo "<td>" "Code HTTP" "</td>"
	echo "<td>" "Encodage" "</td>"
	echo "<td>" "Nombre d'occurences" "</td>"
	echo "<td>" "Page HTML brute" "</td>"
	echo "<td>" "Dump textuel" "</td>"
	echo "<td>" "Contextes (1 ligne)" "</td>"
	echo "<td>" "Concordancier HTML" "</td>"

	echo "</tr>"
)

# ------------------------
# Lecture et aspirations
# ------------------------

# compteur qui va numéroter les fichiers (ex : dump_1) 
ID=1

# ouverture de la boucle qui va lire mon fichier espagnol ligne par ligne
while read -r URL ; do

# On crée on fichier temporaire (tmp) pour stocker la page HTML brute (pour ne pas ralentir ou faire planter le script)
# facile à nettoyer après
TEMP_HTML="/tmp/raw_$ID.html"

# Requête HTTP pour récupérer la page (boucle if)
    # -s : silencieux (pas de barre de progression)
    # -L : suivre les redirections
    # -A : définit l'user-agent (simule un navigateur)
    # -o : écrit le contenu dans TEMP_HTML
    # -w "%{HTTP_CODE}" : récupère le code HTTP en sortie

HTTP_CODE=$(curl -s -L -A "$USER_AGENT" -o "$TEMP_HTML" -w "%{http_code}" "$URL")

# Vérification du code HTTP

if [[ "$HTTP_CODE" != "200" ]]; then
    echo "Erreur : $URL non traité (HTTP $HTTP_CODE)"
    continue   # passe à l'URL suivante
fi

# On copie la page HTML brute dans le dossier "aspirations"

FILE_ASPI="$DIR_ASPI/es-$ID.html"
cp "$TEMP_HTML" "$FILE_ASPI"

# On détecte l'encodage : 

ENCODING=$(file --mime-encoding --brief "$FILE_ASPI")
    echo "L'encodage est le suivant : $ENCODING"

	# -----------------------------
    # Création du dump textuel 
    # -----------------------------

    # On va maintenant convertir le contenu HTML en texte brut (sans les balises)

# Ici on crée le fichier dump textuel

FILE_DUMP="$DIR_DUMP/es-$ID.txt"
links -dump "$FILE_ASPI" > "$FILE_DUMP"

# Avec la commande sed -i on va supprimer : 
	#[^...] : tout ce qui n’est pas dans la liste
	#[:alnum:] : les lettres et les chiffres classiques
	#[:space:] : les espaces, tabulations et retours à la ligne
	# ñÑáéíóúüÁÉÍÓÚÜ : la liste des caractères spéciaux espagnols que l'on souhaite garder

sed -i '' "s/[^[:alnum:][:space:]ñÑáéíóúüÁÉÍÓÚÜ¿¡–—]//g" "$FILE_DUMP"

# -----------------------------
# Comptage des occurences de la regex dans le dump
# -----------------------------

TOTAL_OCCURENCES=$(grep -Eio "$REGEX" "$FILE_DUMP" | wc -l)
    echo "Nombre d'occurrences : $TOTAL_OCCURENCES"

# -----------------------------
# Extraction des contextes
# -----------------------------

# On va extraire 1 ligne autour de chaque occurence

FILE_CONTEXTES="$DIR_CONTXT/contxt_es-$ID.txt"
    grep -E -C 1 "$REGEX" "$FILE_DUMP" | sed -E "s/($REGEX)/..\1../gi" > "$FILE_CONTEXTES"

# Et on va l'ajouter au tableau HTML

FILE_CONCORD="$DIR_CONCORD/concordancier-es-$ID.html"

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

    ((ID++))

done < "$URL_FILE"

# -----------------------------
# Fermeture du tableau HTML
# -----------------------------

echo "</table>" >> "$DIR_HTML_OUT"
echo "</body></html>" >> "$DIR_HTML_OUT"

echo ">>> Script terminé, tableau généré : $DIR_HTML_OUT"














