#!/bin/sh

COMPATIBILITYTOOLS_DIR="${HOME}/.var/app/com.valvesoftware.Steam/.steam/root/compatibilitytools.d"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/../proton-ge-manager-core.sh"
