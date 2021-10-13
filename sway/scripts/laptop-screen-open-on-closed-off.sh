#!/usr/bin/bash
# https://github.com/swaywm/sway/wiki#Multihead
laptop_screen=${1}
if grep -q open /proc/acpi/button/lid/LID/state; then
    swaymsg output "${laptop_screen}" enable
else
    swaymsg output "${laptop_screen}" disable
fi
