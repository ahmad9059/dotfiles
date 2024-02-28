#!/usr/bin/env bash

## Copyright (C) 2020-2024 Aditya Shakya <adi1090x@gmail.com>
##
## Script to take screenshots on Archcraft.

# file
time=`date +%Y-%m-%d-%H-%M-%S`
geometry=`xrandr | grep 'current' | head -n1 | cut -d',' -f2 | tr -d '[:blank:],current'`
dir="`xdg-user-dir PICTURES`/Screenshots"
file="Screenshot_${time}_${geometry}.png"

# directory
if [[ ! -d "$dir" ]]; then
	mkdir -p "$dir"
fi

# notify and view screenshot
notify_view () {
	notify_cmd_shot='dunstify -u low -h string:x-dunst-stack-tag:obscreenshot -i /usr/share/archcraft/icons/dunst/picture.png'
	${notify_cmd_shot} "Copied to clipboard."
	paplay /usr/share/sounds/freedesktop/stereo/screen-capture.oga &>/dev/null &
	viewnior ${dir}/"$file"
	if [[ -e "$dir/$file" ]]; then
		${notify_cmd_shot} "Screenshot Saved."
	else
		${notify_cmd_shot} "Screenshot Deleted."
	fi
}

# copy screenshot to clipboard
copy_shot () {
	tee "$file" | xclip -selection clipboard -t image/png
}

# countdown
countdown () {
	for sec in `seq $1 -1 1`; do
		dunstify -t 1000 -h string:x-dunst-stack-tag:screenshottimer -i /usr/share/archcraft/icons/dunst/timer.png "Taking shot in : $sec"
		sleep 1
	done
}

# take shots
shotnow () {
	cd ${dir} && maim -u -f png | copy_shot
	notify_view
}

shot5 () {
	countdown '5'
	sleep 1 && cd ${dir} && maim -u -f png | copy_shot
	notify_view
}

shot10 () {
	countdown '10'
	sleep 1 && cd ${dir} && maim -u -f png | copy_shot
	notify_view
}

shotwin () {
	cd ${dir} && maim -u -f png -i `xdotool getactivewindow` | copy_shot
	notify_view
}

shotarea () {
	cd ${dir} && maim -u -f png -s -b 2 -c 0.35,0.55,0.85,0.25 -l | copy_shot
	notify_view
}

# execute
if [[ "$1" == "--now" ]]; then
	shotnow
elif [[ "$1" == "--in5" ]]; then
	shot5
elif [[ "$1" == "--in10" ]]; then
	shot10
elif [[ "$1" == "--win" ]]; then
	shotwin
elif [[ "$1" == "--area" ]]; then
	shotarea
else
	echo -e "Available Options : --now --in5 --in10 --win --area"
fi

exit 0
