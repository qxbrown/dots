#!/usr/bin/env zsh
# Sync colors from config/_theme/theme.conf to kitty, alacritty, dunst, wofi
# Run after editing _theme/theme.conf

set -e

RICE_DIR="$(cd "$(dirname "$0")" && pwd)"
THEME="$RICE_DIR/config/_theme/theme.conf"
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"

if [[ ! -f "$THEME" ]]; then
    echo "Error: $THEME not found"
    exit 1
fi

# Parse key=value (values may contain #); skip comment-only lines and empty lines
while IFS= read -r line; do
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    [[ -z "${line// /}" ]] && continue
    if [[ "$line" =~ ^([a-zA-Z0-9_]+)=(.*)$ ]]; then
        key="${match[1]}"
        val="${match[2]}"
        export "${key}=${val}"
    fi
done < "$THEME"

# Write kitty theme
KITTY_THEME="$RICE_DIR/config/kitty/theme.conf"
cat > "$KITTY_THEME" << EOF
# Generated from _theme/theme.conf — do not edit; run sync-colors.sh after changing _theme

foreground              ${foreground:-#aa80ff}
background              ${background:-#171a36}
selection_foreground    ${selection_foreground:-#aa80ff}
selection_background    ${selection_background:-#1c1f3d}

cursor                  ${cursor:-#aa80ff}
cursor_text_color       ${cursor_text:-#171a36}
url_color               ${accent_green:-#9ece6a}

active_border_color     ${accent:-#f53df5}
inactive_border_color   ${background_alt:-#1c1f3d}
bell_border_color       ${accent_yellow:-#f5d63d}

active_tab_foreground   ${cursor_text:-#171a36}
active_tab_background   ${accent:-#f53df5}
inactive_tab_foreground ${muted:-#d4c9c4}
inactive_tab_background ${background_alt:-#1c1f3d}
tab_bar_background      ${background:-#171a36}

color0  ${color0:-#171a36}
color1  ${color1:-#f53d40}
color2  ${color2:-#9ece6a}
color3  ${color3:-#f5d63d}
color4  ${color4:-#80bfff}
color5  ${color5:-#f53df5}
color6  ${color6:-#33ccff}
color7  ${color7:-#d4c9c4}
color8  ${color8:-#1c1f3d}
color9  ${color9:-#ff0080}
color10 ${color10:-#33ff99}
color11 ${color11:-#f5d63d}
color12 ${color12:-#80bfff}
color13 ${color13:-#ff33bb}
color14 ${color14:-#33ccff}
color15 ${color15:-#aa80ff}
EOF
echo "Updated $KITTY_THEME"

# Write alacritty rice-colors
ALACRITTY_COLORS="$RICE_DIR/config/alacritty/rice-colors.toml"
cat > "$ALACRITTY_COLORS" << EOF
# Generated from _theme/theme.conf — do not edit; run sync-colors.sh after changing _theme

[colors.primary]
background = "${background:-#171a36}"
foreground = "${foreground:-#aa80ff}"

[colors.cursor]
cursor = "${cursor:-#aa80ff}"
text = "${cursor_text:-#171a36}"

[colors.normal]
black = "${color0:-#171a36}"
blue = "${color4:-#80bfff}"
cyan = "${color6:-#33ccff}"
green = "${color2:-#9ece6a}"
magenta = "${color5:-#f53df5}"
red = "${color1:-#f53d40}"
white = "${color7:-#d4c9c4}"
yellow = "${color3:-#f5d63d}"

[colors.bright]
black = "${color8:-#1c1f3d}"
blue = "${color12:-#80bfff}"
cyan = "${color14:-#33ccff}"
green = "${color10:-#33ff99}"
magenta = "${color13:-#ff33bb}"
red = "${color9:-#ff0080}"
white = "${color15:-#aa80ff}"
yellow = "${color11:-#f5d63d}"
EOF
echo "Updated $ALACRITTY_COLORS"

# Write dunst
DUNST="$RICE_DIR/config/dunst/dunstrc"
cat > "$DUNST" << EOF
# Generated from _theme/theme.conf — run sync-colors.sh after changing _theme
[global]
font = JetBrains Mono Nerd Font
allow_markup = yes
origin = top-right
corner_radius = 0
offset = 6x6
width = (300, 580)
frame_width = 1
frame_color = "${accent:-#f53df5}"
separator_color = frame
alignment = center
notification_limit = 6
indicate_hidden = yes
gap_size = 5
mouse_left_click = close_current
mouse_middle_click = do_action, close_current
mouse_right_click = close_all
fullscreen_show_everything

[urgency_low]
background = "${background:-#171a36}"
foreground = "${foreground:-#aa80ff}"

[urgency_normal]
background = "${background:-#171a36}"
foreground = "${foreground:-#aa80ff}"

[urgency_critical]
background = "${background:-#171a36}"
foreground = "${critical:-#ff0080}"
frame_color = "${critical_alt:-#f53d40}"
EOF
echo "Updated $DUNST"

# Write wofi style
WOFI_CSS="$RICE_DIR/config/wofi/style.css"
cat > "$WOFI_CSS" << EOF
/* Generated from _theme/theme.conf — run sync-colors.sh after changing _theme */

* {
  font-family: "JetBrainsMono Nerd Font";
}

window {
  margin: 5px;
  backdrop-filter: blur(10px);
  border: none;
  font-family: JetBrains Mono;
}

#input {
  all: unset;
  min-height: 40px;
  border: none;
  color: ${accent_green:-#9ece6a};
  font-size: 16px;
  background-color: rgba(28, 31, 61, 0.8);
  outline: none;
}

#inner-box {
  margin: 4px;
  padding: 10px;
  font-weight: normal;
}

#outer-box {
  margin: 0px;
  padding: 10px;
  border: none;
  background-color: transparent;
}

#scroll {
  margin-top: 4px;
  border: none;
  border-radius: 15px;
  background-color: transparent;
}

#text:selected {
  color: ${foreground:-#aa80ff};
  background-color: rgba(0, 0, 0, 0.1);
}

#entry {
  margin: 0px;
  border: none;
  background-color: transparent;
  font-size: 14px;
}

#entry:selected {
  margin: 0px;
  border: none;
  background: rgba(255, 255, 255, 0.1);
}
EOF
echo "Updated $WOFI_CSS"

echo ""
echo "Colors synced. If config is already in ~/.config, copy again: cp -r config/* ~/.config"
echo ""
