#!/usr/bin/env bash

set -e

if [[ $EUID -eq 0 ]]; then
    echo "Error: Don't run paru-inst.sh as root."
    exit 1
fi

if pacman -Qi paru-bin &>/dev/null 2>&1; then
    echo "Removing stale paru-bin..."
    sudo pacman -Rns --noconfirm paru-bin
fi
sudo rm -f /usr/bin/paru /sbin/paru 2>/dev/null || true

echo "Installing rust (required to build paru from source)..."
sudo pacman -S --needed --noconfirm rust

echo "Building paru from source..."

mkdir -p "$HOME/Clone"

# Clone paru source (not paru-bin)
git clone https://aur.archlinux.org/paru.git "$HOME/Clone/paru"

pushd "$HOME/Clone/paru" > /dev/null

makepkg -si --noconfirm

popd > /dev/null

echo "Paru installed successfully."
exit 0
