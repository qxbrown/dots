# Anyrun

Anyrun (Super+Space) needs its **daemon** running so the GUI can connect over D-Bus.

**Startup:** `anyrun daemon` is already in `hypr/hyprland.conf` as `exec-once = anyrun daemon`. After applying the rice config and restarting Hyprland, the daemon starts on login.

**If anyrun doesn’t open:** run `anyrun daemon &` in a terminal once, then try Super+Space. Ensure both `anyrun` and `anyrun-provider` are installed (e.g. `pacman -S anyrun anyrun-provider` or AUR `anyrun-git` `anyrun-provider-git`).
