#!/usr/bin/env bash

FPS=30
ASCII_DIR="ascii"
AUDIO="bad_apple.ogg"

FRAME_NS=$((1000000000 / FPS))

cleanup() {
    tput cnorm
    [[ -n "$MPV_PID" ]] && kill "$MPV_PID" 2>/dev/null
    clear
}

trap cleanup EXIT INT TERM

# Hide cursor
tput civis

# Start audio
mpv --no-video --really-quiet "$AUDIO" &
MPV_PID=$!

# Small head start so MPV begins playing
sleep 0.05

START=$(date +%s%N)

i=0

for frame in "$ASCII_DIR"/*.txt; do
    TARGET=$((START + i * FRAME_NS))

    # Wait until the exact frame time
    while (( $(date +%s%N) < TARGET )); do
        sleep 0.001
    done

    # Draw frame
    printf "\033[H"
    cat "$frame"

    ((i++))
done

# Wait for MPV to finish
wait "$MPV_PID"