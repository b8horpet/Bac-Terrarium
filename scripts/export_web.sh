#!/bin/bash

rm -rf ./export/web
mkdir -p ./export/web
godot --headless --path . --export-release Web ./export/web/bac_terrarium.html
mv ./export/web/bac_terrarium.html ./export/web/index.html
zip -j ./export/web/bac_terrarium.zip ./export/web/*

