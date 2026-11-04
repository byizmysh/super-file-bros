#!/bin/sh
cd -- "$(dirname -- "$0")/../.." || exit 1
# A file manager can start a shell script without attaching a console.
if [ ! -t 0 ] && [ -n "${DISPLAY:-}${WAYLAND_DISPLAY:-}" ] && [ "${SFB_TERMINAL:-}" != 1 ]; then
  SFB_TERMINAL=1; export SFB_TERMINAL
  if command -v x-terminal-emulator >/dev/null 2>&1; then exec x-terminal-emulator -e sh "$PWD/tools/fs-rpc-browser/console.sh" "$@"
  elif command -v konsole >/dev/null 2>&1; then exec konsole --nofork -e sh "$PWD/tools/fs-rpc-browser/console.sh" "$@"
  elif command -v gnome-terminal >/dev/null 2>&1; then exec gnome-terminal --wait -- sh "$PWD/tools/fs-rpc-browser/console.sh" "$@"
  elif command -v xfce4-terminal >/dev/null 2>&1; then exec xfce4-terminal --disable-server --execute sh "$PWD/tools/fs-rpc-browser/console.sh" "$@"
  elif command -v xterm >/dev/null 2>&1; then exec xterm -e sh "$PWD/tools/fs-rpc-browser/console.sh" "$@"
  else printf '%s\n' 'Open a terminal in this folder and run: sh start.sh' >&2; exit 1
  fi
fi
sh tools/fs-rpc-browser/bootstrap.sh "$@"
result=$?
if [ "$result" -ne 0 ] && [ -t 0 ]; then printf '\nPress Enter to close...'; read -r answer; fi
exit "$result"
