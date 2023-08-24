#!/bin/bash

GREEN=$(tput setaf 2)
RESET=$(tput sgr0)
RED=$(tput setaf 1)

if ! command -v curl &> /dev/null; then
    echo "${RED}curl not found! Installing it...${RESET}"
    
    if command -v apt &> /dev/null; then
        sudo apt update
        sudo apt install -y curl
    elif command -v yum &> /dev/null; then
        sudo yum install -y curl
    elif command -v pacman &> /dev/null; then
        sudo pacman -Sy curl
    else
        echo "${RED}Cannot find a suitable package manager to install curl.${RESET}"
        exit 1
    fi
fi

echo "${GREEN}Downloading AS-http-server.sh...${RESET}"
curl -s -O "https://raw.githubusercontent.com/administrati0n/http-master/main/linux/AS-http-server.sh"
curl -s -O "https://raw.githubusercontent.com/administrati0n/http-master/main/linux/AS-http-server.txt"
chmod +x AS-http-server.sh

echo "Enter the path to your project:"
echo "1 - use default path (cd ~/Documents/Web/admin\ inc/as/)"
echo "2 - point your way"
read -p "Your choice (1/2): " CHOICE

if [ "$CHOICE" == "1" ]; then
    PROJECT_PATH="cd ~/Documents/Web/admin\ inc/as/"
else
    read -p "Specify the path to your project: " CUSTOM_PATH
    PROJECT_PATH="cd $CUSTOM_PATH"
fi

sed -i.bak "s#cd ~/Documents/Web/admin\ inc/as/ || { echo \"Directory not found\"; exit 1; }#$PROJECT_PATH || { echo \"Directory not found\"; exit 1; }#g" AS-http-server.sh
rm AS-http-server.sh.bak

if ! command -v node &> /dev/null; then
    echo "${RED}Node.js not found! Installing it...${RESET}"
    
    if command -v apt &> /dev/null; then
        sudo apt install -y nodejs
    elif command -v yum &> /dev/null; then
        sudo yum install -y nodejs
    elif command -v pacman &> /dev/null; then
        sudo pacman -Sy nodejs
    else
        echo "${RED}Cannot find a suitable package manager to install Node.js.${RESET}"
        exit 1
    fi
fi

if ! command -v npm &> /dev/null; then
    echo "${RED}npm not found! Installing it...${RESET}"
    
    if command -v apt &> /dev/null; then
        sudo apt install -y npm
    elif command -v yum &> /dev/null; then
        sudo yum install -y npm
    elif command -v pacman &> /dev/null; then
        sudo pacman -Sy npm
    else
        echo "${RED}Cannot find a suitable package manager to install npm.${RESET}"
        exit 1
    fi
fi

if ! command -v http-server &> /dev/null; then
    echo "${RED}http-server not found! Installing it with npm...${RESET}"
    npm install -g http-server
fi

echo "Where would you like to create a shortcut for AS-http-server.sh?"
echo "1 - Desktop"
echo "2 - Downloads"
echo "3 - Documents"
read -p "Your choice (1/2/3): " SHORTCUT_CHOICE

case $SHORTCUT_CHOICE in
1)
    ln -s "$(pwd)/AS-http-server.sh" ~/Desktop/
    ;;
2)
    ln -s "$(pwd)/AS-http-server.sh" ~/Downloads/
    ;;
3)
    ln -s "$(pwd)/AS-http-server.sh" ~/Documents/
    ;;
*)
    echo "${RED}Wrong choice!${RESET}"
    ;;
esac

echo "${GREEN}Installation completed!${RESET}"
