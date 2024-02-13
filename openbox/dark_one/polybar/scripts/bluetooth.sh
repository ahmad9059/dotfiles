#!/usr/bin/env bash

## Copyright (C) 2020-2024 Aditya Shakya <adi1090x@gmail.com>

# Colors
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
CDIR=`cd "$DIR" && cd .. && pwd`
POWER_ON=`cat $CDIR/colors.ini | grep 'GREEN' | head -n1 | cut -d '=' -f2 | tr -d ' '`
POWER_OFF=`cat $CDIR/colors.ini | grep 'ALTFOREGROUND' | head -n1 | cut -d '=' -f2 | tr -d ' '`

# Checks if bluetooth controller is powered on
power_on() {
    if bluetoothctl show | grep -q "Powered: yes"; then
        return 0
    else
        return 1
    fi
}

# Checks if a device is connected
device_connected() {
    device_info=$(bluetoothctl info "$1")
    if echo "$device_info" | grep -q "Connected: yes"; then
        return 0
    else
        return 1
    fi
}

# Prints a short string with the current bluetooth status
# Useful for status bars like polybar, etc.
print_status() {
    if power_on; then
		if [[ -z `bluetoothctl info "$device" | grep "Alias" | cut -d ' ' -f 2-` ]]; then
			echo "%{F$POWER_ON}󰂯 %{F-}Power: on"
		fi
		
        paired_devices_cmd="devices Paired"
        # Check if an outdated version of bluetoothctl is used to preserve backwards compatibility
        if (( $(echo "$(bluetoothctl version | cut -d ' ' -f 2) < 5.65" | bc -l) )); then
            paired_devices_cmd="paired-devices"
        fi

        mapfile -t paired_devices < <(bluetoothctl $paired_devices_cmd | grep Device | cut -d ' ' -f 2)
        counter=0

        for device in "${paired_devices[@]}"; do
            if device_connected "$device"; then
                device_alias=$(bluetoothctl info "$device" | grep "Alias" | cut -d ' ' -f 2-)

                if [ $counter -gt 0 ]; then
                    echo "%{F$POWER_ON}󰂱 %{F-}$device_alias"
                else
                    echo "%{F$POWER_ON}󰂱 %{F-}$device_alias"
                fi

                ((counter++))
            fi
        done
    else
        echo "%{F$POWER_OFF}󰂲 Power: off%{F-}"
    fi
}

# Print Status
print_status
