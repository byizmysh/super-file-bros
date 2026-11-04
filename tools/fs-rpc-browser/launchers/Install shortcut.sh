#!/bin/sh
set -eu
cd -- "$(dirname -- "$0")"
exec sh tools/fs-rpc-browser/console.sh tools/fs-rpc-browser/install.cjs
