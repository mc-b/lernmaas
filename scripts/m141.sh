#!/bin/bash
#
#   Modul 141 - Datenbanksystem in Betrieb nehmen
#
#   Diese Umgebung basiert auf einer Vertiefungsarbeit an der TBZ HF von Gaétan Vouillamoz - https://github.com/zoink1989/vertiefungsarbeit

# BeakerX, Datenbank und DB UI starten
kubectl apply -f https://raw.githubusercontent.com/mc-b/duk/master/jupyter/beakerx.yaml
kubectl apply -f https://raw.githubusercontent.com/mc-b/duk/master/mysql/mysql.yaml
kubectl apply -f https://raw.githubusercontent.com/mc-b/duk/master/mysql/adminer.yaml

# Notebook fuer BeakerX ablegen
mkdir -p /data/beakerx
wget https://raw.githubusercontent.com/tbz-k8s/vertiefungsarbeit/master/01_01_Einfu%CC%88hrung_LP.ipynb -O /data/beakerx/M141_Einfuehrung.ipynb

