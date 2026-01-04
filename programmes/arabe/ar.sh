#!/usr/bin/env bash
set -euo pipefail

URLFILE="URLs/ar.txt"
LANGUE="arabe"

BASE_GH="https://github.com/Farah04git/Projet-PPE1_S1_grp/blob/main"


ASP_DIR="aspirations/$LANGUE"
DUMP_DIR="dumps-text/$LANGUE"
CTX_DIR="contextes/$LANGUE"
TAB_DIR="tableaux"
OUTHTML="$TAB_DIR/ar.html"
CONC_DIR="concordances/$LANGUE"


OUTHTML="$TAB_DIR/ar.html"

# 2 patterns séparés + total
PAT1='(ال)?دول(ة|ات|ي|ية|يون|يات|تي|ته|تها|تهم|تنا|كم|كن|نا|ي)?'
PAT2='(ال)?حال(ة|ات|ي|ية|ته|تها|تهم|تنا|كم|كن|نا|ي)?'
PAT_CTX="($PAT1|$PAT2)"

N=50

mkdir -p "$ASP_DIR" "$DUMP_DIR" "$CTX_DIR" "$TAB_DIR" "$CONC_DIR"

if [ ! -f "$URLFILE" ]; then
  echo "Erreur: fichier introuvable: $URLFILE" >&2
  exit 1
fi

cat > "$OUTHTML" <<'HTML'
<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8" />
  <title>Arabe – état (دولة / حالة)</title>
  <style>
    body { background:#000; color:#fff; font-family: Arial, Helvetica, sans-serif; }
    table { border-collapse: collapse; width:100%; }
    th, td { border:1px solid #444; padding:6px; text-align:left; vertical-align: top; }
    th { background:#111; color:#fff; }
    a { color:#9ad; text-decoration:none; }
    a:hover { text-decoration:underline; }
    tr.w1 { background:#ffb3b3; color:#000; } /* rouge clair */
    tr.w2 { background:#b00000; color:#fff; } /* rouge foncé */
    tr.eq { background:#222; color:#fff; }    /* égalité */
  </style>
</head>
<body>

<h1>Arabe – état (دولة / حالة)</h1>
<table>
<tr>
  <th>Num Ligne</th>
  <th>URL</th>
  <th>Occ. (دولة)</th>
  <th>Occ. (حالة)</th>
  <th>Total</th>
  <th>Encodage</th>
  <th>Code HTTP</th>
  <th>Page HTML brute</th>
  <th>Dump textuel</th>
  <th>Contextes</th>
  <th>Concordancier</th>
</tr>
HTML

n=0

while IFS= read -r url; do
  # ignore lignes vides
  [ -z "${url// /}" ] && continue

  # ignore lignes non-URL (commentaires etc.)
  case "$url" in
    http://*|https://*) ;;
    *) continue ;;
  esac

  n=$((n+1))
  if [ "$n" -gt "$N" ]; then
    break
  fi

  html="$ASP_DIR/ar-$n.html"
  txt="$DUMP_DIR/ar-$n.txt"
  ctx="$CTX_DIR/ar-$n.txt"
  conc="$CONC_DIR/ar-$n.html"

  http="000"
  enc="na"
  occ1=0
  occ2=0
  total=0
  row_class="eq"

  # 1) Téléchargement + code HTTP
  http="$(curl -s -L -A "Mozilla/5.0" -o "$html" -w "%{http_code}" "$url" || echo "000")"

  if [ ! -s "$html" ]; then
    echo "[ERREUR] téléchargement vide: $url (HTTP=$http)" > "$txt"
    : > "$ctx"
    cat > "$conc" <<HTML
<!DOCTYPE html><html><head><meta charset="UTF-8"><title>Concordances ar-$n</title></head>
<body><h2>Concordances ar-$n</h2><p>Download vide (HTTP=$http)</p></body></html>
HTML
    enc="na"
    row_class="eq"
  else
    # 2) Extraction texte
    pandoc -f html -t plain "$html" -o "$txt" 2>/dev/null || true
    [ -s "$txt" ] || echo "[ERREUR] extraction texte vide: $url" > "$txt"

    # 3) Encodage
    enc="$(file -I "$txt" 2>/dev/null | sed -E 's/.*charset=([^ ]+).*/\1/' || true)"
    [ -n "${enc:-}" ] || enc="unknown"

    # 4) Occurrences séparées + total
    occ1="$(grep -Eo "$PAT1" "$txt" | wc -l | tr -d ' ' || true)"
    occ2="$(grep -Eo "$PAT2" "$txt" | wc -l | tr -d ' ' || true)"
    occ1="${occ1:-0}"
    occ2="${occ2:-0}"
    total=$((occ1 + occ2))

    # Couleur de ligne
    row_class="eq"
    if [ "$occ1" -gt "$occ2" ]; then
      row_class="w1"
    elif [ "$occ2" -gt "$occ1" ]; then
      row_class="w2"
    fi

    # 5) Contextes (multilignes, lisibles)
    {
      echo "URL: $url"
      echo "PAT1 (دولة): $PAT1"
      echo "PAT2 (حالة): $PAT2"
      echo "----- CONTEXTES (±3 lignes) -----"
      grep -En -C 3 "$PAT_CTX" "$txt" || true
    } > "$ctx"

    # 6) Concordancier HTML (toutes les occurrences en une ligne KWIC)
    kwic_lines="$(perl -0777 -ne '
      s/\s+/ /g;
      my $re = qr/'"$PAT_CTX"'/;
      my @out;
      while (/(.{0,40})($re)(.{0,40})/g) {
        push @out, "$1\[$2\]$3";
      }
      print join("\n", @out);
    ' "$txt" || true)"

    {
      echo '<!DOCTYPE html><html><head><meta charset="UTF-8" />'
      echo "<title>Concordances ar-$n</title></head>"
      echo '<body style="font-family: Arial, Helvetica, sans-serif;">'
      echo "<h2>Concordances ar-$n</h2>"
      echo "<p><b>URL:</b> <a href=\"$url\">$url</a></p>"
      echo "<pre>"
      if [ -n "${kwic_lines:-}" ]; then
        printf "%s\n" "$kwic_lines"
      else
        echo "Aucune occurrence trouvée."
      fi
      echo "</pre></body></html>"
    } > "$conc"
  fi

  # Liens relatifs depuis tableaux/arabe/ar.html
html_rel="$BASE_GH/aspirations/$LANGUE/ar-$n.html"
txt_rel="$BASE_GH/dumps-text/$LANGUE/ar-$n.txt"
ctx_rel="$BASE_GH/contextes/$LANGUE/ar-$n.txt"
conc_rel="$BASE_GH/concordances/$LANGUE/ar-$n.html"


  cat >> "$OUTHTML" <<HTML
<tr class="$row_class">
  <td>$n</td>
  <td><a href="$url">$url</a></td>
  <td>$occ1</td>
  <td>$occ2</td>
  <td>$total</td>
  <td>$enc</td>
  <td>$http</td>
  <td><a href="$html_rel">html</a></td>
  <td><a href="$txt_rel">txt</a></td>
  <td><a href="$ctx_rel">ctx</a></td>
  <td><a href="$conc_rel">conc</a></td>
</tr>
HTML

done < "$URLFILE"

cat >> "$OUTHTML" <<'HTML'
</table>
</body>
</html>
HTML

echo "OK : $OUTHTML généré"
