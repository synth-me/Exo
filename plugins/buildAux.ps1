lsc -c Resilience.ls
lsc -c serverAux.ls
micro serverAux.js
del serverAux.exe
pkg serverAux.js
del serverAux-linux
del serverAux-macos

Rename-Item "serverAux-win.exe" "serverAux.exe" 
echo "Done !"
