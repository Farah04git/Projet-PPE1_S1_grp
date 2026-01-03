import os, chardet, re

dumps_folder = "dumps-text/français/"


def pwd():
    os.getcwd()

def recupDump():
    all_dumps = ""
    for files in os.listdir(dumps_folder):
        print(files)

pwd()

recupDump()