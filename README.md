# Super File Bros.

**A file manager for Nintendo Switch 2.** Browse your console and SD card, download files and ZIP folders, manage SD files, and open a read-only FTP export in your preferred file manager. Supports **SmileBASIC 4 RPC** and **experimental Civilization VII RPC**. [IZ2S Platform](https://github.com/byizmysh/IZ2S-Platform) is also supported; Super File Bros. is built into **IZ2S Platform starting with version 0.2.1**.

**Standalone application.** Super File Bros. has its own launcher, connection settings and version. IZ2S Platform is optional; this package runs without its panel, modules or services.

[Safety notice](DISCLAIMER.md) · [Release notes](RELEASE_NOTES.md)

> **Use with caution.** Modifying, corrupting or deleting files can have unexpected consequences, including consequences that appear later. You may lose screenshots, installed content, saves or access to software. Back up important data first. Folder deletion is permanent and includes its contents. You are responsible for the operations you choose; the software is provided without warranty.

## Compatibility

Super File Bros. connects to a **verified, retained FS RPC session**. Connection options and availability:

| Launcher | Required launch mode | Instructions |
| --- | --- | --- |
| [BermTheSequel/ns2jb2](https://gitlab.com/BermTheSequel/ns2jb2) | `node run.cjs --rpc` | Follow that project's current setup and console requirements. |
| [kurumuz/ns2jb](https://gitlab.com/kurumuz/ns2jb) | `node run.cjs --rpc` | Follow that project's current setup and console requirements. |
| [IZ2S Platform](https://github.com/byizmysh/IZ2S-Platform) | Active retained FS RPC session | Super File Bros. is built in starting with IZ2S Platform 0.2.1. Follow the platform's connection instructions. |

The application checks the run folder, matching session proof and live FS endpoint before connecting. An old run folder, GPU mode, native RPC alone, or a normal run that has already closed its endpoint is insufficient. Compatibility depends on the upstream run format and a successful live session, not just the repository name.

[IZ2S Platform](https://github.com/byizmysh/IZ2S-Platform) includes a panel-integrated edition starting with **version 0.2.1**, opening as a workspace tab. This repository distributes the independent application. Its manual connection form remains available regardless of where the qualified session was created.

## Requirements

- A PC running Windows, macOS or Linux and a current browser.
- [Node.js](https://nodejs.org/) **20.20 or newer; 22+ recommended**. The launch scripts reuse a compatible installed version, or automatically download and install Node.js locally on first launch. The selected upstream launcher has its own requirements.
- One of the launchers above, running on the **same PC**, with its complete held run folder available locally.
- A reachable console IPv4 address on your local network.
- Optional: an FTP-capable file manager such as FileZilla or Dolphin.

No `npm install`, Python or compiler is required to run this manager. Initial dependency setup needs Internet access if Node.js is missing. Node.js is installed under `data/runtime/node/` without administrator privileges; minimal Linux systems may ask for an administrator password to install missing download tools. Required upstream files are read from your existing run folder; do not copy only its JSON files.

## Installation: download, extract, launch

1. Download the archive for your operating system from the GitHub release assets:

   | System | Archive |
   | --- | --- |
   | Windows | `super-file-bros-0.2.0-windows.zip` |
   | macOS | `super-file-bros-0.2.0-macos.zip` |
   | Linux | `super-file-bros-0.2.0-linux.tar.gz` |

   Each package includes the matching launchers, a platform-specific **START_HERE.md**, and complete instructions. No Node.js binary is bundled in the archive. The launchers check dependencies in a console and download the official runtime for your OS and CPU only when needed. Downloads are checked against pinned SHA-256 checksums before installation.
2. Extract the **entire** archive to a folder you can write to. Do not start it inside the archive. Keep the folder's contents together.
3. Start the application using the script below. Leave its console open while first-run setup completes; the manager starts automatically afterward:

| OS | Start | Optional shortcut |
| --- | --- | --- |
| Windows | Double-click **Start Windows.cmd** | Run **Install Windows.cmd**; creates a Start menu shortcut for your user. |
| macOS | Double-click **Start macOS.command** | Run **Install macOS.command**; creates `~/Applications/Super File Bros.app`. |
| Linux | Open **Start Linux.desktop** (allow launching if asked), or run **`sh start.sh`** from the extracted folder | Run **`sh "Install shortcut.sh"`**; creates an application-menu entry. |

If macOS/Linux reports that a script is not executable, use `sh "Start macOS.command"` or `sh start.sh` in a terminal. If the OS blocks an unsigned script, use the terminal commands after reviewing the source and follow your OS's normal security guidance.

The optional installers run the same dependency checks, then create a shortcut for your user. Shortcuts open the launch script in a console and reuse its first-run setup. Keep this portable folder in place after creating a shortcut; rerun the installer if you move it. They do not change the original RPC launcher.

Setup reuses a compatible Node.js on PATH, otherwise it checks its local installation before downloading anything. Subsequent launches work without a download. A failed or interrupted download is discarded and can be retried by reopening the script. On Linux, missing curl/wget, CA certificates, tar, gzip or SHA-256 tools are installed through an available system package manager; the OS may request your administrator password. The automatic runtime download supports common Linux architectures, Intel/Apple Silicon macOS, and x64/ARM64/x86 Windows. If the runtime cannot run on your OS, install a compatible Node.js manually and retry.

This setup covers the manager. Follow the separate ns2jb2/ns2jb instructions to prepare the console connection.

If you already have a compatible Node.js on PATH, the universal alternative is:

```sh
node start.cjs
```

## First connection, step by step

1. Have an active FS RPC connection from **ns2jb2** or **ns2jb** in `--rpc` mode, or through **IZ2S Platform**, and leave that connection application running. Refer to the selected project's own connection instructions. SmileBASIC 4 RPC is supported; Civilization VII RPC support is experimental.
2. Start Super File Bros. Its local page opens automatically. If it does not, use the private link printed in its terminal.
3. The manager revalidates saved settings and searches nearby **ns2jb2/ns2jb** folders for active `runs/switch2-*` sessions. The detected path is filled into Connection settings. **Detect session** repeats this search.
4. Enter **Console IPv4** if it has not been saved. If your session is stored elsewhere, enter the full **Held FS run folder** manually, for example `/path/to/ns2jb2/runs/switch2-ABC123`, then click **Connect**. Select the complete current session folder, not the repository root.
5. Choose **Installed games** or **SD & console storage** and wait for **ready**.

Automatic detection searches near the application folder and the previously selected location, not the entire disk or LAN. A valid saved folder takes priority; otherwise the newest active nearby session is selected. The console IP may need to be entered on first connection.

You can supply both values directly instead of filling the form:

```sh
node start.cjs --run "/absolute/path/to/ns2jb2/runs/switch2-ABC123" --host 192.168.1.20
```

On Windows, for example:

```powershell
.\"Start Windows.cmd" --run "C:\Tools\ns2jb\runs\switch2-ABC123" --host 192.168.1.20
```

`--no-open` prints the local URL without opening a browser. `--help` prints the command syntax. The private URL key controls this local tool: do not publish it or share your live run folder. An IP alone cannot replace the run folder or retained FS handles. After restarting the console, establish a new session and select its new run folder.

## What you can do

### Installed games

The list identifies **Console storage**, **SD card** or **Game card**. Multiple reported locations are shown together. Select **Connect** beside a game to prepare its accessible decoded content using OunceCake. Large games can take several minutes. Select **Open in file manager** once ready, or use the displayed FTP address in your own client. One export is active at a time.

### SD & console storage

Click **Start storage FTP**. Open folders under `/sd`, `/system` and `/user`; only mounts opened by your current session are shown. Directory contents are loaded as you browse. Raw storage mode shows on-disk files; the separate game mode exposes decoded game content. Raw partition access and general save decryption are not provided.

| Action | SD browser | Internal console browser | FTP / decoded game export |
| --- | --- | --- | --- |
| Browse and download | Yes | Yes, when accessible | Yes, read-only |
| Download folder as ZIP | Yes | Yes | Through the browser's storage view only |
| Upload files/folders | Yes | No | No |
| Create folder, rename, delete | Yes | No | No |

**Downloads:** use **Download**, **Download ZIP**, or the toolbar **Download** button (current folder ZIP). Files go to the browser's chosen download location. The **Downloads** section shows transferred bytes and cancellation. Folders stream as uncompressed ZIP64 archives with nested and empty directories; file contents are not buffered as a complete archive. A disconnected download cannot resume: restart it and discard the partial file.

**Navigation:** use **Back** and **Forward** for visited folders, **Up** for the parent folder, or click a breadcrumb such as **Storage › sd**. Up is disabled at the storage root. The selected file view and folder are restored when the page reloads.

**Uploads:** inside `/sd`, open **Upload** and select **Upload files** or **Upload folder**. Progress and **Cancel upload** appear in the panel. Existing names are rejected rather than overwritten. A file is written in 32 KiB chunks to a temporary file, verified in the console buffer, flushed, then renamed into place after completion. Cancelling removes the current incomplete file; files already completed and folders already created remain. Browser folder uploads preserve supplied relative paths; use **New folder** for empty folders.

**Rename and delete:** use the buttons beside an SD entry. Rename cannot replace an existing destination. **Delete permanently** requires confirmation and recursively deletes folder contents. Mounted roots and internal console partitions cannot be changed through these controls. Read the safety notice before editing files, especially inside `Nintendo`.

**Keep both applications running** until transfers finish. Do not launch competing exports of the same console services. Changing the selected game/mode or disconnecting an export is blocked while a browser transfer is active. These are not transactional backups and do not guarantee recovery from network failure or console crashes.

## File manager / FTP setup

Select a file manager and click **Open in file manager**. Choose a manager explicitly. Presets include Windows File Explorer, Finder, FileZilla, Dolphin, Nautilus, Nemo, Thunar and the system FTP handler where applicable. Windows File Explorer and Finder use the read-only FTP export, not a mounted writable drive; availability depends on OS FTP support. If the system handler cannot open FTP, use FileZilla or **Copy FTP address**. A manager opens on the computer running Super File Bros., not on a second computer viewing its page. A custom executable path is also supported; provide an executable, not a shell command.

Use the exact console address and port shown in the panel, **anonymous login**, **passive mode**, and **one simultaneous connection**. Ports rotate within **2122–2199** when exports restart; do not assume a fixed port. FTP itself remains read-only; use the browser's SD controls for uploads, rename and delete. A browser alone may not open `ftp://` links. FTP is unencrypted and anonymous: use a trusted local network, avoid port forwarding and stop the export when finished.

## Stopping, upgrading and uninstalling

Finish or cancel transfers, then click **Disconnect export**. Close the manager with **Ctrl+C** in its terminal. Close the original RPC launcher only after all manager operations have finished; follow its cleanup instructions.

For upgrades, stop the old instance and extract the new version into a new folder. You may copy its `data/state/fs-rpc-browser/connection.json` locally to preserve preferences; saved session details still need to be valid. Never include `data/` in a public repository or release. Rerun the optional shortcut installer to point to the new folder. Remove the old folder only after preserving anything you need.

To uninstall, stop the manager, remove its portable folder and delete its optional shortcut: the Windows Start menu entry, `~/Applications/Super File Bros.app` on macOS, or `super-file-bros.desktop` under your Linux user application directory. Your console data is separate from the manager installation.

## Troubleshooting

| Symptom | What to check |
| --- | --- |
| Dependency setup failed | Check the console error and Internet access, then reopen the launch script. Alternatively install Node.js 20.20+ manually. A checksum mismatch discards the download. |
| Linux double-click opens a text editor | Use **Start Linux.desktop**, allowing launch if asked, or open a terminal in this folder and run `sh start.sh`. |
| No active session detected | Use Connection settings with the exact current run folder and console IPv4. First-time upstream runs may need manual selection; auto-detection does not scan the LAN or all folders on disk. |
| Run folder is not qualified | The launcher must finish its held FS checks with `--rpc`; a regular completed run or native/GPU-only connection cannot be upgraded by this manager. |
| Service busy / not responding | Wait for preparation or a transfer. Check the original launcher and console, then retry. Do not replay uncertain native operations. If the session ended, start a new qualified run. |
| FTP is unreachable | Check console IP, local routing/firewall, the current port and the active upstream session. Allow only the required local-network traffic; do not disable the firewall globally. |
| File manager did not open | Install an FTP-capable client or set its exact executable path. FileZilla is an alternative when the system handler has no FTP support. |
| Upload or rename reports an existing name | Choose a new name. The tool intentionally does not overwrite existing entries. |
| Partial upload after a crash | Cancel through the still-running manager when possible. Abandoned uploads expire while the service is alive; after a terminated service, a `.ns2-upload-*.part` file may need manual cleanup. Inspect the path first. |
| Internal folder is unavailable | The current session could not open that mount; this is not resolved by enabling SD write controls. |

## Privacy and security

The web UI listens only on `127.0.0.1` and uses a private access key. There is no cloud account, telemetry or remote control service. Settings and local export metadata are written under `data/`. Console FTP is a separate network service with the limitations above. A local private UI does not make anonymous FTP safe on an untrusted network.

## Credits and license

GPL-2.0-only; see [LICENSE](LICENSE) and [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md). Unmodified [OunceCake](https://github.com/misshexa66/OunceCake), revision `6fcf9e80d302ff43c96dd5d912c9b08a11913daf`, supplies decoded game exports and its console payload. Its license, payload source and build files are included. The connection projects are separate projects; their current instructions and requirements remain authoritative. Use only content and consoles you are authorized to access. No Nintendo branding or game assets are included.
