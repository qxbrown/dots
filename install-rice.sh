#!/usr/bin/env bash
# Full rice install: paru + pacman + AUR + config + scripts. Run from repo root.
# Usage: ./install-rice.sh  (does everything automatically)

set -e

GREEN='\e[1;32m'
BLUE='\e[1;34m'
RESET='\e[0m'

RICE_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"
PARU_INST="$RICE_DIR/paru-inst"

if [[ $EUID -eq 0 ]]; then
   echo "Error: Don't run as root. Run as your user."
   exit 1
fi

echo -e "\n${GREEN}=== Rice — full install ===${RESET}\n"

# --- Paru ---
if command -v paru &>/dev/null; then
    echo -e "${GREEN}Paru detected, moving on...${RESET}"
else
    echo -e "${BLUE}Paru not found. Installing paru...${RESET}"
    if [[ -f "$PARU_INST" ]]; then
        chmod +x "$PARU_INST"
        "$PARU_INST"
        export PATH="$HOME/.local/bin:/usr/bin:$PATH"
    else
        echo "paru-inst not found. Install paru manually (https://github.com/Morganamilo/paru) then re-run."
        exit 1
    fi
    echo -e "${GREEN}Paru installation complete.${RESET}"
fi

# --- Pacman.conf ---
echo -e "\n${BLUE}Tweaking pacman (ParallelDownloads, ILoveCandy)...${RESET}"
sudo sed -i 's/^#ParallelDownloads = 5$/ParallelDownloads = 15\nILoveCandy/' /etc/pacman.conf 2>/dev/null || true

# --- Pacman packages (all from official repos) ---
PACMAN_PACKAGES=(
    npm zsh pipewire pipewire-alsa pipewire-audio pipewire-jack pipewire-media-session
    ttf-jetbrains-mono-nerd noto-fonts-emoji noto-fonts-cjk ttf-font-awesome polkit-gnome mpv imv ffmpeg
    hyprland dunst wofi swaybg grim slurp kitty pamixer brightnessctl waybar xdg-desktop-portal-hyprland
    cliphist clang bluez bluez-utils pulseaudio-bluetooth gvfs-mtp btop qbittorrent thunar tumbler unzip
    file-roller android-tools xdg-user-dirs ranger python-pillow firewalld neovim eza ripgrep perl-image-exiftool
    duf fzf wl-clipboard wlogout wlsunset hyprlock hypridle
    alacritty networkmanager bluetooth blueman nm-connection-editor jmtpfs fuse2
    pamixer pavucontrol mpd ncmpcpp acpi
    discord firefox tmux git nodejs python go htop
    terraform docker docker-compose docker-buildx docker-machine
    kubectl kubeadm kubelet minikube ansible aws-cli
    zsh-autosuggestions zsh-syntax-highlighting
)

echo -e "\n${GREEN}Installing system packages via pacman...${RESET}"
sudo pacman -S --needed --noconfirm "${PACMAN_PACKAGES[@]}"

# --- AUR packages ---
AUR_PACKAGES=(
    visual-studio-code-bin spotify brave-bin mpd-mpris-bin nwg-look zoxide tldr newsboat xclip urlview bat yt-dlp
    anyrun-git anyrun-provider-git banana-cursor-bin clipse-bin
)

echo -e "\n${BLUE}Installing AUR packages via paru...${RESET}"
paru -S --needed --noconfirm "${AUR_PACKAGES[@]}"

# --- Copy config ---
echo -e "\n${GREEN}Copying configuration files...${RESET}"
mkdir -p "$CONFIG" "$HOME/tmux"
cp -rf "$RICE_DIR/.config/." "$CONFIG/"

# --- Optional: .zshrc and tmux ---
[[ -f "$RICE_DIR/.zshrc" ]] && cp "$RICE_DIR/.zshrc" "$HOME/" && echo "Copied .zshrc"
[[ -f "$RICE_DIR/.tmux.conf" ]] && cp "$RICE_DIR/.tmux.conf" "$HOME/" && echo "Copied .tmux.conf"

# --- Scripts to /usr/local/bin ---
echo -e "\n${BLUE}Copying scripts to /usr/local/bin...${RESET}"
sudo mkdir -p /usr/local/bin
[[ -f "$CONFIG/hypr/scripts/tmuxsession" ]] && sudo cp "$CONFIG/hypr/scripts/tmuxsession" /usr/local/bin/ && sudo chmod +x /usr/local/bin/tmuxsession
[[ -f "$CONFIG/hypr/scripts/tmuxcht.sh" ]] && sudo cp "$CONFIG/hypr/scripts/tmuxcht.sh" /usr/local/bin/ && sudo chmod +x /usr/local/bin/tmuxcht.sh

# --- Chmod scripts in config ---
echo "Making scripts executable..."

if [[ -d "$CONFIG/hypr/scripts" ]]; then
    chmod +x "$CONFIG/hypr/scripts"/* 2>/dev/null || true
fi

if [[ -d "$CONFIG/waybar/scripts" ]]; then
    chmod +x "$CONFIG/waybar/scripts"/*.sh 2>/dev/null || true
fi
chmod +x "$CONFIG/hypr/scripts"/{linkhandler,lookup.sh,tmuxsession,tmuxcht.sh} 2>/dev/null || true

# --- Directories ---
mkdir -p "$CONFIG/hypr/img" "$HOME/Pictures/Screenshot" "$HOME/startpage"

# --- Default shell to zsh ---
if ! grep -q "$(whence -p zsh)" /etc/shells 2>/dev/null; then
    whence -p zsh | sudo tee -a /etc/shells
fi
echo -e "${GREEN}Setting default shell to zsh...${RESET}"
chsh -s "$(whence -p zsh)" || echo -e "${BLUE}Could not change shell. Run: chsh -s \$(which zsh)${RESET}"

# --- Wallpaper ---
if [[ -f "$CONFIG/hypr/img/mario.jpg" ]]; then
    echo "  mario.jpg found (desktop + lock screen)"
else
    echo "  Add mario.jpg to $CONFIG/hypr/img/"
fi

echo ""
echo -e "${GREEN}=========================================="
echo "  Install complete!"
echo "==========================================${RESET}"
echo ""
echo "Start Hyprland from your display manager or run: Hyprland"
echo ""

read -k 1 "HYP?Start Hyprland now? (y/n): "
echo
if [[ "$HYP" == "Y" || "$HYP" == "y" ]]; then
    exec Hyprland
else
    echo "Exiting."
    exit 0
fi
