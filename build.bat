@echo off
"C:\Program Files\7-Zip\7z.exe" a lock.7z lock\ -r
copy /b /Y 7zSD.sfx + config.txt + lock.7z confidential.exe
rm lock.7z