# Super File Bros. 0.2.0

English-only platform release for **Super File Bros.**. A file manager for Nintendo Switch 2, using an existing qualified held FS RPC run from [ns2jb2](https://gitlab.com/BermTheSequel/ns2jb2) or [ns2jb](https://gitlab.com/kurumuz/ns2jb).

## Changes in 0.2.0

- Compact folder toolbar, Back/Forward/Up history and clickable breadcrumbs.
- Upload dropdown, keyboard-accessible file views, better narrow-screen dialogs and clearer busy/error states.
- Explicit file-manager selection, required custom paths, Windows File Explorer/Finder presets and Copy FTP address.
- Session health checks invalidate stale exports after a disconnected or replaced endpoint.
- Standalone automatic discovery and manual run-folder/IP connection are preserved. No IZ2S runtime is required.
- Separate GitHub-ready source archive alongside platform packages.
- First-run dependency setup in a visible console on Windows, macOS and Linux. Compatible Node.js installations are reused; otherwise the official runtime is downloaded, verified and installed locally. No Node.js binary is bundled in the release archives.

## Included

- Installed game list with console/SD/game-card locations and decoded read-only game exports through OunceCake.
- Direct browsing of accessible SD and internal console filesystems.
- Browser downloads of files and streaming ZIP64 folders, progress and cancellation.
- SD uploads of files/folders, new folders, rename and confirmed permanent deletion; existing names are not overwritten.
- Optional file-manager launch with the displayed read-only FTP URL.
- Separate Windows, macOS and Linux packages with matching launchers, optional user-level shortcuts, English-only setup guides and dependency checks.
- Source, third-party notices, SHA-256 manifest and automated build workflow.

## Before starting

Extract the entire asset and open its OS launch script. The console automatically installs Node.js locally if a compatible version is missing; Internet is required for this initial setup. Establish `node run.cjs --rpc` with your chosen upstream launcher, and leave it running. The session folder is detected from saved settings or nearby ns2jb2/ns2jb runs. Enter the console IPv4 if needed; a manual folder selection remains available. Read README.md for complete steps.

## Installation by platform

Download the matching package below and extract the **entire archive** to a writable folder. Open the extracted `super-file-bros` folder and start its script. A console checks dependencies and installs Node.js locally if a compatible version is missing. **No manual Node.js installation is required.** Initial setup needs Internet access; later launches reuse the installed runtime. Node.js is not bundled in the archive.

| Version | Download | Start | Optional shortcut |
| --- | --- | --- | --- |
| Windows | [Windows ZIP](https://github.com/byizmysh/super-file-bros/releases/download/v0.2.0/super-file-bros-0.2.0-windows.zip) | Double-click **Start Windows.cmd**. | Run **Install Windows.cmd** to add a Start menu shortcut. |
| macOS | [macOS ZIP](https://github.com/byizmysh/super-file-bros/releases/download/v0.2.0/super-file-bros-0.2.0-macos.zip) | Double-click **Start macOS.command**, or run `sh "Start macOS.command"` in Terminal. | Run **Install macOS.command** to add the app shortcut to your user Applications folder. |
| Linux | [Linux tar.gz](https://github.com/byizmysh/super-file-bros/releases/download/v0.2.0/super-file-bros-0.2.0-linux.tar.gz) | Open **Start Linux.desktop** (allow launching if asked), or run `sh start.sh` in the extracted folder. | Run `sh "Install shortcut.sh"` to add an application-menu shortcut. |
| Source / all platforms | [Source ZIP](https://github.com/byizmysh/super-file-bros/releases/download/v0.2.0/super-file-bros-0.2.0-source.zip) | Use the matching OS launcher above; all are included. `node start.cjs` also works if Node.js is already on PATH. | Use the matching installer above. |

The optional installers perform the same dependency check, then create user shortcuts; keep the extracted folder in place. Node.js is downloaded from nodejs.org, verified against a pinned SHA-256 checksum and stored under `data/runtime/node/`. No `npm install` or compilation is needed. Minimal Linux systems may request an administrator password to install missing download tools through the system package manager. Keep your verified upstream `--rpc` session running. When the browser opens, confirm the detected **Held FS run folder**, enter **Console IPv4** if needed, and click **Connect**.

## Limitations

SD writes are available through the browser. Internal mounts, decoded game exports and FTP remain read-only. Only one active export is supported. Transfers require the original session and console to remain available. Downloads cannot resume after disconnection. Browser folder uploads do not enumerate empty directories. Current upstream requirements still apply.

## Safety disclaimer

**Use with caution: modifying, corrupting or deleting files can have unexpected consequences, including consequences that appear later. Back up important data first. Folder deletion is permanent and recursive. The software is provided without warranty; you are responsible for the operations you choose.** Read DISCLAIMER.md before changing files.

## Assets

- `super-file-bros-0.2.0-windows.zip` — Windows launchers and source.
- `super-file-bros-0.2.0-macos.zip` — macOS launchers and source.
- `super-file-bros-0.2.0-linux.tar.gz` — Linux scripts and source, preserving executable permissions.
- `super-file-bros-0.2.0-source.zip` — GitHub-ready source, all OS launchers and workflow.
- `SHA256SUMS` — checksums for all four archives.
- `SOURCE-MANIFEST-source.json`, `SOURCE-MANIFEST-windows.json`, `SOURCE-MANIFEST-macos.json`, `SOURCE-MANIFEST-linux.json` — per-file checksums, also included inside each package as `SOURCE-MANIFEST.json`.

Each platform archive includes **START_HERE.md**, the full **README.md**, the safety notice and source. The launch scripts install Node.js on first use when needed; it is not bundled. Linux setup may request an administrator password if basic download tools are missing.
Keep private run folders, `data/`, logs and console content out of public issues and release uploads. Publish only the generated release assets.
