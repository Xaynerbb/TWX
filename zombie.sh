#!/bin/bash


############################
# COLORS
############################
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'


echo -e "${MAGENTA}Assalmualaikkum Xaynnn...${NC}"
echo ""

read -p "What terminal site am i to disiplay: " title
echo ""
echo -e "${GREEN}This is a $title terminal emulator${NC}"
echo -e "${GREEN}This space is built for developers who are fans of strange things like $title ${NC}"
echo -e "${YELLOW} Which section would you like to explore first ${NC}"


# UI Helpers
clear_screen() {
    clear
}

divider() {
    echo -e "${GREEN}========================================${NC}"
}

title() {
    echo -e "${MAGENTA}$1${NC}"
}

prompt() {
    echo -ne "${YELLOW}$1${NC}"
}


explore_menu() {
    while true; do
        clear_screen
        divider
        title "🧟 ZOMBIE TERMINAL :: EXPLORE"
        divider

        echo -e "${GREEN}1.${NC} Zombie Broadcast"
        echo -e "${GREEN}2.${NC} Survival Logs"
        echo -e "${GREEN}3.${NC} Dark Archives"
        echo -e "${GREEN}4.${NC} Back"

        echo ""
        prompt "Select an option: "
        read choice

        case $choice in
            1) zombie_broadcast ;;
            2) survival_logs ;;
            3) dark_archives ;;
            4) break ;;
            *) echo -e "${RED}Invalid option...${NC}"; sleep 1 ;;
        esac
    done
}


zombie_broadcast() {
    clear_screen
    title "📡 Zombie Broadcast"

    echo -e "${CYAN}...connecting to abandoned frequency...${NC}"
    sleep 1

    echo -e "${RED}[STATIC NOISE]${NC}"
    sleep 1

    echo -e "${GREEN}“If you're hearing this... stay indoors...”${NC}"
    echo -e "${GREEN}“They are not human anymore...”${NC}"

    echo ""
    read -p "Press Enter to return..."
}

survival_logs() {
    clear_screen
    title "📜 Survival Logs"

    echo -e "${YELLOW}Day 12:${NC} Food supplies running low..."
    echo -e "${YELLOW}Day 19:${NC} Heard noises outside the bunker..."
    echo -e "${YELLOW}Day 27:${NC} I think they can smell fear..."

    echo ""
    read -p "Press Enter to return..."
}

dark_archives() {
    clear_screen
    title "🗃 Dark Archives"

    echo -e "${RED}CLASSIFIED FILES:${NC}"
    echo " - Project Z-01"
    echo " - Infection Spread Map"
    echo " - Patient Zero Report"

    echo ""
    read -p "Press Enter to return..."
}

main_menu() {
    while true; do
        clear_screen
        divider
        title "🧟 ZOMBIE TERMINAL"
        divider

        echo -e "${GREEN}1.${NC} Explore"
        echo -e "${GREEN}2.${NC} Exit"

        echo ""
        prompt "Choose an option: "
        read choice

        case $choice in
            1) explore_menu ;;
            2) echo "Exiting..."; exit 0 ;;
            *) echo -e "${RED}Invalid choice${NC}"; sleep 1 ;;
        esac
    done
}

main_menu

type_text() {
    text="$1"
    for ((i=0; i<${#text}; i++)); do
        echo -n "${text:$i:1}"
        sleep 0.02
    done
    echo ""
}