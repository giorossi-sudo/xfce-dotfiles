#!/usr/bin/env bash
# Script di installazione e allineamento dotfiles XFCE4
set -e

echo "==> Copia delle configurazioni utente..."
mkdir -p "$HOME/.config" "$HOME/.local/share/backgrounds"

cp -r .config/* "$HOME/.config/"
cp -r .local/share/backgrounds/* "$HOME/.local/share/backgrounds/"

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

# Ricaricamento dell'interfaccia
echo "==> Ricaricamento del pannello XFCE e del gestore finestre..."
xfce4-panel -r || true
xfwm4 --replace >/dev/null 2>&1 & disown || true

echo "==> Installazione completata con successo!"
