#!/bin/bash

URL_FICHIER=$1

# regex pour reconnaître des caractères espagnols et les versions du mot "estado"
REGEX="ñ|[Ee]stado|[Ee]stados"

# dossiers de sortie
DIR_ASPI="./aspirations/espagnol"
DIR_CONTXT="./contextes/espagnol/"
DIR_DUMP="./dumps-text/espagnol/"
DIR_CONCORD="./concordances/espagnol"
DIR_HTML_OUT="./tableaux/estado_espagnol.html"


USER_AGENT="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"


# Vérification arguments 
if [ $# -ne 1 ] ; then
	echo "Usage : ce programme nécessite 1 argument : urls.txt"
	exit 1
fi

if [ ! -f "$URL_FILE" ] ; then
    echo "Erreur : le fichier '$URL_FILE' n'a pas été trouvé"
    exit 1
fi

# Création du tableau HTML

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

# Lecture et aspirations

# compteur qui va numéroter les fichiers (ex : dump_1) 
ID=1


# ouverture de la boucle qui va lire mon fichier espagnol ligne par ligne
while read -r URL ; do

# On crée on fichier temporaire pour stocker la page HTML brute (pour ne pas ralentir ou faire planter le script)
raw_file="/tmp/raw_$ID.html"

# On vérifie le code HTTP
if [[ "$http_code" != "200" ]]; then
    echo "Erreur : $URL non traité (HTTP $http_code)"
    continue   # passe à l'URL suivante
fi


# On copie la page HTML brute dans le dossier "aspirations"
filename_aspiration="$DIR_ASPI/es-$ID.html"
cp "$raw_file" "$filename_aspiration"














