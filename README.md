# XFCE4 Dotfiles & Theming (Ottimizzato per Hardware Low-Power)

[![OS: Arch Linux](https://img.shields.io/badge/OS-Arch%20Linux-1793D1?logo=arch-linux&logoColor=white)](https://archlinux.org/)
[![DE: XFCE4](https://img.shields.io/badge/DE-XFCE4-blue?logo=xfce&logoColor=white)](https://www.xfce.org/)
[![Icons: Papirus](https://img.shields.io/badge/Icons-Papirus--Dark-purple)](https://github.com/PapirusDevelopmentTeam/papirus-icon-theme)
[![License: GPLv3](https://img.shields.io/badge/License-GPLv3-green.svg)](LICENSE)

Configurazione personalizzata, ultra-leggera e ottimizzata di **XFCE4** su **Arch Linux**, rifinita per hardware a basso consumo e display analogici VGA. Basata sul progetto originale del team di **EndeavourOS**.

---

## 📸 Anteprima Desktop

![XFCE4 Desktop Screenshot](assets/screenshot.png)

---

## 💻 Macchina di Riferimento (Hardware Target)

Questa configurazione è studiata appositamente per garantire la massima fluidità e reattività su processori low-power e configurazioni datate:

* **Processore (CPU):** AMD E1-2500 APU (2 Core, 2 Thread @ 1.4 GHz - architettura Jaguar)
* **Memoria (RAM):** 8 GB DDR3 + 3.6 GB ZRAM compressa (`vm.swappiness = 180`, `vm.page-cluster = 0`)
* **Scheda Video (GPU):** AMD Radeon HD 8240 (Kabini, GCN 1.1, driver kernel `amdgpu` con supporto Mesa / RADV)
* **Archiviazione:** SSD SATA 240 GB (con TRIM periodico abilitato)
* **Monitor & Connessione:** Risoluzione nativa `1680x1050` (16:10) connesso tramite porta analogica **VGA**

---

## 🚀 Ottimizzazioni e Migliorie Implementate

### 1. Fix Segnale VGA Analogico & Margini Finestre
* **Margine Destro Finestre a 26px (`xfwm4`):** Sui monitor LCD collegati in analogico (VGA), un disallineamento di clock/fase del segnale fa spesso slittare l'immagine verso destra, tagliando il pulsante di chiusura `[X]` delle finestre massimizzate. Con un margine desktop dedicato di 26px, le finestre a tutto schermo rimangono sempre al 100% visibili e cliccabili.
* **Pulsante Spegnimento Pannello Rientrato:** Aggiunto uno spaziatore a fine pannello per tenere l'icona di spegnimento a 33px dal bordo destro, prevenendo il ritaglio da overscan.

### 2. Tema Icone Moderno & Nitido (Papirus-Dark)
* Sostituite le vecchie icone raster con **Papirus-Dark** (vettoriali SVG puliti, moderni e leggerissimi).
* Sostituita l'icona ingannevole di disconnessione con il vero pulsante universale di **Spegnimento** (`⏻`).
* Regole CSS in `~/.config/gtk-3.0/gtk.css` per un allineamento pixel-perfect di orologio, volume e notifiche.

### 3. Suite Ufficio Integrata
* Lanciatori rapidi di **LibreOffice Writer** (Word) e **LibreOffice Calc** (Excel) integrati direttamente sul pannello principale accanto a Firefox.

### 4. Alleggerimento Carico CPU & Zero Overhead
* **Sfondo Nativo Pre-renderizzato:** Sostituita la rasterizzazione in tempo reale di file SVG pesanti (3840x2400) con uno sfondo PNG nativo `1680x1050`, azzerando i picchi di calcolo di Cairo/xfdesktop.
* **Disattivazione Screensaver Ridondante:** Rimosso il demone software `xfce4-screensaver` in favore del risparmio energetico hardware nativo DPMS gestito dal monitor.
* **Protezione Freeze su Thunar:** Limitata la creazione di miniature (*thumbnails*) ai soli file locali inferiori a 10 MB per evitare che cartelle pesanti saturino la CPU a 1.4 GHz.
* **Accelerazione Hardware GPU & Zero Accessibility Overhead:** Configurate in `~/.xprofile` (caricato direttamente da LightDM) le variabili d'ambiente per `radeonsi` (VA-API), WebRender e `NO_AT_BRIDGE=1` per disattivare il bridge `at-spi` e risparmiare RAM/D-Bus.
* **Pannello, Window Manager & Terminale Snelli:** Rimosso `power-manager-plugin` su desktop fisso, orologio senza secondi (`%H:%M`) per evitare ridisegni ogni secondo, `cycle_preview = false` in `xfwm4` e scrollback limitato (`10000` righe) in `xfce4-terminal`.
* **Gestione ZRAM:** Ottimizzati i parametri `vm.swappiness = 180`, `vm.page-cluster = 0`, `vm.watermark_boost_factor = 0` e `vm.watermark_scale_factor = 125` per sfruttare al meglio la compressione ZRAM in RAM.

---

## 📦 Installazione Rapida

```bash
git clone https://github.com/giorossi-sudo/xfce-dotfiles.git
cd xfce-dotfiles
./install.sh
```

Pacchetti aggiuntivi consigliati per questa configurazione:
```bash
sudo pacman -S --needed papirus-icon-theme libreoffice-still libreoffice-still-it ttf-liberation hunspell-it
```

---

## 🙏 Crediti e Riconoscimenti

* **Creatore originale del tema:** [EndeavourOS Team](https://github.com/EndeavourOS-Community-Editions/endeavouros-xfce4-theming) & [kerness](https://github.com/kerness).
* **Modifiche, fix VGA e ottimizzazioni hardware low-power:** Realizzate per **AMD E1-2500 APU** su **Arch Linux** da [giorossi-sudo](https://github.com/giorossi-sudo).
