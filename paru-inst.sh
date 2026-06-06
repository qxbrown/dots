#!/usr/bin/env bash

set -e

if [[ $EUID -eq 0 ]]; then
    echo "Error: Don't run paru-inst.sh as root."
    exit 1
fi

echo "Building paru-bin from AUR..."

# base-devel and git must already be installed (install.sh does this in step 2)
mkdir -p "$HOME/Clone"

git clone https://aur.archlinux.org/paru-bin.git "$HOME/Clone/paru"

pushd "$HOME/Clone/paru" > /dev/null

makepkg -si --noconfirm

popd > /dev/null

echo "Paru installed successfully."
exit 0
