#!/bin/sh

OUTPUT="HDMI-1-1"
DP="eDP-1"
RESOLUTION="1920x1080"
# Замените 60 на желаемую частоту обновления
REFRESH_RATE="60"
POS="1920x0"
xrandr --output $OUTPUT --mode $RESOLUTION --rate $REFRESH_RATE --pos $POS




