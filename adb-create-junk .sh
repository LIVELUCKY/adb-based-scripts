#!/bin/bash

# Script to overwrite free space on an Android device to ensure data is unrecoverable.
# Usage: ./adb-create-junk.sh [initial_size_MB] [min_size_MB] [stop_size_MB]
# Default: If no arguments are provided, the script will use 32768 MB as the initial size, 1 MB as the minimum size, and will fill the whole device.

initial_size=${1:-32768} 
min_size=${2:-1}  
stop_size=${3:-0}  # Stop size set to 0MB by default.

while [[ $initial_size -ge $min_size ]]; do
    while adb shell "dd if=/dev/urandom of=\$(mktemp) bs=1M count=$initial_size 2>/dev/null"; do
        echo "Created junk file of size $initial_size MB"
    done
    echo "Failed to create junk file of size $initial_size MB, halving size"
    initial_size=$((initial_size / 2))
    available_space=$(adb shell "df \$(dirname \$(mktemp)) | awk 'NR==2{print $4}'")
    if [[ $available_space -lt $initial_size ]]; then
        initial_size=$available_space
    fi
    if [[ $available_space -le $stop_size ]]; then
        break
    fi
done
