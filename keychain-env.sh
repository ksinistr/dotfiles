#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "usage: keychain-env add NAME | fix" >&2
  exit 1
}

names() {
  security dump-keychain 2>/dev/null | sed -n 's/^ *"svce"<blob>="env\/\([A-Za-z_][A-Za-z0-9_]*\)"$/\1/p'
}

add() {
  local name=$1
  [[ $name =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]] || { echo "invalid name: $name" >&2; exit 1; }
  security add-generic-password -U -a "env/$name" -s "env/$name" -w
  echo "saved env/$name, open a new shell to load it"
}

fix() {
  local name
  for name in $(names); do
    echo "env/$name"
    security set-generic-password-partition-list -S apple-tool:,apple: -s "env/$name" >/dev/null
  done
}

case "${1:-}" in
  add) [[ $# -eq 2 ]] || usage; add "$2" ;;
  fix) [[ $# -eq 1 ]] || usage; fix ;;
  *) usage ;;
esac
