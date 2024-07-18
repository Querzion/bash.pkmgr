#!/bin/bash

# Base directory and path to the package list file
BASEDIR="$HOME/order_66"
FROM_PACKAGES_LIST="$BASEDIR/packages.txt"
ERROR_LOG="$HOME/install.errors.txt"

# Color definitions
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

############################################################################################################################### FUNCTION
################### PREREQUSITES | INSTALLATION OF PACKAGE MANAGERS

install_aur_helper() {
    local helper=$1

    if [[ -z "$helper" ]]; then
        echo -e "${RED} Usage: install_aur_helper <helper_name>${NC}"
        return 1
    fi

    if command -v "$helper" &>/dev/null; then
        echo -e "${GREEN} $helper is already installed.${NC}"
        return 0
    fi

    echo -e "${CYAN} Installing $helper...${NC}"

    sudo pacman -S --needed base-devel git

    git clone https://aur.archlinux.org/${helper}.git
    cd $helper || { echo -e "${RED} Failed to enter directory${NC}"; return 1; }

    makepkg -si

    cd ..
    rm -rf $helper

    echo -e "${GREEN} $helper installed successfully.${NC}"
}

install_flatpak() {
    if command -v flatpak &>/dev/null; then
        echo -e "${GREEN} flatpak is already installed.${NC}"
        return 0
    fi

    echo -e "${CYAN} Installing flatpak...${NC}"

    sudo pacman -S flatpak

    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

    flatpak update

    echo -e "${GREEN} flatpak installed successfully.${NC}"
}

install_package_managers() {
    install_aur_helper paru
    install_aur_helper yay
    install_flatpak
}

package_manager_version() {
    
    echo -e "${YELLOW}                       $(yay --version)${NC}"
    echo -e "${YELLOW}                       $(paru --version)${NC}"
    echo -e "${YELLOW}                       $(flatpak --version)${NC}"
    echo -e "${YELLOW}  $(pacman --version)${NC}"
}

############################################################################################################################### FUNCTION
################### INSTALLATION OF PACKAGES


# Function to install packages using different package managers
install_package() {
    local manager=$1
    local package=$2

    # Check if the package is already installed
    case "$manager" in
        pacman)
            if pacman -Q "$package" &>/dev/null; then
                echo -e "${YELLOW} Package $package is already installed. Skipping.${NC}"
                return
            fi
            ;;
        yay|paru)
            if pacman -Q "$package" &>/dev/null; then
                echo -e "${YELLOW} Package $package is already installed. Skipping.${NC}"
                return
            fi
            ;;
        flatpak)
            if flatpak list --app | grep -q "$package"; then
                echo -e "${YELLOW} Package $package is already installed. Skipping.${NC}"
                return
            fi
            ;;
        *)
            echo -e "${BLUE} Unknown package manager: $manager${NC}"
            return
            ;;
    esac

    # Attempt to install the package
    case "$manager" in
        pacman)
            echo -e "${PURPLE} Installing $package with $manager...${NC}"
            sudo pacman -S --noconfirm "$package" || echo "$manager $package" >> "$ERROR_LOG"
            ;;
        yay)
            echo -e "${PURPLE} Installing $package with $manager...${NC}"
            yay -S --noconfirm "$package" || echo "$manager $package" >> "$ERROR_LOG"
            ;;
        paru)
            echo -e "${PURPLE} Installing $package with $manager...${NC}"
            paru -S --noconfirm "$package" || echo "$manager $package" >> "$ERROR_LOG"
            ;;
        flatpak)
            echo -e "${PURPLE} Installing $package with $manager...${NC}"
            remote=$(echo "$package" | cut -d'/' -f1)
            app_id=$(echo "$package" | cut -d'/' -f2-)
            flatpak install -y "$remote" "$app_id" || echo "$manager $package" >> "$ERROR_LOG"
            ;;
    esac
}

# Function to read the package list and install packages
read_package_list() {
    local package_list="$1"

    # Read the package list file line by line
    while IFS= read -r line; do
        # Skip empty lines and lines starting with #
        [[ -z "$line" || "$line" =~ ^# ]] && continue

        # Parse the line to get the package manager and package name
        if [[ "$line" =~ ^\"(.+)\"\ \"(.+)\" ]]; then
            manager="${BASH_REMATCH[1]}"
            package="${BASH_REMATCH[2]}"
            install_package "$manager" "$package"
        fi
    done < "$package_list"
}

############################################################################################################################### FUNCTION
################### MAIN

# Install package managers paru, yay, flatpak.
install_package_managers
install_package_managers # to ensure that they are indeed installed
    
# Check the version of pacman, yay, paru, flatpak
package_manager_version
    
# Pause the script
echo -e "${GREEN} PRESS ENTER TO CONTINUE. ${NC}"
read

# Clear the error log file
> "$ERROR_LOG"

# Call the function to read the package list and install packages
echo -e "${CYAN} Starting package installation...${NC}"
read_package_list "$FROM_PACKAGES_LIST"
echo -e "${CYAN} Package installation complete.${NC}"

# Check if there were any errors
if [[ -s "$ERROR_LOG" ]]; then
    echo -e "${RED} Some packages failed to install. See $ERROR_LOG for details.${NC}"
else
    echo -e "${GREEN} All packages installed successfully.${NC}"
fi


