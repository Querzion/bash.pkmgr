# bash.pkmgr
Package Manager & Packages Installer.
```bash
git clone https://github.com/Querzion/bash.pkmgr.git $HOME
```
```bash
chmod +x -r $HOME/bash.pkmgr
```
```bash
sh $HOME/bash.pkmgr/installer.sh
```
### INSTALLS
  - Paru
  - Yay
  - Flatpak
### REDUNDANCY
  -  In order to verify that they are actually installed, it's going to go through the installation of the package managers twice.
  -  Updates the system before going through any installations.
### INFO
This script was created in order to install packages that are in the format of ("packagemanager" "package" (Optional) # Description)
  - YAY ex. "yay" "spotify-adblock" # Spotify with adblock
  - FLATPAK ex. "flatpak" "flathub/org.gimp.GIMP" # GIMP image editor
  - PARU ex. "paru" "neovim" # Neovim text editor
  - PACMAN ex "pacman" "fastfetch" # Terminal Utility
### USAGE
  -  Make a txt file: "package.txt"
  -  Place it in $HOME/order_66 (so make that folder.)

