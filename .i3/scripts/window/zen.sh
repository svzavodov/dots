#!/bin/bash

# Copyright (C) 2017-2021 by budRich
#
# Permission to use, copy, modify, and/or
# distribute this software for any purpose with or
# without fee is hereby granted.
#
# i3zen - move current window to a "clean" workspace,
# put it in a centered, floating tabbed container.
#
# triggering the command on a window that is already
# "zen" will move it back to the workspace it came
# from.
#
# https://www.reddit.com/r/i3wm/comments/6x8ajm/oc_i3zen/
# https://www.reddit.com/r/unixporn/comments/6xbdtk/oci3_i3zen/
# https://gist.github.com/budRich/16765b5468201aa734d0ec1c0870fd0c

: "${ZEN_VERBOSE:=0}"
# ZEN_VERBOSE=1

# ZEN_WORKSPACE - the workspace number you want to
# use for zen leave it empty if you want the
# script to use the next empty ws.
: "${ZEN_WORKSPACE:=}"

# percentage of screen zen container will be when
# it is created
: "${ZEN_WIDTH:=60}"
: "${ZEN_HEIGHT:=90}"

ERM() { >&2 echo "$*"; }

messy() {
	((ZEN_VERBOSE)) && ERM "m $*"
	_msgstring+="$*;"
}

declare -A i3list
eval "$(i3list -m centerzen)"

ws_zen=${i3list[WST]}

if [[ ! $ws_zen ]]; then

	ws_raw=$(i3-msg -t get_workspaces)

	new_zen=1

	re='"num":([0-9]+)'
	while [[ $ws_raw =~ $re ]]; do
		ws_temp=${BASH_REMATCH[1]}
		[[ $ZEN_WORKSPACE = "$ws_temp" ]] && taken=1
		ws_raw=${ws_raw/\"num\":$ws_temp/}
		((ws_temp > ws_free)) && ws_free=$ws_temp
	done

	[[ $ZEN_WORKSPACE && taken -ne 1 ]] &&
		ws_zen=$ZEN_WORKSPACE ||
		ws_zen=$((ws_free + 1))

	messy "[con_id=${i3list[AWC]}]" \
		"move to workspace number $ws_zen," \
		"floating disable," \
		"split v, layout tabbed," \
		"focus, focus parent"

	messy "mark centerzen"

	((ZEN_WIDTH < 0 || ZEN_WIDTH > 100)) && ZEN_WIDTH=100
	((ZEN_HEIGHT < 0 || ZEN_HEIGHT > 100)) && ZEN_HEIGHT=100

	width=$(((i3list[WAW] * ZEN_WIDTH) / 100))
	height=$(((i3list[WAH] * ZEN_HEIGHT) / 100))

	x=$((i3list[WAX] + (i3list[WAW] - width) / 2))
	y=$((i3list[WAY] + (i3list[WAH] - height) / 2))

	messy "[con_mark=centerzen] floating enable, workspace number $ws_zen"
	messy "[con_id=${i3list[AWC]}] focus"

	messy "[con_mark=centerzen]" \
		"resize set $width $height ," \
		"move position $x $y"

	i3var set "zen${i3list[AWC]}" "${i3list[AWF]}:${i3list[WAN]}"

elif ((i3list[WSA] == ws_zen)); then
	var_data=$(i3var get "zen${i3list[AWC]}")
	[[ $var_data =~ (0|1):(.+) ]] && {
		trg_ws=${BASH_REMATCH[2]}
		((BASH_REMATCH[1])) &&
			trg_float_state=enable ||
			trg_float_state=disable

		messy "[con_id=${i3list[AWC]}]" \
			floating enable, \
			"move to workspace $trg_ws," \
			"floating $trg_float_state," \
			"workspace $trg_ws"

		i3var set "zen${i3list[AWC]}"
	}

else
	messy "[con_id=${i3list[AWC]}]" \
		"floating disable," \
		"move to mark centerzen," \
		"focus, workspace number $ws_zen"

	i3var set "zen${i3list[AWC]}" "${i3list[AWF]}:${i3list[WAN]}"
fi

((ZEN_VERBOSE)) || qflag=-q
[[ $_msgstring ]] && i3-msg ${qflag:-} "$_msgstring"
unset _msgstring

# the variable new_zen is only set when the zen container is created.
# here we test if that workspace still exist. If it doesn't we move
# the zencontainer back to that workspace.
((new_zen)) && {
	re='"num":'"${i3list[WSA]}",
	[[ $(i3-msg -t get_workspaces) =~ $re ]] || {

		messy "[con_mark=centerzen]" \
			move to workspace "${i3list[WAN]}", \
			workspace "${i3list[WAN]}"

		i3-msg ${qflag:-} "$_msgstring"
	}
}
