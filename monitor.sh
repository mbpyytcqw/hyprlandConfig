#!/usr/bin/env bash

INTERNAL="eDP-1"
EXTERNAL="HDMI-A-1"

if hyprctl monitors all | grep -q "^Monitor $EXTERNAL"; then
    # HDMI есть — включаем только его и отключаем eDP
    hyprctl keyword monitor "$INTERNAL,disable"
    hyprctl keyword monitor "$EXTERNAL,3440x1440@99,0x0,1.0"
else
    # HDMI нет — включаем только eDP и отключаем HDMI
    hyprctl keyword monitor "$EXTERNAL,disable"
    hyprctl keyword monitor "$INTERNAL,1920x1080@144.00301,0x0,1.0"
fi
