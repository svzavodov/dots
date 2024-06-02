#!/bin/sh

OUTPUT="HDMI-1-1"
DP="eDP-1"
RESOLUTION="3440x1440"
# Замените 60 на желаемую частоту обновления

xrandr --output $OUTPUT --mode $RESOLUTION

xrandr --output $DP --off
