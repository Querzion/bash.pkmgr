#!/bin/bash

# Define colors
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to print messages with colors
print_message() {
    echo -e "${2}${1}${NC}"
}

# Function to check and update pacman
update_pacman() {
    if command -v pacman &> /dev/null; then
        print_message "Updating system with pacman..." $CYAN
        sudo pacman -Syu
    else
        print_message "pacman is not installed." $YELLOW
    fi
}

# Function to check and update yay
update_yay() {
    if command -v yay &> /dev/null; then
        print_message "Updating system with yay..." $CYAN
        yay -Syu
    else
        print_message "yay is not installed." $YELLOW
    fi
}

# Function to check and update paru
update_paru() {
    if command -v paru &> /dev/null; then
        print_message "Updating system with paru..." $CYAN
        paru -Syu
    else
        print_message "paru is not installed." $YELLOW
    fi
}

# Function to check and update flatpak
update_flatpak() {
    if command -v flatpak &> /dev/null; then
        print_message "Updating system with flatpak..." $CYAN
        sudo flatpak update -y
    else
        print_message "flatpak is not installed." $YELLOW
    fi
}

# Main script execution
print_message "Starting system update..." $PURPLE

update_pacman
update_yay
update_paru
update_flatpak

print_message "System update completed!" $GREEN
