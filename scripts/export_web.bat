@echo off

rmdir /s /q .\export\web
mkdir .\export\web
C:\Programs\Godot\Godot_v4.4.1-stable_win64.exe --headless --path . --export-release Web .\export\web\bac_terrarium.html
rename .\export\web\bac_terrarium.html index.html
zip -j export\web\bac_terrarium.zip export\web\*

