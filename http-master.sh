#!/usr/bin/env bash
# http-master — start an HTTP or HTTPS server for any folder from a small terminal menu.
# macOS and Linux (bash 3.2+, runs fine from zsh). Windows: http-master.bat.
# Server: Node.js http-server. Missing dependencies are installed on request,
# HTTPS certificates are generated locally with openssl.

set -u

VERSION="10.0.0"
REPO="adm1nsys/http-master"
SERVERMASTER_URL="https://adm1nsys.github.io/ServerMaster/"
HTTP_SERVER_PKG="http-server@14"

CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/http-master"
CONFIG_FILE="$CONFIG_DIR/config"
CERT_DIR="$CONFIG_DIR/certs"
LOG_FILE="$CONFIG_DIR/server.log"

# settings (saved between runs)
ROOT="$PWD"
PORT=8080
ACCESS="local"   # local = 127.0.0.1 only, network = reachable from the LAN
PROTO="http"     # http | https

ASSUME_YES=0
SERVER_PID=""

# ---------- output ----------

if [ -t 1 ] && command -v tput >/dev/null 2>&1 && [ "$(tput colors 2>/dev/null || echo 0)" -ge 8 ]; then
  BOLD=$(tput bold); DIM=$(tput dim); RED=$(tput setaf 1); GREEN=$(tput setaf 2)
  YELLOW=$(tput setaf 3); CYAN=$(tput setaf 6); RESET=$(tput sgr0)
else
  BOLD=""; DIM=""; RED=""; GREEN=""; YELLOW=""; CYAN=""; RESET=""
fi

info()  { printf '%s\n' "${CYAN}›${RESET} $*"; }
ok()    { printf '%s\n' "${GREEN}✓${RESET} $*"; }
warn()  { printf '%s\n' "${YELLOW}!${RESET} $*"; }
fail()  { printf '%s\n' "${RED}✗${RESET} $*" >&2; }
pause() { [ -t 0 ] && read -r -p "${DIM}Press Enter to continue…${RESET}" _; }

have() { command -v "$1" >/dev/null 2>&1; }
cls() { clear 2>/dev/null || printf '\033c'; }

confirm() { # confirm "Question" -> 0 for yes
  [ "$ASSUME_YES" -eq 1 ] && return 0
  [ -t 0 ] || return 1
  local answer
  read -r -p "$1 [y/N] " answer
  case "$answer" in y|Y|yes|YES|j|J|ja) return 0 ;; *) return 1 ;; esac
}

# ---------- config ----------

load_config() {
  [ -f "$CONFIG_FILE" ] || return 0
  local key value
  while IFS='=' read -r key value; do
    case "$key" in
      ROOT)   [ -d "$value" ] && ROOT="$value" ;;
      PORT)   [[ "$value" =~ ^[0-9]+$ ]] && PORT="$value" ;;
      ACCESS) [ "$value" = network ] && ACCESS=network || ACCESS=local ;;
      PROTO)  [ "$value" = https ] && PROTO=https || PROTO=http ;;
    esac
  done < "$CONFIG_FILE"
}

save_config() {
  mkdir -p "$CONFIG_DIR"
  printf 'ROOT=%s\nPORT=%s\nACCESS=%s\nPROTO=%s\n' "$ROOT" "$PORT" "$ACCESS" "$PROTO" > "$CONFIG_FILE"
}

# ---------- system ----------

os() { case "$(uname -s)" in Darwin) echo mac ;; Linux) echo linux ;; *) echo other ;; esac; }

lan_ip() {
  local ip=""
  if [ "$(os)" = mac ]; then
    ip=$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null || true)
  else
    ip=$(hostname -I 2>/dev/null | awk '{print $1}')
    [ -z "$ip" ] && have ip && ip=$(ip route get 1.1.1.1 2>/dev/null | awk '{for(i=1;i<NF;i++) if($i=="src") print $(i+1)}')
  fi
  printf '%s' "$ip"
}

port_in_use() { (exec 3<>"/dev/tcp/127.0.0.1/$1") 2>/dev/null; }

free_port_from() {
  local p="$1"
  while port_in_use "$p"; do p=$((p + 1)); done
  printf '%s' "$p"
}

open_url() {
  if [ "$(os)" = mac ]; then open "$1"
  elif have xdg-open; then xdg-open "$1" >/dev/null 2>&1 &
  else info "Open in your browser: $1"
  fi
}

# Runs a package manager command, with sudo when needed
as_root() { if [ "$(id -u)" -eq 0 ]; then "$@"; elif have sudo; then sudo "$@"; else return 1; fi; }

# install_package <name-for-humans> <brew> <apt> <dnf> <pacman> <apk>
# package lists ("nodejs npm") are split into words on purpose
# shellcheck disable=SC2086
install_package() {
  local what="$1"
  if [ "$(os)" = mac ]; then
    if ! have brew; then fail "Homebrew is needed to install $what: https://brew.sh"; return 1; fi
    brew install "$2"
  elif have apt-get; then as_root apt-get update && as_root apt-get install -y $3
  elif have dnf;     then as_root dnf install -y $4
  elif have pacman;  then as_root pacman -S --noconfirm $5
  elif have apk;     then as_root apk add $6
  else fail "No supported package manager found — please install $what manually."; return 1
  fi
}

# ---------- dependencies ----------

ensure_node() {
  have node && have npx && return 0
  warn "Node.js is not installed — http-master runs the server with Node's http-server."
  confirm "Install Node.js now?" || { info "Get it from https://nodejs.org"; return 1; }
  install_package "Node.js" node "nodejs npm" "nodejs npm" "nodejs npm" "nodejs npm" && have npx
}

ensure_openssl() {
  have openssl && return 0
  warn "openssl is needed to generate a certificate for HTTPS."
  confirm "Install openssl now?" || return 1
  install_package "openssl" openssl openssl openssl openssl openssl && have openssl
}

# http-server: a global install if present, otherwise npx fetches and caches it
http_server_cmd() {
  if have http-server; then echo "http-server"; else echo "npx --yes $HTTP_SERVER_PKG"; fi
}

install_dependencies() {
  ensure_node || return 1
  if have http-server; then
    ok "http-server is installed ($(http-server --version 2>/dev/null))"
  elif confirm "Install http-server globally with npm (otherwise npx downloads it on first start)?"; then
    npm install -g "$HTTP_SERVER_PKG" && ok "http-server installed"
  fi
  ensure_openssl && ok "openssl is available"
}

# ---------- certificates ----------

cert_files_exist() { [ -s "$CERT_DIR/localhost.crt" ] && [ -s "$CERT_DIR/localhost.key" ]; }

generate_cert() {
  ensure_openssl || return 1
  mkdir -p "$CERT_DIR"
  local ip cnf san
  ip=$(lan_ip)
  san="DNS:localhost,IP:127.0.0.1"
  [ -n "$ip" ] && san="$san,IP:$ip"
  cnf=$(mktemp)
  # a config file instead of -addext keeps it working with macOS LibreSSL as well
  cat > "$cnf" <<EOF
[req]
distinguished_name = dn
x509_extensions = ext
prompt = no
[dn]
CN = localhost
O = http-master
[ext]
subjectAltName = $san
basicConstraints = critical,CA:FALSE
keyUsage = critical,digitalSignature,keyEncipherment
extendedKeyUsage = serverAuth
EOF
  if openssl req -x509 -newkey rsa:2048 -nodes -sha256 -days 825 \
       -keyout "$CERT_DIR/localhost.key" -out "$CERT_DIR/localhost.crt" -config "$cnf" >/dev/null 2>&1; then
    chmod 600 "$CERT_DIR/localhost.key"
    ok "Certificate created for $san"
    info "Stored in $CERT_DIR — browsers will warn once, because it is self-signed."
  else
    fail "openssl could not create the certificate."
    rm -f "$cnf"; return 1
  fi
  rm -f "$cnf"
}

# ---------- updates ----------

version_gt() { # version_gt A B -> true when A > B
  local IFS=. i a b
  read -r -a a <<< "$1"; read -r -a b <<< "$2"
  for i in 0 1 2; do
    [ "${a[i]:-0}" -gt "${b[i]:-0}" ] && return 0
    [ "${a[i]:-0}" -lt "${b[i]:-0}" ] && return 1
  done
  return 1
}

latest_version() {
  curl -fsSL --max-time 8 "https://api.github.com/repos/$REPO/releases/latest" 2>/dev/null \
    | sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p' | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | tail -1
}

check_update() {
  have curl || { fail "curl is needed to check for updates."; return 1; }
  local latest self tmp
  latest=$(latest_version)
  if [ -z "$latest" ]; then warn "Could not reach GitHub to check for updates."; return 1; fi
  if ! version_gt "$latest" "$VERSION"; then ok "You have the latest version ($VERSION)."; return 0; fi
  info "Version $latest is available (you have $VERSION)."
  confirm "Update now?" || return 0
  self=$(cd "$(dirname "$0")" && pwd)/$(basename "$0")
  tmp=$(mktemp)
  if curl -fsSL "https://raw.githubusercontent.com/$REPO/v$latest/http-master.sh" -o "$tmp" && bash -n "$tmp"; then
    chmod +x "$tmp" && mv "$tmp" "$self" && ok "Updated to $latest — start http-master again."
    exit 0
  fi
  rm -f "$tmp"; fail "Update failed; your current version is unchanged."
}

# ---------- server ----------

bind_address() { [ "$ACCESS" = network ] && echo 0.0.0.0 || echo 127.0.0.1; }

server_args() { # prints the http-server arguments, one per line
  printf '%s\n' "$ROOT" -p "$PORT" -a "$(bind_address)" -c-1
  if [ "$PROTO" = https ]; then
    printf '%s\n' -S -C "$CERT_DIR/localhost.crt" -K "$CERT_DIR/localhost.key"
  fi
}

prepare_start() {
  [ -d "$ROOT" ] || { fail "Folder not found: $ROOT"; return 1; }
  ensure_node || return 1
  if [ "$PROTO" = https ] && ! cert_files_exist; then
    info "No certificate yet — generating one for HTTPS."
    generate_cert || return 1
  fi
  if port_in_use "$PORT"; then
    local next; next=$(free_port_from "$PORT")
    warn "Port $PORT is busy — using $next."
    PORT="$next"
  fi
}

urls() {
  local ip
  printf '  %s\n' "${BOLD}$PROTO://localhost:$PORT${RESET}"
  if [ "$ACCESS" = network ]; then
    ip=$(lan_ip)
    [ -n "$ip" ] && printf '  %s  %s\n' "${BOLD}$PROTO://$ip:$PORT${RESET}" "${DIM}(other devices in your network)${RESET}"
  fi
}

wait_until_up() {
  local i
  for i in $(seq 1 60); do
    port_in_use "$PORT" && return 0
    kill -0 "$SERVER_PID" 2>/dev/null || return 1
    sleep 0.5
  done
  return 1
}

stop_server() {
  [ -n "$SERVER_PID" ] || return 0
  kill "$SERVER_PID" 2>/dev/null
  # npx starts http-server as a child process; take that down too
  pkill -P "$SERVER_PID" 2>/dev/null
  wait "$SERVER_PID" 2>/dev/null
  SERVER_PID=""
}

start_server() {
  prepare_start || { pause; return 1; }
  save_config
  mkdir -p "$CONFIG_DIR"
  local cmd args=() line
  cmd=$(http_server_cmd)
  while IFS= read -r line; do args+=("$line"); done < <(server_args)
  info "Starting $PROTO server for $ROOT …"
  # shellcheck disable=SC2086  # $cmd is "http-server" or "npx --yes http-server@14"
  $cmd "${args[@]}" > "$LOG_FILE" 2>&1 &
  SERVER_PID=$!
  if ! wait_until_up; then
    fail "The server did not start. Last log lines:"
    tail -n 15 "$LOG_FILE" >&2
    stop_server; pause; return 1
  fi
  running_menu
}

running_menu() {
  local choice
  while true; do
    cls
    header
    ok "Serving ${BOLD}$ROOT${RESET}"
    urls
    echo
    echo "  [o] Open in browser    [l] Show log    [s] Stop and back    [q] Stop and quit"
    read -r -n 1 -s choice || { stop_server; exit 0; }
    case "$choice" in
      o|O) open_url "$PROTO://localhost:$PORT" ;;
      l|L) cls; info "Log (last 40 lines) — $LOG_FILE"; tail -n 40 "$LOG_FILE"; pause ;;
      s|S) stop_server; return 0 ;;
      q|Q) stop_server; exit 0 ;;
    esac
  done
}

# ---------- menu ----------

choose_folder() {
  local picked="" choice
  echo "  [1] Type a path    [2] Use the current folder ($PWD)"
  [ "$(os)" = mac ] && echo "  [3] Pick in Finder"
  [ "$(os)" = linux ] && have zenity && echo "  [3] Pick in a dialog"
  read -r -n 1 -s choice; echo
  case "$choice" in
    1) read -r -e -p "Folder: " picked; picked="${picked/#\~/$HOME}" ;;
    2) picked="$PWD" ;;
    3) if [ "$(os)" = mac ]; then
         picked=$(osascript -e 'POSIX path of (choose folder with prompt "Folder to serve")' 2>/dev/null)
       else
         picked=$(zenity --file-selection --directory --title="Folder to serve" 2>/dev/null)
       fi ;;
  esac
  [ -z "$picked" ] && return 0
  if [ -d "$picked" ]; then ROOT=$(cd "$picked" && pwd); save_config; ok "Folder set to $ROOT"
  else fail "Not a folder: $picked"; pause
  fi
}

set_port() {
  local p
  read -r -p "Port (1024–65535, now $PORT): " p
  if [[ "$p" =~ ^[0-9]+$ ]] && [ "$p" -ge 1024 ] && [ "$p" -le 65535 ]; then PORT="$p"; save_config
  elif [ -n "$p" ]; then fail "Not a valid port."; pause
  fi
}

header() {
  printf '%s\n' "${BOLD}http-master${RESET} ${DIM}$VERSION · static HTTP/HTTPS server for any folder${RESET}"
  printf '%s\n\n' "${DIM}Need PHP, Node.js apps or a database? → ServerMaster: $SERVERMASTER_URL${RESET}"
}

main_menu() {
  local choice
  while true; do
    cls
    header
    printf '  %-16s %s\n' "Folder" "$ROOT"
    printf '  %-16s %s\n' "Port" "$PORT"
    printf '  %-16s %s\n' "Access" "$([ "$ACCESS" = network ] && echo "local network" || echo "this computer only")"
    printf '  %-16s %s\n\n' "HTTPS certificate" "$(cert_files_exist && echo "ready" || echo "not created yet")"
    echo "  [1] Start HTTP           [2] Start HTTPS"
    echo "  [3] Choose folder        [4] Change port        [5] Toggle access"
    echo "  [6] Generate certificate [7] Install dependencies"
    echo "  [8] Check for updates    [9] Open ServerMaster  [0] Quit"
    read -r -n 1 -s choice || exit 0
    echo
    case "$choice" in
      1) PROTO=http;  start_server ;;
      2) PROTO=https; start_server ;;
      3) choose_folder ;;
      4) set_port ;;
      5) if [ "$ACCESS" = local ]; then ACCESS=network; else ACCESS=local; fi; save_config ;;
      6) generate_cert; pause ;;
      7) install_dependencies; pause ;;
      8) check_update; pause ;;
      9) open_url "$SERVERMASTER_URL" ;;
      0|q|Q) exit 0 ;;
    esac
  done
}

usage() {
  cat <<EOF
http-master $VERSION — static HTTP/HTTPS server for any folder

Usage:
  http-master                       open the menu
  http-master --serve [DIR]         start right away (foreground, Ctrl+C to stop)
      --port N                      port (default 8080 or the last one used)
      --https                       serve over HTTPS (a certificate is generated if needed)
      --network                     listen on all interfaces, not just this computer
  http-master --gen-cert            create a new self-signed certificate
  http-master --install-deps        install Node.js, http-server and openssl if missing
  http-master --check-update        look for a newer release
  http-master --version | --help
  Add --yes to answer prompts with yes.

More (PHP, Node.js apps, databases): $SERVERMASTER_URL
EOF
}

serve_foreground() {
  prepare_start || exit 1
  local cmd args=() line
  cmd=$(http_server_cmd)
  while IFS= read -r line; do args+=("$line"); done < <(server_args)
  info "Serving $ROOT"; urls
  # shellcheck disable=SC2086  # $cmd is "http-server" or "npx --yes http-server@14"
  exec $cmd "${args[@]}"
}

trap 'stop_server' EXIT
trap 'stop_server; exit 130' INT TERM

load_config

ACTION="menu"
while [ $# -gt 0 ]; do
  case "$1" in
    --serve) ACTION="serve"; if [ $# -gt 1 ] && [ "${2#-}" = "$2" ]; then ROOT=$(cd "$2" 2>/dev/null && pwd || echo "$2"); shift; fi ;;
    --port) [[ "${2:-}" =~ ^[0-9]+$ ]] || { fail "--port needs a number"; exit 2; }; PORT="$2"; shift ;;
    --https) PROTO=https ;;
    --network) ACCESS=network ;;
    --yes|-y) ASSUME_YES=1 ;;
    --gen-cert) ACTION="gen-cert" ;;
    --install-deps) ACTION="install" ;;
    --check-update) ACTION="update" ;;
    --version|-v) echo "http-master $VERSION"; exit 0 ;;
    --help|-h) usage; exit 0 ;;
    *) fail "Unknown option: $1"; usage; exit 2 ;;
  esac
  shift
done

case "$ACTION" in
  serve)    serve_foreground ;;
  gen-cert) generate_cert ;;
  install)  install_dependencies ;;
  update)   check_update ;;
  menu)     [ -t 0 ] || { usage; exit 2; }; main_menu ;;
esac
