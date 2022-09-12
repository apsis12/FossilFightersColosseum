#!/bin/sh

[ -s ./Spreadsheet/VivoMeta.xlsx ] || exit 1
[ -s ./Spreadsheet/VivoSkill.xlsx ] || exit 1

mkdir -p ./Json

python3 ./xlsx-to-json.py     ./Spreadsheet/VivoMeta.xlsx  > ./Json/vivodata.json
python3 ./xlsx-to-json.py -3d ./Spreadsheet/VivoSkill.xlsx > ./Json/vivoskill.json
