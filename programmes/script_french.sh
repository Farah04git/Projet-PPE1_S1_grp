#!/bin/bash

URL_FILE=$1

DIR_ASPI="./aspirations"
DIR_CONTXT="./contextes"
DIR_DUMP="./dumps-text"
DIR_CONCORD="./concordances"
DIR_HTML_OUT="./tableaux/état_français.html"

numero_ligne=0

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
	echo "<title>Projet de groupe PPE-25/26, français</title>"
	echo "<link rel=\"stylesheet\" href=\"https://cdn.jsdelivr.net/npm/bulma@1.0.2/css/bulma.min.css\">"
	echo "</head>"
	
	echo "<style>"
    echo ".content{overflow:scroll}"
	echo "</style>"
	
	echo "<body>"
	echo "<h2 class=\"title\" >Tableau <code>français</code></h2>"
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
	echo "<td>" "Concordancier HTML" "</td>"

	echo "</tr>"
	echo "</table>"
	echo "</body>"
	echo "</html>"

)

echo "$TAB_HTML" > "$DIR_HTML_OUT"










#fichier_temp=$(mktemp) #fichier temporaire






#rm ${temp_file} # supression fichier temporaire

