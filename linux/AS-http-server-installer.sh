#!/bin/bash

# Цветовые коды для красивого вывода
GREEN=$(tput setaf 2)
RESET=$(tput sgr0)
RED=$(tput setaf 1)

# 1. Загрузка AS-http-server.sh в ту же директорию, где и установщик
echo "${GREEN}Downloading AS-http-server.sh...${RESET}"
curl -s -O "https://raw.githubusercontent.com/administrati0n/http-master/main/linux/AS-http-server.sh"
curl -s -O "https://raw.githubusercontent.com/administrati0n/http-master/main/linux/AS-http-server.txt"
chmod +x AS-http-server.sh
# brew install duti
# duti -s com.apple.Terminal .sh all

# 2. Запрашиваем путь к проекту
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

# Обновляем файл AS-http-server.sh, заменяя путь к проекту
# Обновляем файл AS-http-server.sh, заменяя путь к проекту
sed -i.bak "s#cd ~/Documents/Web/admin\\\\ inc/as/ || { echo \"Directory not found\"; exit 1; }#$PROJECT_PATH || { echo \"Directory not found\"; exit 1; }#g" AS-http-server.sh


rm AS-http-server.sh.bak

# 3. Проверка необходимых компонентов для работы http-server
if ! command -v http-server &> /dev/null; then
    echo "${RED}http-server not found! Install it with npm or another package manager.${RESET}"
    exit 1
fi
# Добавьте другие необходимые проверки по вашему усмотрению

# 4. Предложение создать ярлык
echo "Where would you like to create a shortcut for AS-http-server.sh?"
echo "1 - Desctop"
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
# duti -s com.apple.Terminal .sh all

