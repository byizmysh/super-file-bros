#!/bin/sh
# Download a verified runtime only when no compatible Node.js is available.
set -eu
cd -- "$(dirname -- "$0")/../.."
entry=${1:-start.cjs}
if [ "$#" -gt 0 ]; then shift; fi
case "$entry" in start.cjs|tools/fs-rpc-browser/install.cjs) ;; *) printf '%s\n' 'Unknown launcher action.' >&2; exit 1 ;; esac
compatible() { "$1" -e "require('./tools/fs-rpc-browser/requirements.cjs').check()" >/dev/null 2>&1; }
printf '%s\n' 'Super File Bros. - checking dependencies...'
if command -v node >/dev/null 2>&1 && compatible "$(command -v node)"; then
    exec node "$entry" "$@"
fi
runtime="$PWD/data/runtime"
if [ -x "$runtime/node/bin/node" ] && compatible "$runtime/node/bin/node"; then
    exec "$runtime/node/bin/node" "$entry" "$@"
fi
case "$(uname -s)" in Linux) platform=linux ;; Darwin) platform=darwin ;; *) printf '%s\n' 'Automatic setup supports Linux and macOS. Install Node.js 20.20+ manually on this system.' >&2; exit 1 ;; esac
case "$(uname -m)" in x86_64|amd64) arch=x64 ;; aarch64|arm64) arch=arm64 ;; armv7l) arch=armv7l ;; ppc64le|s390x) arch=$(uname -m) ;; *) printf '%s\n' 'Unsupported CPU. Install Node.js 20.20+ for this architecture manually.' >&2; exit 1 ;; esac
target="$platform-$arch"
if [ "$target" = linux-x64 ] && { [ -f /etc/alpine-release ] || (ldd --version 2>&1 || :) | grep -qi musl; }; then target=linux-x64-musl; fi
version= checksum=
while read -r candidate candidate_target candidate_checksum; do
    if [ "$candidate_target" = "$target" ]; then version=$candidate; checksum=$candidate_checksum; break; fi
done < tools/fs-rpc-browser/node-runtimes.tsv
if [ -z "$checksum" ]; then printf 'No automatic Node.js download for %s. Install Node.js 20.20+ manually.\n' "$target" >&2; exit 1; fi
as_root() {
    if [ "$(id -u)" = 0 ]; then "$@"
    elif command -v sudo >/dev/null 2>&1; then sudo "$@"
    else printf '%s\n' 'Setup needs download tools. Ask your administrator to install curl, ca-certificates, tar, gzip and coreutils, then retry.' >&2; return 1
    fi
}
if { ! command -v curl >/dev/null 2>&1 && ! command -v wget >/dev/null 2>&1; } || ! command -v tar >/dev/null 2>&1 || ! command -v gzip >/dev/null 2>&1 || { ! command -v sha256sum >/dev/null 2>&1 && ! command -v shasum >/dev/null 2>&1; }; then
    if [ "$platform" != linux ]; then printf '%s\n' 'The system curl, tar, gzip and shasum tools are required. Restore the missing macOS tools and retry.' >&2; exit 1; fi
    printf '%s\n' 'Installing missing download tools (curl, CA certificates, tar, gzip and SHA-256). Your system may request an administrator password.'
    if command -v apt-get >/dev/null 2>&1; then as_root apt-get update; as_root apt-get install -y curl ca-certificates tar gzip coreutils
    elif command -v dnf >/dev/null 2>&1; then as_root dnf install -y curl ca-certificates tar gzip coreutils
    elif command -v yum >/dev/null 2>&1; then as_root yum install -y curl ca-certificates tar gzip coreutils
    elif command -v pacman >/dev/null 2>&1; then as_root pacman -S --needed --noconfirm curl ca-certificates tar gzip coreutils
    elif command -v zypper >/dev/null 2>&1; then as_root zypper --non-interactive install curl ca-certificates tar gzip coreutils
    elif command -v apk >/dev/null 2>&1; then as_root apk add curl ca-certificates tar gzip coreutils
    else printf '%s\n' 'Install curl, ca-certificates, tar, gzip and coreutils using your system package manager, then retry.' >&2; exit 1
    fi
fi
mkdir -p "$runtime"
lock="$runtime/.install-lock"
attempt=0
until mkdir "$lock" 2>/dev/null; do
    if [ "$attempt" = 0 ]; then printf '%s\n' 'Waiting for another first-run setup to finish...'; fi
    attempt=$((attempt + 1))
    if [ "$attempt" -ge 300 ]; then printf '%s\n' 'Setup is still locked. Close other launchers; if none are running, remove data/runtime/.install-lock and retry.' >&2; exit 1; fi
    sleep 1
done
work=
cleanup() { if [ -n "$work" ]; then rm -rf "$work"; fi; rmdir "$lock" 2>/dev/null || :; }
trap cleanup 0
trap 'exit 130' INT
trap 'exit 143' TERM
if [ ! -x "$runtime/node/bin/node" ] || ! compatible "$runtime/node/bin/node"; then
    work=$(mktemp -d "$runtime/.setup.XXXXXX")
    name="node-v$version-$target"
    url="https://nodejs.org/dist/v$version/$name.tar.gz"
    printf 'Node.js is missing or too old. Downloading Node.js %s for %s from nodejs.org...\n' "$version" "$target"
    if command -v curl >/dev/null 2>&1; then
        curl --fail --location --retry 2 --connect-timeout 20 --max-time 300 --proto '=https' --tlsv1.2 --output "$work/node.tar.gz" "$url"
    else
        wget --https-only --timeout=30 --tries=3 -O "$work/node.tar.gz" "$url"
    fi
    if command -v sha256sum >/dev/null 2>&1; then digest=$(sha256sum "$work/node.tar.gz"); else digest=$(shasum -a 256 "$work/node.tar.gz"); fi
    if [ "${digest%% *}" != "$checksum" ]; then printf '%s\n' 'Node.js checksum mismatch. The download was discarded. Retry or install Node.js from its official website.' >&2; exit 1; fi
    tar -xzf "$work/node.tar.gz" -C "$work" "$name/bin/node" "$name/LICENSE"
    if ! compatible "$work/$name/bin/node"; then
        printf '%s\n' 'The downloaded Node.js cannot run on this OS. Install a compatible Node.js 20.20+ using your system package manager, then retry.' >&2
        exit 1
    fi
    rm -rf "$runtime/node"
    mv "$work/$name" "$runtime/node"
    printf 'Node.js installed in %s/node. Future launches reuse it.\n' "$runtime"
fi
cleanup
trap - 0 INT TERM
exec "$runtime/node/bin/node" "$entry" "$@"
