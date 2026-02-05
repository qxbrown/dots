#!/bin/bash

STATE_FILE="/tmp/waybar_clock_state"

if [ ! -f "$STATE_FILE" ]; then
    echo "0" > "$STATE_FILE"
fi

case "$1" in
    "toggle")
        CURRENT_STATE=$(cat "$STATE_FILE")
        if [ "$CURRENT_STATE" -eq "0" ]; then
            echo "1" > "$STATE_FILE"
        else
            echo "0" > "$STATE_FILE"
        fi
        pkill -RTMIN+8 waybar
        ;;
    *)
        CURRENT_STATE=$(cat "$STATE_FILE")
        if [ "$CURRENT_STATE" -eq "0" ]; then
            ICON=""
            TEXT=$(date +'%H:%M')
        else
            ICON=""
            TEXT=$(date +'%A, %d %B %Y')
        fi
        echo -e "${ICON} ${TEXT}"  
        ;;
esac
