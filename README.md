# Rice — Arch Hyprland config

Clone this repo and run **`./install-rice.sh`** — it does the full install
automatically (paru, packages, config, scripts). One file for colors:
**`config/_theme/theme.conf`** — run `./sync-colors.sh` only when you change it.

## Quick apply (one script, does everything)

```bash
git clone https://github.com/qxbrown/dots.git
cd dots
chmod +x install-rice.sh
./install-rice.sh
```

### Neovim

Clone this repo for the neovim.

```bash
git clone https://github.com/BIIJESH/nvim-dots.git
mv nvim-dots nvim
mv nvim ~/.config
nvim .
:Lazy
```

After that Install and Update Neovim
