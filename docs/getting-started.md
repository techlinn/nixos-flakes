# Getting started

## Requirements

- An existing NixOS install (the installer creates the host config for you).
- A user with `sudo` access.
- Network access to fetch the flake inputs the first time.

## Install

From the flake directory:

```bash
./install.sh switch
```

The installer:

1. Detects your user, host name, time zone and hardware.
2. Creates `hosts/<host>/` from the `nixos` template if it does not exist.
3. Collects garbage (skippable) and runs `nixos-rebuild` with the flake.

### Installer actions

| Action | What it does |
| --- | --- |
| `switch` | Build and activate, persistent (default) |
| `test` | Build and activate for this boot only |
| `boot` | Build and set as the default for the next boot |
| `build` | Build only, do not activate |
| `dry-activate` | Build and show what would change, do not activate |

### Installer options

| Option | Meaning |
| --- | --- |
| `-H`, `--host HOST` | Flake host to build (default: short hostname) |
| `-n`, `--no-gc` | Skip garbage collection before rebuilding |
| `-v`, `--verbose` | Stream all output (default is quiet) |
| `-- EXTRA...` | Extra arguments passed to `nixos-rebuild` |

Examples:

```bash
./install.sh build
./install.sh test -H myhost
./install.sh switch --verbose
./install.sh switch -- --show-trace
```

## Moving to another machine

Copy the whole `Flakes` folder to `~/Flakes` on the new machine (a USB stick, or
a private git repository) and run `./install.sh switch` there once. After that,
`upd` works as usual.

What comes with the folder, and so is the same everywhere:

- Every program, the keys, the bar, Alt+Tab, all 30 themes and 26 wallpapers,
  the theme switcher (including Discord, OBS and Zen), the microphone gate, the
  patched GitHub Desktop, and the exact package versions (`flake.lock`).
- The look you start with: the City Lights theme, the capsule bar, 88 %
  transparency. These are only the starting values on a machine where nothing
  has been chosen yet; `ALT + S` changes them as always.
- Discord's theme switch (QuickCSS) and plugin list, seeded once into Equibop's
  settings.
- Mullvad VPN (installed, started at boot, the firewall and kernel settings it
  needs, connect-at-boot), the AI coding tools, and the libraries that downloaded Linux
  programs such as IDA Pro need (`programs.nix-ld`).

What the installer works out for the new machine, in `hosts/<its name>/`:

- Your user name, the host name, the time zone, the disks and the boot loader.
- An NVIDIA card, if there is one (`nvidia.nix`).
- Nothing about this machine's two monitors or its headset is carried over.
  Monitors use their own best mode. For a fixed layout add
  `pwnbox.desktop.monitors` to the host file (see `hosts/nix/default.nix`),
  and for a headset rule copy `hosts/nix/audio.nix` and change the names.

What is **not** in the folder, because it is personal data and not
configuration: logins (Discord, Spotify, GitHub, browser), Zen's bookmarks,
extensions and history, OBS scenes, anything in `~/Documents` or `~/Downloads`,
and licence files. Copy those separately if you want them.

Two things need you once on the new machine, because they are accounts and
licences, not configuration:

- **Mullvad:** `mullvad account login <your account number>` (see
  `docs/privacy.md`). It then connects by itself at every boot.
- **IDA Pro:** put the installer you downloaded in `~/Downloads` and run
  `ida-install` (see `docs/apps.md`). It installs it, links Python, and applies
  the theme. The licence is yours to supply; nothing here handles it.

The folder is not a git repository at the moment. If you make it one, new files
must be added with `git add` before a rebuild can see them.

## After install

Useful shell aliases (defined in `home/shell.nix`):

| Command | Does |
| --- | --- |
| `upd` | Rebuild and activate |
| `update` | Update all flake inputs, then rebuild |
| `rebuild` | Not defined by default, use `upd` |

## Host configuration

The generated `hosts/<host>/default.nix` is the single place to tune the
machine. Common options:

```nix
pwnbox = {
  hostName = "myhost";
  timeZone = "Europe/Berlin";
  username = "pwnbox";

  desktop = {
    enable = true;
    resolution = "2560x1440@144";
    accessibility = false;
  };

  vpn.mullvad = true;   # Mullvad VPN (see docs/privacy.md)

  virtualisation = {
    docker = true;
    dockerOnBoot = false;
    libvirtd = true;
    wireshark = true;
  };

  packages = {
    hacking = true;
    gaming = false;
    creative = false;
  };
};
```

Every option is documented in `system/options.nix`.

## Wallpapers

Wallpapers live in the flake at `dotfiles/gnome/wallpapers/` and are linked
read-only to `~/.local/share/pwnbox/wallpapers`. Add an image there and rebuild,
then pick it from `ALT + S → Pywal`.

## Recovery

If a build breaks the system, boot an older generation from the boot menu and
rebuild. You can also activate a previous configuration with:

```bash
sudo /nix/var/nix/profiles/system-<n>-link/bin/switch-to-configuration switch
```

The installer writes its full log to `/tmp/pwnbox-install.log`.
