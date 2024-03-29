case "$(uname -a)" in
  Darwin*) OS="Darwin";;
  Linux*)
    OS="Linux"
    grep -q Microsoft /proc/version \
      && OS="WSL"
    ;;
esac

DISTRO="$(lsb_release -id | head -n 1 | awk '{print $3}')"

case "$OS" in
  WSL)
    BROWSER="/c/Program Files (x86)/Google/Chrome/Application/chrome.exe"
    CLIPBOARD="clip.exe"
    ;;
  Darwin)
    # on MacOS `open` uses the default browser
    BROWSER="open"
    CLIPBOARD="pbcopy"
    ;;
esac

use() { source "${0%/*}/../src/$1.sh"; }

clip() {
  [[ -z "$CLIPBOARD" ]] && { echo "no \$CLIPBOARD available"; exit 1; }
  "$CLIPBOARD"
}

open_url() {
  [[ -z "$BROWSER" ]] && { echo "no \$BROWSER available"; exit 1; }
  "$BROWSER" "$1"
}

is_installed() {
  case "$DISTRO" in
    Ubuntu) dpkg-query -W -f='${Status}' "$1" 2>/dev/null | grep -c "ok installed" >/dev/null;;
    *) echo "[BIN] is_installed: $DISTRO is not yet supported" && exit 1;;
  esac
}

ensure() {
  case "$DISTRO" in
    Ubuntu) is_installed "$1" || (echo "[INFO] installing: $1" && sudo apt install -y "$1");;
    *) echo "[BIN] ensure: $DISTRO is not yet supported" && exit 1;;
  esac
}
