#!/usr/bin/env bash
alias python=/mingw64/bin/python3.exe
while true; do
lualatex --interaction=nonstopmode --halt-on-error --shell-escape manual
read -p "Press [enter] to compile again"
done

