#!/bin/bash

FICHIER_URLS=$1

numero_ligne=0

if [ $# -ne 1 ]
then
	echo "Ce programme nécessite un (1) argument "
	exit 1
else
	echo "Démarrage du processus"
fi

if [ ! -f "$FICHIER_URLS" ]
then
    echo "Erreur : le fichier '$FICHIER_URLS' n'a pas été trouvé"
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

done < "$FICHIER_URLS"

echo "</table>	
	</body>
</html>"

} > output2.html





#fichier_temp=$(mktemp) #fichier temporaire






#rm ${temp_file} # supression fichier temporaire

