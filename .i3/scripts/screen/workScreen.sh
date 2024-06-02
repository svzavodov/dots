#!/bin/sh

OUTPUT="eDP-1"
HDMI="HDMI-1-1"
RESOLUTION="2560x1440"
# Замените 60 на желаемую частоту обновления
REFRESH_RATE="165"

xrandr --output $OUTPUT --mode $RESOLUTION --rate $REFRESH_RATE

xrandr --output $HDMI --off
