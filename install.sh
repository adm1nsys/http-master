#!/usr/bin/env bash
# Installs http-master as a command for the current user (macOS and Linux).
#   curl -fsSL https://raw.githubusercontent.com/adm1nsys/http-master/main/install.sh | bash
set -eu

REPO="adm1nsys/http-master"
BIN_DIR="${HTTP_MASTER_BIN:-$HOME/.local/bin}"
TARGET="$BIN_DIR/http-master"

mkdir -p "$BIN_DIR"
tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT

echo "Downloading http-master …"
curl -fsSL "https://raw.githubusercontent.com/$REPO/main/http-master.sh" -o "$tmp"
bash -n "$tmp"
install -m 755 "$tmp" "$TARGET"
echo "Installed: $TARGET ($("$TARGET" --version))"

case ":$PATH:" in
  *":$BIN_DIR:"*) echo "Run: http-master" ;;
  *)
    shell_rc="$HOME/.bashrc"
    [ "$(basename "${SHELL:-}")" = zsh ] && shell_rc="$HOME/.zshrc"
    echo "Add $BIN_DIR to your PATH, for example:"
    echo "  echo 'export PATH=\"$BIN_DIR:\$PATH\"' >> $shell_rc && source $shell_rc"
    ;;
esac
