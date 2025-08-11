#!/bin/bash

PROFILE_BALANCED="balanced"
PROFILE_VIRTUAL="virtual-host"

notify() {
    local message="$1"
    local urgency="${2:-normal}"
    notify-send -u "$urgency" "Tuned Profile Switch" "$message"
}

# Check tuned service
if ! systemctl is-active --quiet tuned; then
    notify "Tuned service not running. Starting..." "low"
    if sudo systemctl start tuned; then
        sleep 1
        if systemctl is-active --quiet tuned; then
            notify "Tuned service started successfully." "normal"
        else
            notify "Failed to start tuned service." "critical"
            exit 1
        fi
    else
        notify "Permission denied to start tuned service." "critical"
        exit 1
    fi
fi

CURRENT_PROFILE=$(tuned-adm active | grep "Current active profile:" | awk '{print $NF}')

if [[ "$CURRENT_PROFILE" == "$PROFILE_BALANCED" ]]; then
    if tuned-adm profile "$PROFILE_VIRTUAL"; then
        notify "Switched to $PROFILE_VIRTUAL successfully." "normal"
    else
        notify "Failed to switch to $PROFILE_VIRTUAL." "critical"
    fi
elif [[ "$CURRENT_PROFILE" == "$PROFILE_VIRTUAL" ]]; then
    if tuned-adm profile "$PROFILE_BALANCED"; then
        notify "Switched to $PROFILE_BALANCED successfully." "normal"
    else
        notify "Failed to switch to $PROFILE_BALANCED." "critical"
    fi
else
    notify "Unknown profile: $CURRENT_PROFILE" "critical"
fi
