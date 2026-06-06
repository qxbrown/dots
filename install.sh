#!/usr/bin/env bash

set -e

GREEN='\e[1;32m'
BLUE='\e[1;34m'
RESET='\e[0m'

RICE_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"

if [[ $EUID -eq 0 ]]; then
    echo "Error: Don't run as root. Run as your user."
    exit 1
fi

echo -e "\n${GREEN}=== Rice — pacman-only install ===${RESET}\n"

# --- Pacman.conf ---
echo -e "\n${BLUE}Tweaking pacman (ParallelDownloads, ILoveCandy)...${RESET}"

sudo sed -i 's/^#\s*ParallelDownloads.*/ParallelDownloads = 15/' /etc/pacman.conf

grep -q "^ILoveCandy" /etc/pacman.conf || echo "ILoveCandy" | sudo tee -a /etc/pacman.conf >/dev/null

# --- Pacman packages (official repos only) ---
PACMAN_PACKAGES=(
    npm zsh git nodejs python go htop
    pipewire pipewire-alsa pipewire-audio pipewire-jack pipewire-pulse wireplumber
    pavucontrol pamixer mpd ncmpcpp acpi
    ttf-jetbrains-mono-nerd noto-fonts noto-fonts-cjk noto-fonts-emoji ttf-font-awesome
    hyprland xdg-desktop-portal-hyprland waybar dunst wofi swaybg grim slurp
    wl-clipboard cliphist hyprlock hypridle wlsunset brightnessctl
    kitty alacritty thunar tumbler ranger file-roller unzip
    eza fzf ripgrep duf bat zoxide
    mpv imv ffmpeg yt-dlp
    networkmanager bluez bluez-utils blueman nm-connection-editor
    polkit-gnome xdg-user-dirs gvfs-mtp android-tools fuse2
    qbittorrent firewalld neovim btop clang python-pillow perl-image-exiftool
    firefox discord tmux
    docker docker-compose docker-buildx
    terraform ansible
    zsh-autosuggestions zsh-syntax-highlighting
)

echo -e "\n${GREEN}Installing system packages via pacman...${RESET}"

VALID_PKGS=()

for pkg in "${PACMAN_PACKAGES[@]}"; do
    if pacman -Si "$pkg" &>/dev/null; then
        VALID_PKGS+=("$pkg")
    else
        echo "Skipping missing package: $pkg"
    fi
done

sudo pacman -S --needed --noconfirm "${VALID_PKGS[@]}"

echo -e "\n${GREEN}Setting up zsh plugins in ~/.zsh/...${RESET}"

mkdir -p "$HOME/.zsh/zsh-autosuggestions"
mkdir -p "$HOME/.zsh/zsh-syntax-highlighting"

if [[ -d /usr/share/zsh/plugins/zsh-autosuggestions ]]; then
    cp -rf /usr/share/zsh/plugins/zsh-autosuggestions/. "$HOME/.zsh/zsh-autosuggestions/"
    echo "Copied zsh-autosuggestions"
else
    echo "Warning: zsh-autosuggestions not found in /usr/share — skipping"
fi

if [[ -d /usr/share/zsh/plugins/zsh-syntax-highlighting ]]; then
    cp -rf /usr/share/zsh/plugins/zsh-syntax-highlighting/. "$HOME/.zsh/zsh-syntax-highlighting/"
    echo "Copied zsh-syntax-highlighting"
else
    echo "Warning: zsh-syntax-highlighting not found in /usr/share — skipping"
fi

# --- Copy config ---
echo -e "\n${GREEN}Copying configuration files...${RESET}"
mkdir -p "$CONFIG"
cp -rf "$RICE_DIR/.config/." "$CONFIG/"

# --- .zshrc ---
if [[ -f "$RICE_DIR/.zshrc" ]]; then
    cp "$RICE_DIR/.zshrc" "$HOME/"
    echo "Copied .zshrc"
else
    echo "Warning: .zshrc not found in repo root — skipping"
fi

# --- Tmux ---
if [[ -d "$RICE_DIR/tmux" ]]; then

    [[ -f "$RICE_DIR/tmux/.tmux.conf" ]] && \
        cp "$RICE_DIR/tmux/.tmux.conf" "$HOME/" && \
        echo "Copied .tmux.conf"

    mkdir -p "$HOME/tmux"
    cp -rf "$RICE_DIR/tmux/." "$HOME/tmux/"

    rm -f "$HOME/tmux/.tmux.conf"

    shopt -s nullglob
    tmux_scripts=("$HOME/tmux/"*.sh)
    shopt -u nullglob
    [[ ${#tmux_scripts[@]} -gt 0 ]] && chmod +x "${tmux_scripts[@]}"

    echo "Copied tmux folder"
fi

# --- Scripts to /usr/local/bin ---
echo -e "\n${BLUE}Copying scripts to /usr/local/bin...${RESET}"
sudo mkdir -p /usr/local/bin

[[ -f "$CONFIG/hypr/scripts/tmuxsession" ]] && \
    sudo cp "$CONFIG/hypr/scripts/tmuxsession" /usr/local/bin/ && \
    sudo chmod +x /usr/local/bin/tmuxsession

[[ -f "$CONFIG/hypr/scripts/tmuxcht.sh" ]] && \
    sudo cp "$CONFIG/hypr/scripts/tmuxcht.sh" /usr/local/bin/ && \
    sudo chmod +x /usr/local/bin/tmuxcht.sh

# --- Chmod scripts in config ---
echo "Making scripts executable..."

shopt -s nullglob

if [[ -d "$CONFIG/hypr/scripts" ]]; then
    hypr_scripts=("$CONFIG/hypr/scripts"/*)
    [[ ${#hypr_scripts[@]} -gt 0 ]] && chmod +x "${hypr_scripts[@]}"
fi

if [[ -d "$CONFIG/waybar/scripts" ]]; then
    waybar_scripts=("$CONFIG/waybar/scripts"/*.sh)
    [[ ${#waybar_scripts[@]} -gt 0 ]] && chmod +x "${waybar_scripts[@]}"
fi

shopt -u nullglob

# --- Directories ---
xdg-user-dirs-update
mkdir -p "$HOME/Pictures/Screenshot"

# --- Default shell to zsh ---
ZSH_PATH="$(command -v zsh)"

if [[ -z "$ZSH_PATH" ]]; then
    echo -e "${BLUE}zsh not found in PATH — skipping shell change.${RESET}"
else
    if ! grep -qF "$ZSH_PATH" /etc/shells; then
        echo "$ZSH_PATH" | sudo tee -a /etc/shells
    fi

    echo -e "${GREEN}Setting default shell to zsh...${RESET}"
    chsh -s "$ZSH_PATH" || echo -e "${BLUE}Could not change shell. Run: chsh -s \$(which zsh)${RESET}"
fi

echo ""
echo -e "${GREEN}=========================================="
echo "  Install complete! (pacman packages only)"
echo "  AUR packages were skipped."
echo "  Run install-rice-paru-only.sh to install them."
echo "==========================================${RESET}"
echo ""
echo "Start Hyprland from your display manager or run: Hyprland"
echo ""

read -n 1 -p "Start Hyprland now? (y/n): " HYP
echo
if [[ "$HYP" == "Y" || "$HYP" == "y" ]]; then
    exec Hyprland
else
    echo "Exiting."
    exit 0
fi
