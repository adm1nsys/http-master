#!/bin/bash

CONFIG_FILE="$HOME/.as_http_server_config"

clearScreen() {
    printf '\033c'
    clear && printf '\e[3J'
}

update_config_value() {
    local key=$1
    local value=$2
    grep -q "$key" "$CONFIG_FILE" && sed -i "s/^$key=.*/$key=$value/" "$CONFIG_FILE" || echo "$key=$value" >> "$CONFIG_FILE"
}

initializeConfig() {
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "Creating File Configuration"
        echo "AUTO_UPDATE=true" > "$CONFIG_FILE"
        source "$CONFIG_FILE"
    else
        source "$CONFIG_FILE"
    fi
}

initializeConfig

clearScreen

update_ip() {
    read -p "Enter new IP address (default is 127.0.0.1): " new_ip
    if [[ "$new_ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        update_config_value "IP" "$new_ip"
        echo "IP address updated to $new_ip!"
    else
        echo "Invalid IP address."
    fi
    read -p "Press enter to continue..."
}

update_port() {
    read -p "Enter new port (default is 8080): " new_port
    if [[ "$new_port" =~ ^[0-9]+$ ]]; then
        update_config_value "PORT" "$new_port"
        echo "Port updated to $new_port!"
    else
        echo "Invalid port number."
    fi
    read -p "Press enter to continue..."
}

YELLOW=$(tput setaf 3)
GREEN=$(tput setaf 2)
RESET=$(tput sgr0)
CURRENT_VERSION="9.1.7"
CURRENT_EDITION="Windows"
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
    echo "Update is available!"  
else
    echo "You have the latest version!"
fi

if ! command -v http-server &> /dev/null; then
    echo "http-server is not installed or not in the PATH."
    exit 1
fi

cd ~/Documents/Web/admin\ inc/as/ || { echo "Directory not found"; exit 1; }
http-server > /tmp/http_server_logs 2>&1 &
SERVER_PID=$!
sleep 2  
AVAILABLE_ADDRESSES=($(grep -oE "http://[0-9.]+:[0-9]+" /tmp/http_server_logs))
trap "kill $SERVER_PID 2> /dev/null" EXIT

view_live_logs() {
gnome-terminal -- tail -f /tmp/http_server_logs

}

update_config() {
    local new_value="$1"
    sed -i "s/^AUTO_UPDATE=.*/AUTO_UPDATE=$new_value/" "$CONFIG_FILE"

}

# The settings_menu function remains unchanged.


settings_menu() {
    clearScreen

    center_text() {
        local text="$1"
        local total_width=$(tput cols)
        local text_width=${#text}
        echo -en "${GREEN}"
        echo -n "${text}"
        printf "%$((total_width - text_width - 16))s${NO_FORMAT}\n"
    }

    center_text_with_color() {
        local text="$1"
        local color="$2"
        local total_width=$(tput cols)
        local text_width=${#text}
        echo -en "${color}${C_BLACK}"
        echo -n "${text}"
        printf "%$((total_width - text_width - 16))s${NO_FORMAT}\n"
    }

    while true; do
        clearScreen
        while IFS= read -r line; do
            center_text "$line"
        done < "$HOME/AS-http-server.txt"
        center_text "Version ${CURRENT_VERSION} (${CURRENT_EDITION} Edition)"
        center_text "http-server"
        center_text "Settings:"
        center_text "1. Check for Updates"
        
        if [ "$AUTO_UPDATE" == "true" ]; then
            echo -en "${C_ORANGE2}${C_BLACK}"
            echo -n "2. Auto Update: "
            center_text_with_color "True" "${GREEN}"
        else
            echo -en "${C_ORANGE2}${C_BLACK}"
            echo -n "2. Auto Update: "
            center_text_with_color "False" "${C_RED1}"
        fi

#         center_text "3. Set Font Size (Standard: 15)"
        center_text "3. Return to main menu"
        center_text "Enter your choice:"

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
update_config "false"
else
AUTO_UPDATE=true
update_config "true"
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
print_menu() {
    printf '\033c'
    clear && printf '\e[3J'
    trap 'print_menu' SIGWINCH

    C_GOLD1="\033[48;5;220m"
    echo -en "${F_BOLD}${C_GREY3}${C_GOLD1}"

    center_text() {
        local text="$1"
        local total_width=$(tput cols)
        local text_width=${#text}
        local padding=$(( (total_width - text_width) / 2 ))
        printf "${F_BOLD}${C_GREY3}${C_ORANGE1}%${padding}s"
        echo -n "${text}"
        printf "%$((total_width - text_width - padding))s${NO_FORMAT}\n"
    }

    center_text ""
    while IFS= read -r line; do
        center_text "$line"
    done < "$HOME/AS-http-server.txt"

    center_text "Version ${CURRENT_VERSION} (${CURRENT_EDITION} Edition)"
    center_text "http-server"
    center_text ""

    NO_FORMAT=$(tput sgr0)
    F_BOLD=$(tput bold)
    C_WHITE=$(tput setaf 15)
    C_BLACK=$(tput setab 0)

    center_text1() {
        local text="$1"
        local total_width=$(tput cols)
        local text_width=${#text}
        C_ORANGE2="\033[38;5;214m"
        echo -en "${F_BOLD}${C_WHITE}${C_BLACK}"
        echo -n "${text}"
        printf "%$((total_width - text_width))s${NO_FORMAT}\n"
    }

    center_text2() {
        local text="$1"
        local total_width=$(tput cols)
        local text_width=${#text}
        C_SEAGREEN2="\033[38;5;83m"
        echo -en "${C_ORANGE2}${C_BLACK}"
        echo -n "${text}"
        printf "%$((total_width - text_width))s${NO_FORMAT}\n"
    }

    center_text1 "Available on:"

    C_YELLOW1="\033[38;5;226m"
    C_GREEN3="\033[38;5;34m"

    center_text3() {
        local text="$1"
        local total_width=$(tput cols)
        local text_width=${#text}
        C_SEAGREEN2="\033[38;5;83m"
        echo -en "${GREEN}${C_BLACK}"
        echo -n "${text}"
        printf "%$((total_width - text_width))s${NO_FORMAT}\n"
    }

    center_text3_3() {
        local text="$1"
        local total_width=$(tput cols)
        local text_width=${#text}
        C_SEAGREEN2="\033[38;5;83m"
        echo -en "${GREEN}${C_BLACK}"
        echo -n "${text}"
        printf "%$((total_width - text_width - 8))s${NO_FORMAT}\n"
    }

    center_text4() {
        local text="$1"
        local total_width=$(tput cols)
        local text_width=${#text}
        C_SEAGREEN2="\033[38;5;83m"
        echo -en "${C_ORANGE2}${C_BLACK}"
        echo -n "${text}"
        printf "%$((total_width - text_width))s${NO_FORMAT}"
    }

    for IP in "${AVAILABLE_ADDRESSES[@]}"; do
        center_text3 "$IP"
    done

    center_text1 ""
    center_text1 "Actions:"

    for i in "${!AVAILABLE_ADDRESSES[@]}"; do
        echo -en "${C_ORANGE2}${C_BLACK}"
        echo -n "$((i+1)). Open "
        center_text3_3 "${AVAILABLE_ADDRESSES[$i]}"
    done

    center_text2 "$((${#AVAILABLE_ADDRESSES[@]}+1)). View logs"
    center_text2 "$((${#AVAILABLE_ADDRESSES[@]}+2)). View live logs"
    center_text2 "$((${#AVAILABLE_ADDRESSES[@]}+3)). Download logs"
    center_text2 "$((${#AVAILABLE_ADDRESSES[@]}+4)). Stop http-server"
    center_text2 "$((${#AVAILABLE_ADDRESSES[@]}+5)). Stop http-server and close console"
    center_text2 "$((${#AVAILABLE_ADDRESSES[@]}+6)). Settings"
    center_text1 "Enter your choice:"
    echo -en "${GREEN}${C_BLACK}"
}

save_logs() {
    echo "Select a location to save the logs:"
    echo "1. Documents"
    echo "2. Downloads"
    echo "3. Desktop"
    echo "4. Custom path"
    echo "5. Cancel"

    read -p "Enter your choice: " choice
    local dest_path=""

    case $choice in
        1) dest_path="$HOME/Documents" ;;
        2) dest_path="$HOME/Downloads" ;;
        3) dest_path="$HOME/Desktop" ;;
        4) read -p "Enter the custom path: " custom_path
           dest_path="$custom_path" ;;
        5) echo "Cancelled."
           return ;;
        *) echo "Invalid choice. Cancelled."
           return ;;
    esac

    cp /tmp/http_server_logs "$dest_path/http_server_logs.txt"
    echo "Logs saved to $dest_path/http_server_logs.txt"
}

while true; do
    print_menu
    read CHOICE

    if [[ $CHOICE -ge 1 && $CHOICE -le ${#AVAILABLE_ADDRESSES[@]} ]]; then
        open "${AVAILABLE_ADDRESSES[$CHOICE-1]}"
        read -p "Press enter to continue..."
    elif [[ $CHOICE -eq $((${#AVAILABLE_ADDRESSES[@]}+1)) ]]; then
        cat /tmp/http_server_logs
        read -p "Press enter to continue..."
    elif [[ $CHOICE -eq $((${#AVAILABLE_ADDRESSES[@]}+2)) ]]; then
        view_live_logs
        read -p "Press enter to return to menu..."
    elif [ "$CHOICE" -eq "$((${#AVAILABLE_ADDRESSES[@]}+3))" ]; then
        save_logs
    elif [[ $CHOICE -eq $((${#AVAILABLE_ADDRESSES[@]}+4)) ]]; then
        kill $SERVER_PID
        clear
        echo "Server stopped. Restart the script to run it again."
        exit 0
    elif [[ $CHOICE -eq $((${#AVAILABLE_ADDRESSES[@]}+5)) ]]; then
        kill $SERVER_PID
        exit 0
    elif [[ $CHOICE -eq $((${#AVAILABLE_ADDRESSES[@]}+6)) ]]; then
        settings_menu
    else
        echo "Invalid choice!"
        read -p "Press enter to continue..."
    fi
done
