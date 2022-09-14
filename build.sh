#!/bin/sh

PROG='ffcol'
DESTDIR='./bin'
EXPPATH="${DESTDIR}/${PROG}"

mkdir -p "$DESTDIR"

for arg; do
    case "$arg" in
	linux)
	    godot --no-window --export 'Linux/X11' "${EXPPATH}.x86_64"
	    ;;
	windows)
	    godot --no-window --export 'Windows Desktop' "${EXPPATH}.exe"
	    ;;
    esac
done
