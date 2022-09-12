#!/bin/sh

PROG='ffcol'
DESTDIR='./bin'

mkdir -p "$DESTDIR"

EXPPATH="${DESTDIR}/${PROG}"

godot --no-window --export 'Linux/X11' "${EXPPATH}.x86_64"
#godot --no-window --export 'Windows Desktop' "${EXPPATH}.exe"
