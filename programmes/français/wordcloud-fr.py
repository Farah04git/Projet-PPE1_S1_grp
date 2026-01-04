import os, chardet, re
import matplotlib.pyplot as plt

dumps_folder = "dumps-text/français/"
output = "output-wordcloud.txt"


def read_convert(path):
    with open(path, "rb") as f:
        raw = f.read()

    result_chardet = chardet.detect(raw)

    try:
        text = raw.decode(enc)
    except Exception:
        text = raw.decode("latin-1", errors='replace')

    return text

def pwd():
    os.getcwd()

def recupDump():
    all_dumps = ""
    
    for files in os.listdir(dumps_folder):
        path = os.path.join(dumps_folder, files)
        
        txt = read_convert(path)
        all_dumps += txt + "\n"

    with open(output, 'w', encoding='utf-8') as out:
        out.write(all_dumps)
            
 
            


pwd()

recupDump()