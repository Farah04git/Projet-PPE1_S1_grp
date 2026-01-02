#!/bin/bash

## TODO :
# centrer colonnes
# script pour arboressence



URL_FILE=$1
ID=1
REGEX="[eéèêËE][tT][aàAÀ][tT]s?([-][A-Za-zàâäéèêëïîôöùûüÿçÀÂÄÉÈÊËÏÎÔÖÙÛÜŸÇ]+)?"
USER_AGENT="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"


DIR_ASPI="./aspirations/français"
DIR_CONTXT="./contextes/français/"
DIR_DUMP="./dumps-text/français/"
DIR_CONCORD="./concordances/français"
DIR_HTML_OUT="./tableaux/état_français.html"



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
	echo "<td>" "Contextes (1 ligne)" "</td>"
	echo "<td>" "Concordancier HTML" "</td>"

	echo "</tr>"
)

echo "$TAB_HTML" > "$DIR_HTML_OUT"


while read -r URL ; do
	echo ">>> Requête vers : $URL"

	# Création fichier temporaire (pour ne pas stocker HTML dans variable)
	raw_file="/tmp/raw_$ID.html"
	
	# Code HTTP
	http_code=$(curl -s -L -A "$USER_AGENT" -w "%{http_code}" -o "$raw_file" "$URL")

	# Vérification HTTP
	if [[ "$http_code" != "200" ]] ; then
		echo "Erreur : $URL non traité ($http_code)"
		continue
	fi
	
	# Envoi du HTML dans aspiration
	filename_aspiration="$DIR_ASPI/fr-$ID.html"
	cp "$raw_file" "$filename_aspiration"

	encoding=$(file --mime-encoding --brief "$filename_aspiration")
	echo 'l'encoding est = "$encoding"

	# links (!= lynx) pour dump
	filename_dump="$DIR_DUMP/fr-$ID.txt"
	links -dump "$filename_aspiration" > "$filename_dump"
	sed -i 's/\([^[:alpha:]]\)[\/<>|*?_-]\([^[:alpha:]]\)/\1\2/g' "$filename_dump" # suprresion caractères spéciaux
	

	# debug######
	if iconv -f UTF-8 -t UTF-8 "$filename_dump" > /dev/null 2>&1; then
		echo "dump est valide UTF‑8"
	else
		echo "dump n’est pas UTF‑8 valide"
	fi

	# Comptage mots dump
	total_words=$(egrep "\b[[:alnum:]]+\b" -o < "$filename_dump" | wc -l)
	echo "$total_words"
	
	# Comptage occurences dump
	total_occurences=$(grep -Eio "$REGEX" "$filename_dump" | wc -l)
	echo "$total_occurences"
	
	# Contexte - 1 ligne : mise en avant avec .. ..
	filename_contextes="$DIR_CONTXT/contxt_fr-$ID.txt"
	grep -E -C 1 "$REGEX" "$filename_dump" | sed -E "s/($REGEX)/..\1../gi" > "$filename_contextes"

	# Ajout Concordancier :
	filename_concord="$DIR_CONCORD/concordancier-fr-$ID.html"
	

	echo "<tr>" >> "$DIR_HTML_OUT"
	echo "<td>" "$ID" "</td>" >> "$DIR_HTML_OUT"
	echo "<td>" "<a href=\"$URL\" >Lien internet</a>" "</td>" >> "$DIR_HTML_OUT"
	echo "<td>" "$http_code" "</td>" >> "$DIR_HTML_OUT"
	echo "<td>" "$encoding" "</td>" >> "$DIR_HTML_OUT"
	echo "<td>" "$total_occurences" "</td>" >> "$DIR_HTML_OUT"
	echo "<td>" "<a href=\".$filename_aspiration\" >HTML brute</a>" "</td>" >> "$DIR_HTML_OUT"
	echo "<td>" "<a href=\".$filename_dump\" >dump</a>" "</td>" >> "$DIR_HTML_OUT"
	echo "<td>" "<a href=\".$filename_contextes\" >contxt</a>" "</td>" >> "$DIR_HTML_OUT"
	echo "<td>" "<a href=\".$filename_concord\" >contxt</a>" "</td>" >> "$DIR_HTML_OUT"
	echo "</tr>" >> "$DIR_HTML_OUT"
	
	((ID++))


done < "$URL_FILE" 

echo "</table>" >> "$DIR_HTML_OUT"
echo "</body></html>" >> "$DIR_HTML_OUT"