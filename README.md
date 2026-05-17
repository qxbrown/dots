# Rice — Arch Hyprland config

Clone this repo and run **`./install-rice.sh`** — it does the full install automatically (paru, packages, config, scripts). One file for colors: **`config/_theme/theme.conf`** — run `./sync-colors.sh` only when you change it.

## Quick apply (one script, does everything)

```bash
git clone https://github.com/YOUR_USER/rice.git ~/rice
cd ~/rice
chmod +x install-rice.sh
./install-rice.sh
```

`install-rice.sh` does everything automatically: paru (via paru-inst if missing), pacman.conf tweak, pacman packages, AUR packages (paru), copy config to `~/.config`, copy tmuxsession/tmuxcht.sh to `/usr/local/bin`, chmod all scripts, create dirs. At the end it asks to start Hyprland (y/n).

### Wallpaper

Put **mario.jpg** in **`config/hypr/img/`** — used for desktop background and lock screen. See `config/hypr/img/README.md`.

### Changing colors (one file)

1. Edit **`config/_theme/theme.conf`** (or `~/.config/_theme/theme.conf` after
   setup).
2. From the repo root run: **`./sync-colors.sh`**
3. That updates kitty/theme.conf, alacritty/rice-colors.toml, dunst/dunstrc,
   wofi/style.css. If config is already in `~/.config`, copy again:
   `cp -r config/* ~/.config`

### Neovim colorscheme

Tokyo Night is removed. In `init.lua`: `require("init-rice")` or set
`vim.g.rice_colorscheme = "habamax"` (or another scheme) before plugins load.

## Dependencies (Arch)

Install before using:

- **Hyprland**: `hyprland`, `hyprlock`, `hypridle`, `wl-paste` (wl-clipboard),
  `cliphist`, `grim`, `slurp`, `wlogout`, `swaybg`, `wlsunset`, `polkit-gnome`
- **Waybar**: `waybar`
- **Terminal**: `alacritty` and/or `kitty`
- **Launcher / menu**: `anyrun` + `anyrun-provider` (daemon starts via `exec-once = anyrun daemon` in hyprland), `wofi`
- **Notifications**: `dunst`
- **Font**: `ttf-jetbrains-mono-nerd`
- **Battery script**: `acpi` (for batterynotify.sh)
- **Ranger**: `ranger`
- **Optional**: `mpd`, `ncmpcpp`, `thunar`, `ranger`, `nvim`, `brave`,
  `spotify`, `discord`, `code`, `thinkfan`, `brightnessctl`, `pamixer`,
  `pavucontrol`, `nm-connection-editor`, `blueman-manager`

## Theme customization (one file)

Edit **`config/_theme/theme.conf`** (or `~/.config/_theme/theme.conf`). Then run
**`./sync-colors.sh`** — it writes the same colors to:

- Kitty (`config/kitty/theme.conf`)
- Alacritty (`config/alacritty/rice-colors.toml`)
- Dunst (`config/dunst/dunstrc`)
- Wofi (`config/wofi/style.css`)

Waybar is custom and not auto-synced; if you change waybar colors, update
`_theme/theme.conf` to match and run `sync-colors.sh` so the rest stay in sync.

## What was fixed from the original config

- **Hyprland**: `exec-once` path for batterynotify was `/usr/config/...` →
  `~/.config/hypr/scripts/batterynotify.sh`; added `batterynotify.sh` script;
  removed duplicate `animation = windows`; Print key — one binding for save,
  `$mainMod Print` for copy.
- **Wofi**: Removed `@import "/home/papa/.cache/wal/..."` (wrong user, pywal);
  wofi uses inline colors from theme.
- **Ranger**: Removed `map bw shell wal -i %s` (pywal); colorscheme stays
  `default`.
- **Neovim**: Tokyo Night removed; use `vim.g.rice_colorscheme` or set
  colorscheme in init.

## Layout

```
rice/
  config/
    _theme/theme.conf    # One file for colors — edit this, then run sync-colors.sh
    anyrun/              # Anyrun launcher (config.ron, style.css, websearch, plugins)
    hypr/                # Hyprland, hyprlock, scripts (batterynotify, lookup, power, tmuxsession, customhtml, fan, mountandroid, unmountandroid, tmuxcht)
    hypr/img/            # Put mario.jpg here (desktop + lock screen)
    waybar/
    kitty/
    alacritty/
    dunst/
    wofi/
    ranger/
    nvim/
  install-rice.sh        # Full install: paru + pacman + AUR + config + scripts
  paru-inst              # Used by install-rice.sh to install paru if missing
  sync-colors.sh         # Optional: sync _theme/theme.conf → kitty, alacritty, dunst, wofi
  README.md
```
