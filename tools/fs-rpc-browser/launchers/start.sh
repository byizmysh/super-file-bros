#!/bin/sh
cd -- "$(dirname -- "$0")" || exit 1
exec sh tools/fs-rpc-browser/console.sh start.cjs "$@"
