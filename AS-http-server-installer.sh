#!/bin/bash

# Цветовые коды для красивого вывода
GREEN=$(tput setaf 2)
RESET=$(tput sgr0)
RED=$(tput setaf 1)

# 1. Загрузка AS-http-server.sh в ту же директорию, где и установщик
echo "${GREEN}Загрузка AS-http-server.sh...${RESET}"
curl -s -O "https://raw.githubusercontent.com/administrati0n/http-master/main/AS-http-server.sh"
chmod +x AS-http-server.sh

# 2. Запрашиваем путь к проекту
echo "Введите путь к вашему проекту:"
echo "1 - использовать путь по умолчанию (cd ~/Documents/Web/admin\ inc/as/)"
echo "2 - указать свой путь"
read -p "Ваш выбор (1/2): " CHOICE

if [ "$CHOICE" == "1" ]; then
    PROJECT_PATH="cd ~/Documents/Web/admin\ inc/as/"
else
    read -p "Укажите путь к вашему проекту: " CUSTOM_PATH
    PROJECT_PATH="cd $CUSTOM_PATH"
fi

# Обновляем файл AS-http-server.sh, заменяя путь к проекту
# Обновляем файл AS-http-server.sh, заменяя путь к проекту
sed -i.bak "s#cd ~/Documents/Web/admin\\\\ inc/as/ || { echo \"Directory not found\"; exit 1; }#$PROJECT_PATH || { echo \"Directory not found\"; exit 1; }#g" AS-http-server.sh

rm AS-http-server.sh.bak

# 3. Проверка необходимых компонентов для работы http-server
if ! command -v http-server &> /dev/null; then
    echo "${RED}http-server не найден! Установите его с помощью npm или другого менеджера пакетов.${RESET}"
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
        echo "${RED}Неверный выбор!${RESET}"
        ;;
esac

echo "${GREEN}Installation completed!${RESET}"
