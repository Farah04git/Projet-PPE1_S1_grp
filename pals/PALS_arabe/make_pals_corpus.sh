#!/usr/bin/env bash
set -euo pipefail

# Se placer à la racine du projet
cd "$(dirname "$0")/../.." || exit 1

# Où lire les fichiers arabes
DUMP_DIR="dumps-text/arabe"
CTX_DIR="contextes/arabe"

# Où écrire les fichiers PALS arabes (dans ce dossier)
OUT_DIR="pals/PALS_arabe"
mkdir -p "$OUT_DIR"

ALL_DUMPS="$OUT_DIR/dumps_AR.txt"
ALL_CONTEXTES="$OUT_DIR/contextes_AR.txt"

# Vérifs
if [[ ! -d "$DUMP_DIR" ]]; then
  echo "❌ Dossier introuvable: $DUMP_DIR"
  exit 1
fi
if [[ ! -d "$CTX_DIR" ]]; then
  echo "❌ Dossier introuvable: $CTX_DIR"
  exit 1
fi

echo "PROJECT_ROOT = $(pwd)"
echo "DUMP_DIR     = $DUMP_DIR"
echo "CTX_DIR      = $CTX_DIR"
echo "OUT_DIR      = $OUT_DIR"
echo

# Tokenisation Unicode arabe: on extrait des séquences arabes
python3 - <<'PY'
import re, glob, pathlib

arabic_word = re.compile(r"[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF]+")

def fuse_and_tokenize(src_glob, out_path):
    tokens = []
    for fn in sorted(glob.glob(src_glob)):
        txt = pathlib.Path(fn).read_text(encoding="utf-8", errors="ignore")
        tokens.extend(arabic_word.findall(txt))
    pathlib.Path(out_path).write_text("\n".join(tokens) + "\n", encoding="utf-8")

fuse_and_tokenize("dumps-text/arabe/*.txt", "pals/PALS_arabe/dumps_AR.txt")
fuse_and_tokenize("contextes/arabe/*.txt",  "pals/PALS_arabe/contextes_AR.txt")

print("✅ OK : fichiers créés")
print(" - pals/PALS_arabe/dumps_AR.txt")
print(" - pals/PALS_arabe/contextes_AR.txt")
PY
