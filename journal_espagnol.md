Je dois constituer un corpus d'URLS en espagnol pour étudier le mot "estado" sur le web

>> Biaser les recherches via la recherche avancée google

- premières observations :

| colocaciones         | locuciones                  |
| -------------------- | --------------------------- |
| Estado autonómico    | mudar estado                |
| estado civil         | tomar estado                |
| estado de alarma     | caer a alguien de su estado |
| estado de ánimo      | estado llano                |
| estado de cuentas    |                             |
| estado de emergencia |                             |
| Estado de derecho    |                             |
| estado de excepción  |                             |
| estado de guerra     |                             |
| estado de necesidad  |                             |
| estado de opinión    |                             |
| Estado federal       |                             |
| Estado Mayor         |                             |
| estado fundamental   |                             |
| jefe de Estado       |                             |
| consejo de Estado    |                             |
| inquisidor de Estado |                             |
| secreto de Estado    |                             |

Le corpus que j'ai constitué contenait 50 URLs, mais toutes n’ont pas pu être traitées. Certaines pages web bloquent les requêtes automatisées pour des raisons de sécurité, par exemple via des restrictions serveur ou des protections anti-robots. Dans ces cas, la requête renvoie un code HTTP d’erreur, comme 403 ou 000. Le script est conçu pour ne traiter que les pages correctement récupérées, c’est-à-dire celles qui renvoient un code 200. Les pages bloquées sont donc ignorées automatiquement afin d’éviter des erreurs et de garantir la cohérence du traitement linguistique.

J'ai rajouté un 51ème.

```bash
grep -Eio ".{0,30}\b($REGEX)\b.{0,30}" "$FILE_DUMP" | while read -r line; do

    gauche=$(echo "$line" | sed -E "s/(.*)\b($REGEX)\b.*/\1/I")
    cible=$(echo "$line" | grep -Eio "\b($REGEX)\b")
    droite=$(echo "$line" | sed -E "s/.*\b($REGEX)\b(.*)/\2/I")

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
```

Le premier résultat montrait une redondance car la segmentation gauche/droite n’était pas suffisamment contrainte. J’ai corrigé le concordancier en bornant explicitement les contextes autour de l’occurrence centrale. 

Observations 

1. Anomalies d’encodage et de code HTTP

Certaines pages présentent des encodages non reconnus ou n’ont pas pu être téléchargées. Nous avons choisi de conserver ces lignes dans le tableau pour illustrer que le script fonctionne de manière robuste : il récupère les pages accessibles, extrait les informations et gère proprement les erreurs lorsque certaines URLs sont inaccessibles ou bloquées.

- **URL 2/ 200 / unknown-8bit** → Page récupérée correctement mais encodage non identifié ; le contenu est exploitable.
- **URL 13 / 000 / N/A** → Page non téléchargée (erreur réseau ou URL inaccessible) ; aucun contenu disponible.
- **URL / 403 / N/A** → Accès interdit par le serveur (protection anti-bot) ; fichier vide créé.
- **URL 32 / 000 / N/A** → Page non téléchargée (erreur réseau ou URL inaccessible) ; aucun contenu disponible.

*Nuage des points*
Pour réaliser le nuage de points j'ai crée un script qui prendra tous les fichiers dump text et en constituer un corpus entier 
J'ai crée un venv pour éxécuter la commande wordcloud_cli
Au début je n'ai pas réussi à generer une image pertinente j'ai du rajouter des prépositions "para", "con", "de" au fichier stopwords_espagnol que j'ai telechargé depuis un source de github 

*PALS*
Le but de cet exercice final est d’analyser linguistiquement un mot précis, ici le mot espagnol **« estado »**, en étudiant ses cooccurrences dans notre corpus. 
Grâce au script de PALS (_Probabilistic Association of Lexical Sequences_), on peut identifier les mots qui apparaissent fréquemment autour de « estado », mesurer leur fréquence, leur co‑fréquence avec le mot cible et leur spécificité. Cela permet de comprendre dans quels contextes le mot est utilisé, de détecter ses associations lexicales typiques et éventuellement ses variations sémantiques. L’exercice offre ainsi une vision quantitative et qualitative de l’usage du mot dans le corpus, préparant à des observations plus fines sur la langue et sur les structures syntaxiques ou lexicales qui l’entourent.

```bash
./script_coo_espagnol.sh

```

- **UTF-8** : `PYTHONIOENCODING=utf-8` force Python à écrire les caractères accentués correctement.
- **Chemins relatifs** : le script suppose que tu es dans `PALS/PALS_espagnol` et que `cooccurrents.py` est dans `PALS`.
- **Fichier de sortie** : `estado_cooc.html` sera créé dans le même dossier que le script (`PALS_espagnol`).
- **Arguments** :
    - `--target "estado"` → le mot à étudier
    - `-N 10` → les 10 co-occurrents les plus fréquents
    - `-s i` → calcul de la spécificité (informatif)
    - `--match-mode regex` → pour inclure toutes les formes du mot si besoin

Pour l’étape finale de l’analyse linguistique, j’avais besoin d’étudier les co-occurrents du mot _estado_ sur l’ensemble de mon corpus espagnol. Mon problème était que les fichiers texte étaient dispersés dans plusieurs dumps (`es-ID.txt`) et qu’il n’était pas possible de les traiter directement dans `coocurrents.py`. J’ai donc pris la décision de créer d’abord un **corpus commun**, en fusionnant tous les fichiers texte en un seul fichier. Cette approche m’a permis de centraliser toutes les données, de faciliter le traitement automatisé et de préparer un support unique pour générer ensuite les tableaux de co-occurrents et réaliser une étude linguistique cohérente.

```bash
python3 ../cooccurrents.py ./corpus_espagnol.txt --target "estado" -N 10 -s i > estado_cooc.txt
cat estado_cooc.txt | awk 'BEGIN{print "<table><tr><th>Token</th><th>Corpus</th><th>AllCtx</th><th>Freq</th><th>CoFreq</th><th>Spec</th></tr>"} {print "<tr><td>"$1"</td><td>"$2"</td><td>"$3"</td><td>"$4"</td><td>"$5"</td><td>"$6"</td></tr>"} END{print "</table>"}' > estado_cooc.html

```

J'ai ensuite constaté que le corpus fusionné contenait beaucoup d'éléments non pertinents comme des numéros, des images ou des titres publicitaires. Pour obtenir des résultats exploitables, j’ai donc créé un script qui transforme tout le texte en minuscules, supprime les caractères non alphabétiques et les lignes vides et normalise les espaces. Ce traitement m’a permis de générer un corpus *propre*, ne contenant que des mots exploitables pour l’analyse des co-occurrents, ce qui garantit la fiabilité des mesures de fréquence et de spécificité dans l’étape suivante.

- erreur avec le corpus sans nettoyage : 
![[Capture d’écran 2026-01-04 à 02.51.36]]

Le corpus est clean mais prend en compte des lignes en entier
Après avoir regardé la docu du fichier "cooccurrents.py" je me suis rendue compte qu'il fallait tokeniser le corpus  

- erreur sans les tokens :
![[Capture d’écran 2026-01-04 à 02.51.22]]