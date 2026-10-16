#!/usr/bin/env bash
# Fullscreen Alacritty on a bare TTY via a minimal sway session (no desktop manager).
# Use instead of cage-alacritty.sh when key repeat delay/rate matter: cage hardcodes them.
set -euo pipefail

dir=$(dirname "$(readlink -f "$0")")
exec sway -c "$dir/sway/alacritty.conf"
