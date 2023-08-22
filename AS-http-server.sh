#!/bin/bash
CONFIG_FILE="$HOME/.as_http_server_config"
    printf '\033c'
    clear && printf '\e[3J'
# if [ ! -f "$CONFIG_FILE" ]; then
#     echo "AUTO_UPDATE=false" > "$CONFIG_FILE"
# fi

CONFIG_FILE="$HOME/.as_http_server_config"
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
echo "Creating File Configuration"
    echo "AUTO_UPDATE=true" > "$CONFIG_FILE"
    source "$CONFIG_FILE"
    
fi




YELLOW=$(tput setaf 3)
GREEN=$(tput setaf 2)
RESET=$(tput sgr0)
NO_FORMAT="\033[0m"
F_BOLD="\033[1m"
F_INVERT="\033[7m"
C_WHITE="\033[38;5;15m"
C_GREY0="\033[48;5;16m"
CURRENT_VERSION="2.3.5"  # пример текущей версии
CURRENT_EDITION="Mac OS"  # пример текущей версии
# AUTO_UPDATE=false 
NO_FORMAT="\033[0m"
F_BOLD="\033[1m"
F_INVERT="\033[7m"
C_WHITE="\033[38;5;15m"
C_GREY0="\033[48;5;16m"
C_GREY100="\033[38;5;231m"
C_ORANGE1="\033[48;5;214m"
C_ORANGE2=$(tput setab 214)
C_GREY3="\033[38;5;232m"


GITHUB_REPO_URL="https://github.com/administrati0n/http-master"
echo "${GREEN}"
echo "Server is starting..."


echo "Checking for updates..."

if [ -z "$CURRENT_VERSION" ]; then
    echo "Error: CURRENT_VERSION is not set."
    exit 1
fi

LATEST_VERSION_RAW=$(curl -s "https://raw.githubusercontent.com/administrati0n/http-master/master/ASV.txt")
if [ $? -ne 0 ]; then
    echo "Failed to fetch the latest version. Please check your internet connection."
    exit 1
fi

LATEST_VERSION=$(echo "$LATEST_VERSION_RAW" | tr -d '[:space:]')
CURRENT_VERSION_CLEAN=$(echo "$CURRENT_VERSION" | tr -d '[:space:]')

if [ "$LATEST_VERSION" != "$CURRENT_VERSION_CLEAN" ]; then
    echo "Update is available!"  # Просто добавьте какое-либо действие здесь
else
    echo "You have the latest version!"
fi


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

update_config() {
    local new_value="$1"
    sed -i "" "s/^AUTO_UPDATE=.*/AUTO_UPDATE=$new_value/" "$CONFIG_FILE"
}


settings_menu() {
    printf '\033c'
    clear && printf '\e[3J'


# Обработка сигнала SIGWINCH (изменение размера окна)

    printf '\033c'
    clear && printf '\e[3J'
    while true; do
        printf '\033c'
        
        center_text ""
# Центрирование содержимого файла
while IFS= read -r line; do
    center_text "$line"
done < "$HOME/AS-http-server.txt"
# Вывод текста, центрированного по ширине терминала
center_text "Version ${CURRENT_VERSION} (${CURRENT_EDITION} Edition)"
center_text "http-server"
center_text ""
        center_text1 "Settings:"
        center_text2 "1. Check for Updates"
        if [ "$AUTO_UPDATE" == "true" ]; then
     center_text2 "2. Auto Update: ${GREEN}True"
else
  center_text2 "2. Auto Update: ${YELLOW}False"
fi
        center_text2 "3. Return to main menu"
        center_text1 "Enter your choice:"
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
                        
                        curl -s -o "$TMP_FILE" "https://raw.githubusercontent.com/administrati0n/http-master/main/AS-http-server.sh"
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
#         echo "Setting AUTO_UPDATE to false"
        update_config "false"
    else
        AUTO_UPDATE=true
#         echo "Setting AUTO_UPDATE to true"
        update_config "true"
    fi
#     read -p "Press enter to continue..."
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
    clear && printf '\e[3J'


# Обработка сигнала SIGWINCH (изменение размера окна)
trap 'print_menu' SIGWINCH
# Устанавливаем цвет
C_GOLD1="\033[48;5;220m"
echo -en "${F_BOLD}${C_GREY3}${C_GOLD1}"

# Выводим содержимое файла
# cat ~/Documents/Web/AS-http-server.txt
# cat "$HOME/AS-http-server.txt"
#  echo "${RESET}"
# Функция для выравнивания текста по центру в зависимости от ширины терминала
center_text() {
    local text="$1"
    local total_width=$(tput cols)
    local text_width=${#text}
    local padding=$(( (total_width - text_width) / 2 ))
    
    printf "${F_BOLD}${C_GREY3}${C_ORANGE1}%${padding}s" # Добавляем пробелы слева
    echo -n "${text}"
    printf "%$((total_width - text_width - padding))s${NO_FORMAT}\n" # Добавляем пробелы справа
}



center_text ""
# Центрирование содержимого файла
while IFS= read -r line; do
    center_text "$line"
done < "$HOME/AS-http-server.txt"
# Вывод текста, центрированного по ширине терминала
center_text "Version ${CURRENT_VERSION} (${CURRENT_EDITION} Edition)"
center_text "http-server"
center_text ""

# Сбрасываем цвет
# sleep 0.5
# echo -e "${NO_FORMAT}"
#     echo "${RESET}"
NO_FORMAT="\033[0m"
F_BOLD="\033[1m"
C_WHITE="\033[38;5;15m"
C_BLACK="\033[48;5;0m"

center_text1() {
    local text="$1"
    local total_width=$(tput cols)
    local text_width=${#text}
    C_ORANGE2="\033[38;5;214m"
    # Устанавливаем стили: белый текст на черном фоне
    echo -en "${F_BOLD}${C_WHITE}${C_BLACK}"
    # Выводим текст
    echo -n "${text}"
    # Добавляем пробелы справа до конца строки
    printf "%$((total_width - text_width))s${NO_FORMAT}\n"
}

center_text2() {
    local text="$1"
    local total_width=$(tput cols)
    local text_width=${#text}
    C_SEAGREEN2="\033[38;5;83m"
 echo -en "${C_ORANGE2}${C_BLACK}"
    # Устанавливаем стили: белый текст на черном фоне
#     echo -en "${C_WHITE}${C_BLACK}${F_BOLD}"
    # Выводим текст
    echo -n "${text}"
    # Добавляем пробелы справа до конца строки
    printf "%$((total_width - text_width))s${NO_FORMAT}\n"
}

# Использование функции:
center_text1 "Available on:"

#     center_text1 "Available on:"
#     echo "${GREEN}"
C_YELLOW1="\033[38;5;226m"
C_GREEN3="\033[38;5;34m"
    for IP in "${AVAILABLE_ADDRESSES[@]}"; do
    
        center_text2 "${GREEN}$IP"
    done
    center_text1 ""
    center_text1 "Actions:"
#     echo "${GREEN}"
    for i in "${!AVAILABLE_ADDRESSES[@]}"; do 
        center_text2 "$((i+1)). Open ${GREEN}${AVAILABLE_ADDRESSES[$i]}"
    done
    center_text2 "$((${#AVAILABLE_ADDRESSES[@]}+1)). View logs"
    center_text2 "$((${#AVAILABLE_ADDRESSES[@]}+2)). View live logs"
    center_text2 "$((${#AVAILABLE_ADDRESSES[@]}+3)). Stop http-server"
    center_text2 "$((${#AVAILABLE_ADDRESSES[@]}+4)). Stop http-server and close console"
    center_text2 "$((${#AVAILABLE_ADDRESSES[@]}+5)). Settings"
    center_text1 "Enter your choice:"
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
