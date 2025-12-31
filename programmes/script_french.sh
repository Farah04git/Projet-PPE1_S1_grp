#!/bin/bash

# voir encodage

URL_FILE=$1
ID=1

DIR_ASPI="./aspirations/français"
DIR_CONTXT="./contextes"
DIR_DUMP="./dumps-text/français/"
DIR_CONCORD="./concordances"
DIR_HTML_OUT="./tableaux/état_français.html"

USER_AGENT="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"

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


while read -r URL ; do
	echo ">>> Requête vers : $URL"

	# Toute la réponse HTTP (header + body), pour éviter trop de curl
	full_response=$(curl -s -i -L -A "$USER_AGENT" "$URL")

	# Code HTTP
	http_code=$(echo "$full_response" | head -n 1 | cut -d ' ' -f 2)

	# Vérification HTTP
	if [[ "$http_code" != "200" ]] ; then
		echo "Erreur : $URL non traité (!=200)"
		continue
	fi
	
	# HTML + écriture dans fichiers aspiration
	html_full=$(echo "$full_response" | sed -n '/^[[:space:]]*</,$p')
	filename_aspiration="$DIR_ASPI/fr-$ID.html"

	echo "$html_full" > "$filename_aspiration"

	# Détection encodage UTF-8
	encoding=$(echo "$html_full" | grep -i -o 'UTF-8' | head -1)
	
	if [[ -n "$encoding" ]]; then
		#echo "Encodage détecté : $encoding"

		# Écriture dump dans fichiers
		filename_dump="$DIR_DUMP/fr-$ID.txt"

		echo "$html_full" | lynx -dump -nolist -stdin > "$filename_dump"

	else
		continue
		
	fi

	((ID++))

	
	


done < "$URL_FILE" 









#fichier_temp=$(mktemp) #fichier temporaire






#rm ${temp_file} # supression fichier temporaire

