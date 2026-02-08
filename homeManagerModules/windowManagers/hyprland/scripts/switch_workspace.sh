#!/usr/bin/env bash

KEY="$1"
STATE="$2"
TMPDIR="/tmp/hypr-hold-ws"
THRESHOLD_MS=500

mkdir -p "$TMPDIR"

now_ms() {
    date +%s%3N
}

if [ "$STATE" = "press" ]; then
    now_ms > "$TMPDIR/$KEY"
elif [ "$STATE" = "release" ]; then
    if [ -f "$TMPDIR/$KEY" ]; then
        START=$(cat "$TMPDIR/$KEY")
        NOW=$(now_ms)
        DIFF=$((NOW - START))

        if [ "$DIFF" -ge "$THRESHOLD_MS" ]; then
            hyprctl dispatch workspace "$KEY"
        fi

        rm -f "$TMPDIR/$KEY"
    fi
fi

