#!/usr/bin/env bash
# Full rice install: paru + pacman + AUR + config + scripts. Run from repo root.
# Usage: ./install-rice.sh  (does everything automatically)

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

echo -e "\n${GREEN}=== Rice — full install ===${RESET}\n"

# --- Paru ---

# FIX 1: Export PATH early so ~/.local/bin paru is found before the version check
export PATH="$HOME/.local/bin:/usr/bin:$PATH"

install_paru() {
    sudo pacman -S --needed --noconfirm base-devel git

    local TMPDIR
    TMPDIR=$(mktemp -d)

    # FIX 2: Trap to clean up tmpdir even on failure
    trap 'rm -rf "$TMPDIR"' EXIT

    git clone https://aur.archlinux.org/paru-bin.git "$TMPDIR/paru-bin"

    # FIX 3: Use pushd/popd instead of bare cd so we always return to RICE_DIR
    pushd "$TMPDIR/paru-bin" > /dev/null

    # makepkg must NOT be run as root; already guarded above
    makepkg -si --noconfirm

    popd > /dev/null

    trap - EXIT
    rm -rf "$TMPDIR"
}

echo -e "${GREEN}Checking paru...${RESET}"

if paru --version &>/dev/null; then
    echo -e "${GREEN}Paru is working.${RESET}"
else
    echo -e "${BLUE}Paru missing or broken. Reinstalling...${RESET}"

    # FIX 4: Only attempt removal if it is actually installed as a package;
    #         avoids a pacman error that would kill the script under set -e
    if pacman -Qi paru-bin &>/dev/null 2>&1; then
        sudo pacman -Rns --noconfirm paru-bin
    fi

    # Remove stale binary regardless
    sudo rm -f /usr/bin/paru 2>/dev/null || true

    install_paru
fi

# Verify paru is actually usable before continuing
if ! paru --version &>/dev/null; then
    echo "Error: paru installation failed. Aborting."
    exit 1
fi

echo -e "${GREEN}Paru ready.${RESET}"

# --- Pacman.conf ---
echo -e "\n${BLUE}Tweaking pacman (ParallelDownloads, ILoveCandy)...${RESET}"

sudo sed -i 's/^#\s*ParallelDownloads.*/ParallelDownloads = 15/' /etc/pacman.conf

grep -q "^ILoveCandy" /etc/pacman.conf || echo "ILoveCandy" | sudo tee -a /etc/pacman.conf >/dev/null

# --- Pacman packages (all from official repos) ---
PACMAN_PACKAGES=(
    npm zsh git nodejs python go htop
    pipewire pipewire-alsa pipewire-audio pipewire-jack pipewire-pulse wireplumber
    pavucontrol pamixer mpd ncmpcpp acpi
    ttf-jetbrains-mono-nerd noto-fonts noto-fonts-cjk noto-fonts-emoji ttf-font-awesome
    hyprland xdg-desktop-portal-hyprland waybar dunst wofi swaybg grim slurp
    wl-clipboard cliphist hyprlock hypridle wlsunset brightnessctl
    kitty alacritty thunar tumbler ranger file-roller unzip
    eza fzf ripgrep duf bat
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

# --- AUR packages ---
AUR_PACKAGES=(
    visual-studio-code-bin spotify brave-bin nwg-look zoxide tldr xclip urlview
    anyrun-git anyrun-provider-git wlogout
)

echo -e "\n${BLUE}Installing AUR packages via paru...${RESET}"
paru -S --needed --noconfirm "${AUR_PACKAGES[@]}"

# --- Copy config ---
echo -e "\n${GREEN}Copying configuration files...${RESET}"
mkdir -p "$CONFIG"
cp -rf "$RICE_DIR/.config/." "$CONFIG/"

# --- Optional: .zshrc ---
[[ -f "$RICE_DIR/.zshrc" ]] && cp "$RICE_DIR/.zshrc" "$HOME/" && echo "Copied .zshrc"

# --- Tmux ---
if [[ -d "$RICE_DIR/tmux" ]]; then

    [[ -f "$RICE_DIR/tmux/.tmux.conf" ]] && \
        cp "$RICE_DIR/tmux/.tmux.conf" "$HOME/" && \
        echo "Copied .tmux.conf"

    mkdir -p "$HOME/tmux"
    cp -rf "$RICE_DIR/tmux/." "$HOME/tmux/"

    # Remove duplicate .tmux.conf from ~/tmux/
    rm -f "$HOME/tmux/.tmux.conf"

    # FIX 5: Only chmod if .sh files actually exist; avoids a globbing error
    #         under set -e when the directory has no .sh files
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

# FIX 6: Use nullglob for both script dirs to avoid errors when dirs are empty
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

# FIX 7: Removed the duplicate chmod of named scripts — they were already
#         covered by the glob above and the redundant call caused set -e exits
#         if any of those specific files didn't exist.

# --- Directories ---
xdg-user-dirs-update
mkdir -p "$HOME/Pictures/Screenshot"

# --- Default shell to zsh ---
# FIX 8: Replace zsh-specific `whence` with bash-compatible `command -v`
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
echo "  Install complete!"
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
