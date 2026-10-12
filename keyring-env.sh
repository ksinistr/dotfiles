#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "usage: keyring-env add NAME | ls" >&2
  exit 1
}

names() {
  secret-tool search --all service env 2>&1 >/dev/null | sed -n 's/^attribute\.name = \([A-Za-z_][A-Za-z0-9_]*\)$/\1/p'
}

add() {
  local name=$1
  [[ $name =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]] || { echo "invalid name: $name" >&2; exit 1; }
  secret-tool store --label="env/$name" service env name "$name"
  echo "saved env/$name, open a new shell to load it"
}

case "${1:-}" in
  add) [[ $# -eq 2 ]] || usage; add "$2" ;;
  ls) [[ $# -eq 1 ]] || usage; names ;;
  *) usage ;;
esac
