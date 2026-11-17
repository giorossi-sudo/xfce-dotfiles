#!/usr/bin/env bash
# Script di installazione e allineamento dotfiles XFCE4 (Full HD DVI-D / HDMI)
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

WALLPAPER="$HOME/.local/share/backgrounds/sfondo_1920x1080.png"
WALLPAPER_STYLE=5

# Se xfconfd è attivo in sessione, fermalo prima di sovrascrivere gli XML
if command -v pgrep >/dev/null 2>&1 && pgrep -u "$USER" -x xfconfd >/dev/null 2>&1; then
    echo "==> Arresto temporaneo di xfconfd per applicare i nuovi XML..."
    pkill -TERM -u "$USER" -x xfconfd || true
    for _ in 1 2 3 4 5 6 7 8 9 10; do
        pgrep -u "$USER" -x xfconfd >/dev/null 2>&1 || break
        sleep 0.2
    done
fi

echo "==> Copia delle configurazioni, sfondi e tema Arc-Darker-solid..."
mkdir -p "$HOME/.config" "$HOME/.local/share/backgrounds" "$HOME/.local/share/themes"

cp -r .config/* "$HOME/.config/"
cp -r .local/share/backgrounds/* "$HOME/.local/share/backgrounds/"
if [ -d ".local/share/themes" ]; then
    cp -r .local/share/themes/* "$HOME/.local/share/themes/"
fi

# Copia .xprofile (letto da LightDM/X11 anche con bash --login) o aggiunge le variabili se mancanti
if [ -f "$HOME/.xprofile" ]; then
    if ! grep -q "LIBVA_DRIVER_NAME" "$HOME/.xprofile"; then
        {
            echo ""
            echo "# Hardware acceleration environment for AMD GPU (Radeon HD 8240 / amdgpu)"
            echo "export LIBVA_DRIVER_NAME=radeonsi"
            echo "export MOZ_WEBRENDER=1"
            echo "export MOZ_ACCELERATED=1"
        } >> "$HOME/.xprofile"
    fi
    if ! grep -q "NO_AT_BRIDGE" "$HOME/.xprofile"; then
        {
            echo ""
            echo "# Disable AT-SPI accessibility bridge to reduce D-Bus/GTK overhead"
            echo "export NO_AT_BRIDGE=1"
        } >> "$HOME/.xprofile"
    fi
else
    cp .xprofile "$HOME/.xprofile"
fi

# Adatta automaticamente i percorsi assoluti all'utente corrente
echo "==> Adattamento percorsi alla home dell'utente ($HOME)..."
sed -i "s|/home/[^/]*|${HOME}|g" "$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml" 2>/dev/null || true

# Configurazione opzionale ZRAM
if [ -f "etc/sysctl.d/99-zram.conf" ]; then
    read -p "Vuoi applicare la configurazione di memoria ZRAM (/etc/sysctl.d/99-zram.conf)? [s/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Ss]$ ]]; then
        sudo cp etc/sysctl.d/99-zram.conf /etc/sysctl.d/
        sudo sysctl -p /etc/sysctl.d/99-zram.conf || true
    fi
fi

# Ricaricamento dell'interfaccia solo se è attiva una sessione grafica X11
if [ -n "${DISPLAY:-}" ]; then
    echo "==> Ricaricamento della sessione XFCE..."
    # Riattiva xfconfd sui nuovi XML e configura lo sfondo sulle uscite video connesse (es. DVI-D-0, HDMI-1)
    if command -v xfconf-query >/dev/null 2>&1 && command -v xrandr >/dev/null 2>&1; then
        xfconf-query -c xfce4-desktop -l >/dev/null 2>&1 || true
        while IFS= read -r out; do
            [ -z "$out" ] && continue
            for ws in workspace0 workspace1; do
                xfconf-query -c xfce4-desktop -p "/backdrop/screen0/monitor${out}/${ws}/color-style" -n -t int -s 0 || true
                xfconf-query -c xfce4-desktop -p "/backdrop/screen0/monitor${out}/${ws}/image-style" -n -t int -s "$WALLPAPER_STYLE" || true
                xfconf-query -c xfce4-desktop -p "/backdrop/screen0/monitor${out}/${ws}/last-image" -n -t string -s "$WALLPAPER" || true
            done
        done < <(xrandr --query 2>/dev/null | awk '/ connected/{print $1}')
    fi

    xfsettingsd --replace >/dev/null 2>&1 & disown || true
    xfce4-panel -r || true
    xfdesktop --reload || true
    xfwm4 --replace >/dev/null 2>&1 & disown || true
fi

echo "==> Installazione completata con successo!"
