#!/usr/bin/env bash
# Battery low/critical notifications. Runs at Hyprland startup.
# Depends: acpi or upower. Install: acpi (Arch)

notify_low=20
notify_critical=10
cooldown_file="${XDG_RUNTIME_DIR:-/tmp}/batterynotify_cooldown"

get_percent() {
  if command -v acpi &>/dev/null; then
    acpi -b 2>/dev/null | grep -oP '\d+(?=%)' | head -1
  elif command -v upower &>/dev/null; then
    upower -i /org/freedesktop/UPower/devices/battery_BAT0 2>/dev/null | awk '/percentage/ { gsub(/%/, ""); print $2 }'
  else
    echo ""
  fi
}

is_charging() {
  if command -v acpi &>/dev/null; then
    acpi -b 2>/dev/null | grep -qi "charging\|full"
  else
    upower -i /org/freedesktop/UPower/devices/battery_BAT0 2>/dev/null | grep -qi "state.*charging\|state.*fully"
  fi
}

run_once_per_level() {
  local level=$1
  if [[ -f "$cooldown_file" ]]; then
    read -r last < "$cooldown_file" 2>/dev/null
    [[ "$last" == "$level" ]] && return 1
  fi
  echo "$level" > "$cooldown_file"
  return 0
}

p=$(get_percent)
[[ -z "$p" ]] && exit 0
is_charging && exit 0

if (( p <= notify_critical )); then
  run_once_per_level "critical" && notify-send -u critical "Battery critical" "Battery at ${p}%. Plug in soon."
elif (( p <= notify_low )); then
  run_once_per_level "low" && notify-send "Battery low" "Battery at ${p}%."
fi

exit 0
