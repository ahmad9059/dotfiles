#!/bin/bash

# Set environment for GUI under Wayland
export DISPLAY=:0
export XDG_RUNTIME_DIR=/run/user/$(id -u)
export WAYLAND_DISPLAY=wayland-1

# Start the VM
virsh --connect=qemu:///system start debian13

# Wait for the VM to boot and SPICE to become ready
# sleep 3

# Open GUI viewer (windowed)
virt-viewer --connect=qemu:///system debian13
