#!/bin/bash

URL_FILE=$1

DIR_ASPI="./aspirations"
DIR_CONTXT="./contextes"
DIR_DUMP="./dumps-text"
DIR_CONCORD="./concordances"



numero_ligne=0

# Vérification arguments 
if [ $# -ne 1 ]
then
	echo "Usage : ce programme nécessite 1 argument : urls.txt"
	exit 1
fi

if [ ! -f "$URL_FILE" ]
then
    echo "Erreur : le fichier '$URL_FILE' n'a pas été trouvé"
    exit 1
fi

{

echo "<html>
	<head>
		<meta charset=\"UTF-8\">
	</head>

	<body>
		<table>
			<tr>
				<th>numero_ligne</th>
				<th>URL</th>
				<th>code</th>
				<th>encodage</th>
				<th>nb_mots</th>
			</tr>"
		




while read -r URL 
do

	numero_ligne=$((numero_ligne + 1))
    
    onlyRequest=$(curl -sS "$URL")

    #code=$(curl -s -o /dev/null -w "%{http_code}" "$URL")
    encodage=$(echo "$onlyRequest" | grep -i charset | cut -d= -f2)
    nb_mots=$(echo "$onlyRequest" | wc -w)

    echo "<tr>
        	<td>$numero_ligne</td>
        	<td>$URL</td>
        	<td>$code</td>
        	<td>$encodage</td>
        	<td>$nb_mots</td>
   		 </tr>"

done < "$URL_FIL"

echo "</table>	
	</body>
</html>"

} > output2.html





#fichier_temp=$(mktemp) #fichier temporaire






#rm ${temp_file} # supression fichier temporaire

