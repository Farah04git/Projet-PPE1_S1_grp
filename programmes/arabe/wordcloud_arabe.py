from wordcloud import WordCloud
import matplotlib.pyplot as plt
import arabic_reshaper
from bidi.algorithm import get_display
import os
import re
import glob

# Dossier contenant les fichiers texte générés (ar-1.txt, ar-2.txt, ...)
# (chemin relatif au dossier du projet)
input_folder = "dumps-text/arabe"

# Pattern des fichiers
pattern = os.path.join(input_folder, "ar-*.txt")
files = sorted(glob.glob(pattern))

if not files:
    raise FileNotFoundError(f"Aucun fichier trouvé avec le pattern: {pattern}")

# Stopwords simples (tu peux agrandir la liste)
stopwords = {"في", "و", "من", "على", "أن", "عن", "ما", "مع", "هذا", "هذه"}

# Lire et concaténer tous les textes
all_text_parts = []
for fp in files:
    with open(fp, "r", encoding="utf-8", errors="ignore") as f:
        all_text_parts.append(f.read())

text = "\n".join(all_text_parts)

# Nettoyage: garder arabe + espaces, normaliser espaces
text = text.replace("\n", " ")
text = re.sub(r"[^\u0600-\u06FF\s]+", " ", text)  # garde lettres arabes
text = re.sub(r"\s+", " ", text).strip()

# Stopwords + petits mots
words = [w for w in text.split() if w not in stopwords and len(w) > 1]

# Reshape + Bidi mot par mot
# Hack WordCloud: inversion pour compenser le rendu LTR
final_words = []
for w in words:
    reshaped = arabic_reshaper.reshape(w)
    bidi_word = get_display(reshaped)
    final_words.append(bidi_word[::-1])

final_text = " ".join(final_words)

# Police (macOS). Si ça échoue, on tente une alternative.
font_path = "/System/Library/Fonts/Supplemental/Arial Unicode.ttf"
if not os.path.exists(font_path):
    alt = "/System/Library/Fonts/Supplemental/Arial.ttf"
    if os.path.exists(alt):
        font_path = alt
    else:
        raise FileNotFoundError(
            "Police introuvable. Installe une police qui supporte l'arabe "
            "ou modifie font_path."
        )

# Générer le nuage
wc = WordCloud(
    width=1400,
    height=800,
    background_color="white",
    font_path=font_path,
    collocations=False,
    prefer_horizontal=1.0
).generate(final_text)

# Dossier de sortie : nuages/arabe
output_folder = "nuages/arabe"
os.makedirs(output_folder, exist_ok=True)

output_path = os.path.join(output_folder, "nuage_arabe.png")

wc.to_file(output_path)

# Affichage
plt.figure(figsize=(14, 8))
plt.imshow(wc, interpolation="bilinear")
plt.axis("off")
plt.tight_layout()
plt.show()

print("Fichiers utilisés :", len(files))
print("Nuage enregistré :", output_path)
