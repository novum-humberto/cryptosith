#!/usr/bin/env bash
# ================================================================
# install.sh — Instalador automático de cryptosith
#
# Uso:
#   ./install.sh                  # instalación interactiva
#   ./install.sh --unattended     # sin preguntas
#
# Repo: https://codeberg.org/novum-humberto/cryptosith
# ================================================================

set -euo pipefail

readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly NC='\033[0m'

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly ZSH_FUNCTIONS_DIR="$HOME/.config/zsh/functions"
readonly CRYPTOSITH_CONFIG_DIR="$HOME/.config/cryptosith"
readonly ZSHRC="$HOME/.config/zsh/.zshrc"
readonly COMPDEFS="$HOME/.config/zsh/conf.d/31-compdefs.zsh"

UNATTENDED=false
for arg in "$@"; do
    case "$arg" in
        --unattended) UNATTENDED=true ;;
        -h|--help)
            echo "Uso: $0 [--unattended]"
            exit 0
            ;;
        *) echo "Flag desconocido: $arg"; exit 1 ;;
    esac
done

info()   { echo -e "${CYAN}→ $1${NC}"; }
ok()     { echo -e "${GREEN}✓ $1${NC}"; }
warn()   { echo -e "${YELLOW}⚠ $1${NC}"; }
err()    { echo -e "${RED}✗ $1${NC}" >&2; }
die()    { err "$1"; exit 1; }

confirmar() {
    if $UNATTENDED; then return 0; fi
    local prompt="$1" resp
    read -rp "$prompt (s/N): " resp
    [[ "$resp" =~ ^[sSyY]$ ]]
}

clear
echo -e "${CYAN}"
cat <<'EOF'
╔══════════════════════════════════════════════════════╗
║        🔐 INSTALADOR DE CRYPTOSITH 🔐                ║
║      Cifrado por capas para archivos y directorios   ║
╚══════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    DISTRO="${ID:-unknown}"
else
    DISTRO="unknown"
fi
info "Distribución detectada: ${BOLD}$DISTRO${NC}"
echo ""

if [[ ! -f "$SCRIPT_DIR/cryptosith" ]]; then
    die "No se encuentra 'cryptosith' en $SCRIPT_DIR. Ejecuta el script desde la raíz del repo."
fi

echo -e "${BOLD}── Paso 1: Verificar dependencias ──${NC}"
echo ""

case "$DISTRO" in
    arch|omarchy|manjaro|endeavouros)
        PKG_INSTALL="sudo pacman -S --needed --noconfirm"
        PKGS="age util-linux systemd p7zip tar coreutils"
        ;;
    debian|ubuntu|linuxmint|pop)
        PKG_INSTALL="sudo apt install -y"
        PKGS="age util-linux systemd p7zip-full tar coreutils"
        ;;
    fedora|rhel|centos)
        PKG_INSTALL="sudo dnf install -y"
        PKGS="age util-linux systemd p7zip p7zip-plugins tar coreutils"
        ;;
    opensuse*|suse)
        PKG_INSTALL="sudo zypper install -y"
        PKGS="age util-linux systemd p7zip tar coreutils"
        ;;
    *)
        warn "Distribución no reconocida: $DISTRO. Se asumirá Arch."
        PKG_INSTALL="sudo pacman -S --needed --noconfirm"
        PKGS="age util-linux systemd p7zip tar coreutils"
        ;;
esac

MISSING=()
for cmd in age script gpg 7z tar sha256sum; do
    command -v "$cmd" &>/dev/null || MISSING+=("$cmd")
done

if [[ ${#MISSING[@]} -eq 0 ]]; then
    ok "Todas las dependencias están instaladas."
else
    warn "Faltan: ${MISSING[*]}"
    if confirmar "¿Instalar dependencias con '${PKG_INSTALL%% *}'?"; then
        $PKG_INSTALL $PKGS || die "Fallo al instalar dependencias."
        ok "Dependencias instaladas."
    else
        warn "Continuando sin instalar dependencias."
    fi
fi

echo ""
echo -e "${BOLD}── Paso 2: Copiar archivos ──${NC}"
echo ""

if [[ ! -d "$ZSH_FUNCTIONS_DIR" ]]; then
    warn "No existe $ZSH_FUNCTIONS_DIR"
    warn "¿Está instalado zsh-config?"
    warn "Instálalo primero desde: https://codeberg.org/novum-humberto/zsh-config"
    if ! confirmar "¿Continuar de todos modos?"; then
        die "Cancelado."
    fi
    mkdir -p "$ZSH_FUNCTIONS_DIR"
fi

info "Copiando cryptosith..."
cp "$SCRIPT_DIR/cryptosith" "$ZSH_FUNCTIONS_DIR/cryptosith"
chmod +x "$ZSH_FUNCTIONS_DIR/cryptosith"
ok "Copiado: $ZSH_FUNCTIONS_DIR/cryptosith"

info "Copiando _cryptosith (autocompletado)..."
cp "$SCRIPT_DIR/_cryptosith" "$ZSH_FUNCTIONS_DIR/_cryptosith"
chmod +x "$ZSH_FUNCTIONS_DIR/_cryptosith"
ok "Copiado: $ZSH_FUNCTIONS_DIR/_cryptosith"

info "Copiando manual.txt..."
mkdir -p "$CRYPTOSITH_CONFIG_DIR"
cp "$SCRIPT_DIR/manual.txt" "$CRYPTOSITH_CONFIG_DIR/manual.txt"
ok "Copiado: $CRYPTOSITH_CONFIG_DIR/manual.txt"

echo ""
echo -e "${BOLD}── Paso 3: Verificar autoload y compdef ──${NC}"
echo ""

if [[ -f "$ZSHRC" ]]; then
    if grep -q "cryptosith" "$ZSHRC"; then
        ok "cryptosith ya está en el autoload de .zshrc."
    else
        warn "cryptosith NO está en el autoload de .zshrc."
        echo ""
        echo -e "${YELLOW}Añade la siguiente línea al autoload -Uz de tu .zshrc:${NC}"
        echo -e "${CYAN}    cryptosith _cryptosith${NC}"
        echo ""
    fi
else
    warn "No existe $ZSHRC"
    warn "Instala zsh-config primero."
fi

if [[ -f "$COMPDEFS" ]]; then
    if grep -q "_cryptosith" "$COMPDEFS"; then
        ok "compdef _cryptosith ya está registrado."
    else
        warn "compdef _cryptosith NO está registrado."
        echo ""
        echo -e "${YELLOW}Añade la siguiente línea a $COMPDEFS:${NC}"
        echo -e "${CYAN}    compdef _cryptosith cryptosith${NC}"
        echo ""
    fi
else
    warn "No existe $COMPDEFS"
fi

echo ""
echo -e "${BOLD}── Instalación completada ──${NC}"
echo ""
echo -e "${GREEN}cryptosith está instalado.${NC}"
echo ""
echo -e "${YELLOW}⚠ IMPORTANTE:${NC}"
echo "  Si modificaste el .zshrc o el 31-compdefs.zsh, recarga:"
echo -e "    ${CYAN}exec zsh${NC}"
echo ""
echo -e "${CYAN}Verificar:${NC}"
echo -e "  ${YELLOW}type cryptosith${NC}    → debe mostrar la función"
echo -e "  ${YELLOW}cryp help${NC}          → ayuda corta"
echo -e "  ${YELLOW}cryp man${NC}           → manual completo"
echo ""
echo -e "${GREEN}¡Disfruta cryptosith!${NC}"
echo ""
