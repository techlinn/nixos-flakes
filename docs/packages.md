# Packages

The box ships a full daily-driver app set plus 26 pentest categories. Almost
everything is toggleable from `hosts/<host>/default.nix`.

## Tooling categories

All categories are enabled by default. Disable any with
`pwnbox.packages.toolset.<category>.enable = false;`.

| Group | Category | Focus |
| --- | --- | --- |
| **Recon & Web** | `reconnaissance` | Host/port discovery, DNS, OSINT |
| | `web` | Web proxies, injection, content discovery |
| **Exploit & AD** | `exploitation` | Exploit frameworks and databases |
| | `active-directory` | Windows / AD attack & enumeration |
| **Network & Radio** | `network` | Capture, MITM, proxying, pivoting |
| | `wireless` | Wi-Fi auditing |
| | `bluetooth` | Bluetooth / BLE |
| | `rf-sdr` | Radio / software-defined radio |
| **Hardware & Firmware** | `hardware` | Embedded, flashing, logic |
| | `firmware` | Firmware extraction & analysis |
| | `smartcards` | NFC, RFID, smart cards |
| **Reversing & Pwn** | `reverse-engineering` | Disassembly, decompilation, malware |
| | `binary-exploitation` | Pwn, debugging, ROP |
| | `fuzzing` | Fuzzers and mutation tooling |
| **Forensics & Defense** | `forensics` | Disk & memory forensics |
| | `blue-team` | Detection, monitoring, hardening |
| | `code-analysis` | SAST, secrets, dependencies |
| **Cloud & Infra** | `cloud` | AWS, Azure, GCP |
| | `containers` | Docker, Podman |
| | `kubernetes` | Kubernetes tooling |
| **Cracking & Crypto** | `password-cracking` | Hash & login cracking |
| | `cryptography` | Crypto and key tooling |
| | `wordlists` | Bundled wordlists |
| **Mobile & Comms** | `mobile` | Android / iOS |
| | `voip` | SIP |
| **Utilities** | `python` | OSINT CLI helpers |

## Optional sets

| Option | Adds |
| --- | --- |
| `pwnbox.packages.gaming` | Gaming and entertainment apps |
| `pwnbox.packages.creative` | Creative, media and office apps |
| `pwnbox.packages.hacking` | The full pentest toolset |

## Daily-driver apps

| Area | Apps |
| --- | --- |
| **Private & encrypted chat** | Signal, SimpleX, Element (Matrix), Dino (XMPP), qTox, AyuGram (Telegram), Equibop (Discord / Equicord) |
| **Browsers** | Zen (default), Chromium, Tor Browser |
| **Privacy & security** | KeePassXC, Mullvad VPN, Tor + torsocks |
| **Office & notes** | LibreOffice, Obsidian, Geary, Zathura |
| **Media & creative** | Spotify, VLC, mpv, cmus, qBittorrent, GIMP, Inkscape, Krita, OBS, Audacity, Kdenlive, Blender |
| **Terminal & system** | kitty, ranger, zsh + oh-my-zsh, tmux, btop, fastfetch, fzf, ripgrep, bat, eza, zoxide |
| **Development** | Neovim, Zed, Git, Docker / Podman, libvirt / KVM and language toolchains (C/C++, Rust, Go, Python, JVM, JS/TS, Haskell, …) |

## Adding your own packages

Put extra packages in `pkgs/custom.nix`; they are picked up automatically:

```nix
{ pkgs, ... }:
with pkgs;
[
  ripgrep-all
  ffuf
]
```

Then rebuild with `upd`.
