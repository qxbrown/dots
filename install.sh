#!/usr/bin/env bash
# Full rice install — one script to rule them all.
# Usage: ./install.sh   (run from repo root, never as root)

set -e

GREEN='\e[1;32m'
BLUE='\e[1;34m'
RESET='\e[0m'

RICE_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"

# --- Root guard ---
if [[ $EUID -eq 0 ]]; then
    echo "Error: Don't run as root. Run as your user."
    exit 1
fi

echo -e "\n${GREEN}=== Rice — full install ===${RESET}\n"

# ─────────────────────────────────────────────
# STEP 1 — pacman.conf tweaks
# ─────────────────────────────────────────────
echo -e "${BLUE}Tweaking pacman (ParallelDownloads, ILoveCandy)...${RESET}"

sudo sed -i 's/^#\s*ParallelDownloads.*/ParallelDownloads = 15/' /etc/pacman.conf
grep -q "^ILoveCandy" /etc/pacman.conf || echo "ILoveCandy" | sudo tee -a /etc/pacman.conf >/dev/null

# ─────────────────────────────────────────────
# STEP 2 — pacman packages (official repos)
# ─────────────────────────────────────────────
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

echo -e "\n${GREEN}Installing pacman packages...${RESET}"

VALID_PKGS=()
for pkg in "${PACMAN_PACKAGES[@]}"; do
    if pacman -Si "$pkg" &>/dev/null; then
        VALID_PKGS+=("$pkg")
    else
        echo "  Skipping unknown package: $pkg"
    fi
done

sudo pacman -S --needed --noconfirm "${VALID_PKGS[@]}"

# ─────────────────────────────────────────────
# STEP 3 — zsh plugins into ~/.zsh/
# .zshrc sources from ~/.zsh/ but pacman puts
# them in /usr/share/ — bridge that gap here.
# ─────────────────────────────────────────────
echo -e "\n${GREEN}Setting up zsh plugins in ~/.zsh/...${RESET}"

mkdir -p "$HOME/.zsh/zsh-autosuggestions"
mkdir -p "$HOME/.zsh/zsh-syntax-highlighting"

if [[ -d /usr/share/zsh/plugins/zsh-autosuggestions ]]; then
    cp -rf /usr/share/zsh/plugins/zsh-autosuggestions/. "$HOME/.zsh/zsh-autosuggestions/"
    echo "  Copied zsh-autosuggestions"
else
    echo "  Warning: zsh-autosuggestions not found in /usr/share — skipping"
fi

if [[ -d /usr/share/zsh/plugins/zsh-syntax-highlighting ]]; then
    cp -rf /usr/share/zsh/plugins/zsh-syntax-highlighting/. "$HOME/.zsh/zsh-syntax-highlighting/"
    echo "  Copied zsh-syntax-highlighting"
else
    echo "  Warning: zsh-syntax-highlighting not found in /usr/share — skipping"
fi

# ─────────────────────────────────────────────
# STEP 4 — copy configs + .zshrc
# ─────────────────────────────────────────────
echo -e "\n${GREEN}Copying configuration files...${RESET}"

mkdir -p "$CONFIG"
cp -rf "$RICE_DIR/.config/." "$CONFIG/"

if [[ -f "$RICE_DIR/.zshrc" ]]; then
    cp "$RICE_DIR/.zshrc" "$HOME/"
    echo "  Copied .zshrc"
else
    echo "  Warning: .zshrc not found in repo root — skipping"
fi

# ─────────────────────────────────────────────
# STEP 5 — tmux
# ─────────────────────────────────────────────
if [[ -d "$RICE_DIR/tmux" ]]; then
    echo -e "\n${GREEN}Setting up tmux...${RESET}"

    [[ -f "$RICE_DIR/tmux/.tmux.conf" ]] && \
        cp "$RICE_DIR/tmux/.tmux.conf" "$HOME/" && \
        echo "  Copied .tmux.conf"

    mkdir -p "$HOME/tmux"
    cp -rf "$RICE_DIR/tmux/." "$HOME/tmux/"
    rm -f "$HOME/tmux/.tmux.conf"

    shopt -s nullglob
    tmux_scripts=("$HOME/tmux/"*.sh)
    shopt -u nullglob
    [[ ${#tmux_scripts[@]} -gt 0 ]] && chmod +x "${tmux_scripts[@]}"

    echo "  Copied tmux folder"
fi

# ─────────────────────────────────────────────
# STEP 6 — scripts to /usr/local/bin + chmod
# ─────────────────────────────────────────────
echo -e "\n${BLUE}Installing scripts to /usr/local/bin...${RESET}"
sudo mkdir -p /usr/local/bin

[[ -f "$CONFIG/hypr/scripts/tmuxsession" ]] && \
    sudo cp "$CONFIG/hypr/scripts/tmuxsession" /usr/local/bin/ && \
    sudo chmod +x /usr/local/bin/tmuxsession && \
    echo "  Installed tmuxsession"

[[ -f "$CONFIG/hypr/scripts/tmuxcht.sh" ]] && \
    sudo cp "$CONFIG/hypr/scripts/tmuxcht.sh" /usr/local/bin/ && \
    sudo chmod +x /usr/local/bin/tmuxcht.sh && \
    echo "  Installed tmuxcht.sh"

[[ -f "$CONFIG/hypr/scripts/linkhandler" ]] && \
    sudo cp "$CONFIG/hypr/scripts/linkhandler" /usr/local/bin/ && \
    sudo chmod +x /usr/local/bin/linkhandler && \
    echo "  Installed linkhandler"

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

# ─────────────────────────────────────────────
# STEP 7 — user directories
# ─────────────────────────────────────────────
xdg-user-dirs-update
mkdir -p "$HOME/Pictures/Screenshot"

# ─────────────────────────────────────────────
# STEP 8 — default shell to zsh
# chsh takes effect on next login, not now.
# ─────────────────────────────────────────────
echo -e "\n${GREEN}Setting default shell to zsh...${RESET}"

ZSH_PATH="$(command -v zsh)"

if [[ -z "$ZSH_PATH" ]]; then
    echo -e "${BLUE}  zsh not found in PATH — skipping shell change.${RESET}"
else
    if ! grep -qF "$ZSH_PATH" /etc/shells; then
        echo "$ZSH_PATH" | sudo tee -a /etc/shells
    fi
    chsh -s "$ZSH_PATH" || echo -e "${BLUE}  Could not change shell. Run manually: chsh -s \$(which zsh)${RESET}"
    echo "  Default shell set to $ZSH_PATH (takes effect on next login)"
fi

# ─────────────────────────────────────────────
# STEP 9 — paru install (needs base-devel+git
#           from step 2, zsh registered in step 8)
# ─────────────────────────────────────────────
echo -e "\n${BLUE}Checking for paru...${RESET}"

export PATH="$HOME/.local/bin:/usr/bin:$PATH"

ISAUR="/sbin/paru"
PARU_INST="$RICE_DIR/paru-inst.sh"

if [[ -f "$ISAUR" ]]; then
    echo -e "${GREEN}  Paru was located, moving on...${RESET}"
else
    echo "  Paru not found. Installing..."
    if [[ -f "$PARU_INST" ]]; then
        chmod +x "$PARU_INST"
        bash "$PARU_INST"
    else
        echo -e "${BLUE}  Warning: paru-inst.sh not found at $PARU_INST"
        echo -e "  Skipping paru. Place paru-inst.sh in repo root and re-run.${RESET}"
    fi
fi

# ─────────────────────────────────────────────
# STEP 10 — AUR packages (needs paru from step 9)
# ─────────────────────────────────────────────
if command -v paru &>/dev/null; then
    AUR_PACKAGES=(
        visual-studio-code-bin
        spotify
        brave-bin
        nwg-look
        hyprlock
        wlogout
        tldr
        newsboat
        urlview
        anyrun-git
        anyrun-provider-git
        banana-cursor-bin
        clipse-bin
        mpd-mpris-bin
    )

    echo -e "\n${BLUE}Installing AUR packages via paru...${RESET}"
    paru -S --needed --noconfirm "${AUR_PACKAGES[@]}"
    echo -e "${GREEN}  AUR packages installed.${RESET}"
else
    echo -e "${BLUE}  paru not available — skipping AUR packages.${RESET}"
    echo "  Install paru manually then run: paru -S visual-studio-code-bin spotify brave-bin nwg-look hyprlock wlogout newsboat urlview anyrun-git anyrun-provider-git banana-cursor-bin clipse-bin mpd-mpris-bin"
fi


# ─────────────────────────────────────────────
# Done
# ─────────────────────────────────────────────
echo ""
echo -e "${GREEN}=========================================="
echo "  Install complete!"
echo "  Log out and back in for zsh to take effect."
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
