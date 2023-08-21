#!/bin/bash

YELLOW=$(tput setaf 3)
GREEN=$(tput setaf 2)
RESET=$(tput sgr0)
NO_FORMAT="\033[0m"
F_BOLD="\033[1m"
F_INVERT="\033[7m"
C_WHITE="\033[38;5;15m"
C_GREY0="\033[48;5;16m"
CURRENT_VERSION="1.0.0"  # пример текущей версии
AUTO_UPDATE=false 
GITHUB_REPO_URL="https://github.com/administrati0n/http-master"
echo "${GREEN}"
echo "Server is starting..."

# Проверка наличия http-server
if ! command -v http-server &> /dev/null; then
    echo "http-server is not installed or not in the PATH."
    exit 1
fi

# Переход к директории сервера
cd ~/Documents/Web/admin\ inc/as/ || { echo "Directory not found"; exit 1; }

# Запуск сервера и получение его PID
http-server > /tmp/http_server_logs 2>&1 &
SERVER_PID=$!
sleep 2  # дадим серверу некоторое время на запуск и запись логов

# Извлечение IP-адресов и портов из лога сервера
AVAILABLE_ADDRESSES=($(grep -oE "http://[0-9.]+:[0-9]+" /tmp/http_server_logs))

# При завершении скрипта убиваем процесс http-server
trap "kill $SERVER_PID 2> /dev/null" EXIT

# Функция для вывода живых логов в новом окне терминала
view_live_logs() {
    osascript <<END
    tell application "Terminal"
        do script "tail -f /tmp/http_server_logs"
        activate
    end tell
END
}

settings_menu() {
    while true; do
        printf '\033c'
        echo "Settings:"
        echo "1. Check for Updates"
        if [ "$AUTO_UPDATE" == "true" ]; then
            echo -e "2. Auto Update: ${GREEN}True${RESET}"
        else
            echo -e "2. Auto Update: ${RED}False${RESET}"
        fi
        echo "3. Return to main menu"
        echo "Enter your choice:"
        read SETTINGS_CHOICE
        case $SETTINGS_CHOICE in
            1)
                echo "Checking for updates..."
                LATEST_VERSION=$(curl -s "https://raw.githubusercontent.com/administrati0n/http-master/master/ASV.txt")  # получаем последнюю версию
                if [ "$LATEST_VERSION" != "$CURRENT_VERSION" ]; then
                    echo "Update available!"
                    echo "Current version: $CURRENT_VERSION"
                    echo "Latest version: $LATEST_VERSION"
                    if [ "$AUTO_UPDATE" == "true" ]; then
                        echo "Auto updating..."

                        TMP_FILE=$(mktemp)  # создаем временный файл
                        echo "Downloading to: $TMP_FILE"
                        
                        curl -s "https://raw.githubusercontent.com/administrati0n/http-master/main/AS-http-server.sh"
                        # Проверяем, был ли файл успешно загружен
                        if [ $? -eq 0 ] && [ -s "$TMP_FILE" ]; then
                            echo "Downloaded new version successfully. Checking content:"
                            head "$TMP_FILE"  # показываем начало файла для проверки

                            # Перемещаем временный файл на место старого
                            mv "$TMP_FILE" "$0"
                            if [ $? -eq 0 ]; then
                                echo "Replaced old version successfully."
                                chmod +x "$0"
                                echo "Update complete!"
                            else
                                echo "Failed to replace old version!"
                            fi
                        else
                            echo "Failed to download new version or file is empty!"
                        fi
                        
                    else
                        echo "Please update manually or enable auto update."
                    fi
                else
                    echo "You have the latest version!"
                fi
                read -p "Press enter to continue..."
                ;;
            2)
                if [ "$AUTO_UPDATE" == "true" ]; then
                    AUTO_UPDATE=false
                else
                    AUTO_UPDATE=true
                fi
                ;;
            3)
                return
                ;;
            *)
                echo "Invalid choice!"
                read -p "Press enter to continue..."
                ;;
        esac
    done
}



# Функция для вывода меню
print_menu() {
    printf '\033c'
NO_FORMAT="\033[0m"
F_BOLD="\033[1m"
F_INVERT="\033[7m"
C_WHITE="\033[38;5;15m"
C_GREY0="\033[48;5;16m"

# Устанавливаем цвет
echo -en "${F_BOLD}${F_INVERT}${C_WHITE}${C_GREY0}"

# Выводим содержимое файла
cat ~/Documents/Web/AS-http-server.txt
 echo "${RESET}"
echo -e "${F_BOLD}${F_INVERT}${C_WHITE}${C_GREY0}                                              ${NO_FORMAT}"
echo -e "${F_BOLD}${F_INVERT}${C_WHITE}${C_GREY0}                    http-server               ${NO_FORMAT}"
# Сбрасываем цвет
echo -e "${NO_FORMAT}"
    echo "${RESET}"
    echo "Available on:"
    echo "${GREEN}"
    for IP in "${AVAILABLE_ADDRESSES[@]}"; do
        echo "$IP"
    done
    echo "${RESET}Actions:"
    echo "${GREEN}"
    for i in "${!AVAILABLE_ADDRESSES[@]}"; do 
        echo "$((i+1)). Open ${AVAILABLE_ADDRESSES[$i]} in browser"
    done
    echo "$((${#AVAILABLE_ADDRESSES[@]}+1)). View logs"
    echo "$((${#AVAILABLE_ADDRESSES[@]}+2)). View live logs"
    echo "$((${#AVAILABLE_ADDRESSES[@]}+3)). Stop http-server"
    echo "$((${#AVAILABLE_ADDRESSES[@]}+4)). Stop http-server and close console"
    echo "$((${#AVAILABLE_ADDRESSES[@]}+5)). Settings"
    echo "${RESET}Enter your choice:"
}

# Ожидание выбора пользователя
while true; do
    print_menu
    read CHOICE

    if [[ $CHOICE -ge 1 && $CHOICE -le ${#AVAILABLE_ADDRESSES[@]} ]]; then
        open "${AVAILABLE_ADDRESSES[$CHOICE-1]}"
        read -p "Press enter to continue..."
    elif [[ $CHOICE -eq $((${#AVAILABLE_ADDRESSES[@]}+1)) ]]; then
        cat /tmp/http_server_logs
        read -p "Press enter to continue..."
    elif [[ $CHOICE -eq $((${#AVAILABLE_ADDRESSES[@]}+3)) ]]; then
        kill $SERVER_PID
        clear
        echo "Server stopped. Restart the script to run it again."
        exit 0
    elif [[ $CHOICE -eq $((${#AVAILABLE_ADDRESSES[@]}+2)) ]]; then
        view_live_logs
        read -p "Press enter to return to menu..."
    elif [[ $CHOICE -eq $((${#AVAILABLE_ADDRESSES[@]}+4)) ]]; then
        kill $SERVER_PID
        exit 0
    elif [[ $CHOICE -eq $((${#AVAILABLE_ADDRESSES[@]}+5)) ]]; then
        settings_menu
    else
        echo "Invalid choice!"
        read -p "Press enter to continue..."
    fi
    
done
