#!/usr/bin/env bash
set -euo pipefail

URLFILE="URLs/ar.txt"
LANG="arabe"

ASP_DIR="aspirations/$LANG"
DUMP_DIR="dumps-text/$LANG"
CTX_DIR="contextes/$LANG"
TAB_DIR="tableaux/$LANG"

OUTHTML="$TAB_DIR/ar.html"

# 2 patterns séparés + total
PAT1='(ال)?دول(ة|ات|ي|ية|يون|يات|تي|ته|تها|تهم|تنا|كم|كن|نا|ي)?'
PAT2='(ال)?حال(ة|ات|ي|ية|ته|تها|تهم|تنا|كم|كن|نا|ي)?'
PAT_CTX="($PAT1|$PAT2)"

N=50

mkdir -p "$ASP_DIR" "$DUMP_DIR" "$CTX_DIR" "$TAB_DIR"

if [ ! -f "$URLFILE" ]; then
  echo "Erreur: fichier introuvable: $URLFILE" >&2
  exit 1
fi

cat > "$OUTHTML" <<'HTML'
<html>
<head>
  <meta charset="UTF-8" />
  <title>Arabe – état (دولة / حالة)</title>
  <style>
    body { background:#000; color:#fff; font-family: Arial, Helvetica, sans-serif; }
    table { border-collapse: collapse; width:100%; }
    th, td { border:1px solid #444; padding:6px; text-align:left; }
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
<table border="1">
<tr>
  <th>#</th>
  <th>URL</th>
  <th>Occ. (دولة)</th>
  <th>Occ. (حالة)</th>
  <th>Total</th>
  <th>Encodage</th>
  <th>HTML</th>
  <th>Texte</th>
  <th>Contextes</th>
</tr>
HTML


n=0

while IFS= read -r url; do
  [ -z "${url// /}" ] && continue

  n=$((n+1))
  if [ "$n" -gt "$N" ]; then
    break
  fi

  html="$ASP_DIR/ar-$n.html"
  txt="$DUMP_DIR/ar-$n.txt"
  ctx="$CTX_DIR/ar-$n.txt"

  # 1) Téléchargement
  curl -s -L -A "Mozilla/5.0" -o "$html" "$url" || true

  if [ ! -s "$html" ]; then
    echo "[ERREUR] téléchargement vide: $url" > "$txt"
    : > "$ctx"
    occ1=0
    occ2=0
    total=0
    row_class="eq"
    enc="na"
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

row_class="eq"
if [ "$occ1" -gt "$occ2" ]; then
  row_class="w1"
elif [ "$occ2" -gt "$occ1" ]; then
  row_class="w2"
fi


    # 5) Contextes des deux
    grep -En -C 3 "$PAT_CTX" "$txt" > "$ctx" || true
  fi

  # Liens relatifs depuis tableaux/arabe/ar.html
  html_rel="../../aspirations/$LANG/ar-$n.html"
  txt_rel="../../dumps-text/$LANG/ar-$n.txt"
  ctx_rel="../../contextes/$LANG/ar-$n.txt"

  cat >> "$OUTHTML" <<HTML
<tr class="$row_class">
  <td>$n</td>
  <td><a href="$url">$url</a></td>
  <td>$occ1</td>
  <td>$occ2</td>
  <td>$total</td>
  <td>$enc</td>
  <td><a href="$html_rel">html</a></td>
  <td><a href="$txt_rel">txt</a></td>
  <td><a href="$ctx_rel">ctx</a></td>
</tr>
HTML

done < "$URLFILE"

cat >> "$OUTHTML" <<'HTML'
</table>
</body>
</html>
HTML

echo "OK : $OUTHTML généré"
