#!/bin/bash

kitty --server & sleep 0.5  # Start kitty server if not already running
kitty --title ncmpcpp -e ncmpcpp
