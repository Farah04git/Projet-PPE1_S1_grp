#!/bin/bash
set -e

# =====================================
# RUN PALS – Arabe
# Pôles : حالة / دولة
# Script situé dans : pals/PALS_arabe/
# =====================================

# Déterminer la racine du projet (on remonte de 2 niveaux)
PROJECT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

# Dossiers d'entrée / sortie
CONTEXTES="$PROJECT_ROOT/contextes"
RESULTATS="$PROJECT_ROOT/resultats"

# Dossier PALS (celui où se trouve ce script)
PALS_DIR="$(cd "$(dirname "$0")" && pwd)"

# Trouver le script Perl PALS
PALS_PL="$(ls "$PALS_DIR"/*.pl 2>/dev/null | head -n 1)"

# Créer le dossier résultats si nécessaire
mkdir -p "$RESULTATS"

# --------- Affichage de contrôle ---------
echo "PROJECT_ROOT = $PROJECT_ROOT"
echo "CONTEXTES    = $CONTEXTES"
echo "RESULTATS    = $RESULTATS"
echo "PALS_DIR     = $PALS_DIR"
echo

# --------- Vérifications ---------
if [[ ! -d "$CONTEXTES" ]]; then
  echo "❌ ERREUR : dossier contextes introuvable : $CONTEXTES"
  exit 1
fi

if [[ -z "$PALS_PL" ]]; then
  echo "❌ ERREUR : aucun script .pl trouvé dans : $PALS_DIR"
  echo "Contenu du dossier :"
  ls -la "$PALS_DIR"
  exit 1
fi

echo "✅ Script PALS détecté : $PALS_PL"
echo

# --------- Exécution PALS ---------
# Certains scripts PALS nécessitent d'être lancés depuis leur dossier
cd "$PALS_DIR"

echo "▶️ Lancement PALS pour حالة..."
perl "$PALS_PL" "$CONTEXTES" "حالة" > "$RESULTATS/pals_hala.txt"

echo "▶️ Lancement PALS pour دولة..."
perl "$PALS_PL" "$CONTEXTES" "دولة" > "$RESULTATS/pals_dawla.txt"

echo
echo "✅ Analyse terminée."
echo "Fichiers générés :"
echo " - $RESULTATS/pals_hala.txt"
echo " - $RESULTATS/pals_dawla.txt"
