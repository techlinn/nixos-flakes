# Installing NixOS next to Windows (step by step)

Written for someone new to Linux. Do the steps in order.

## Before you start (in Windows)

1. Push or copy any project you still need. Keep your SSH/GPG keys somewhere safe.
2. Check **Settings > Privacy & security > Device encryption** is off. If it is on, save the recovery key first.
3. Shut Windows down fully (Start > Shut down), not just restart.

## 1. Make the USB

1. Download the **NixOS 26.05 Graphical ISO (64-bit Intel/AMD)** from https://nixos.org/download (scroll to the NixOS section, not the Nix one at the top). In its boot menu you pick the GNOME desktop.
2. Install **Ventoy** (https://www.ventoy.net) on a USB stick (8 GB or more). Then just drag files onto it.
3. Copy two things onto the stick: the ISO, and **this whole `Flakes` folder**.

## 2. Boot the USB

1. Restart and press the BIOS key (often **Del**) and turn **Secure Boot off**. Save and exit.
2. Restart again and open the boot menu (often **F11** or **F12**), pick the USB, then the NixOS ISO.
3. If the screen goes black, restart, press **e** on the boot entry, add `nomodeset` to the end of the line that starts with `linux`, and boot it.
4. Choose "Try NixOS" if asked. You get a desktop. Ethernet works automatically.

## 3. Make room (GParted)

1. Open **GParted** and pick your NVMe disk at the top right.
2. Right-click the big NTFS partition (about 928 GB, your Windows C:) > **Resize/Move**.
3. Set **Free space following (MiB)** to `440000`. Click Resize/Move, then the green tick to apply. This gives NixOS about 430 GB.
4. Right-click the new **unallocated** space > **New**. File system **ext4**, Label **NIXOS**. Click Add, then the green tick.

Do not touch the other small partitions.

## 4. Install

1. In the file manager open the USB's `Flakes` folder, right-click an empty spot > **Open in Terminal**.
2. Run:

   ```
   sudo bash install-from-iso.sh
   ```

3. Answer `yes` when it shows your NIXOS partition. It finds the Windows boot partition by itself.
4. Wait. It downloads a lot (the pentest tools make it bigger, expect 1 to 2 hours). If it stops with a network error, run the same command again.
5. When asked, type a password for `techh` (you won't see it as you type).
6. At the end type `reboot` and unplug the USB.

## 5. First boot

1. You see a boot menu with NixOS and Windows (5 seconds). Pick either.
2. The login screen lists sessions. Choose **Hyprland**. **GNOME** is the plain desktop if Hyprland misbehaves.
3. Log in as `techh`.

Hyprland basics (these use ALT, not the Windows key):

| Keys | Does |
| --- | --- |
| `CTRL + ENTER` | Terminal |
| `CTRL + SPACE` | App launcher |
| `ALT + F` | Browser (Zen) |
| `ALT + SHIFT + Q` | Close window |
| `ALT + S` | Theme and settings menu |
| `ALT + 1` to `9` | Switch workspace |

## Later

- Your config lives in `~/Flakes`. Machine settings are in `~/Flakes/hosts/tower/default.nix`.
- After editing it, apply changes with: `upd`
- The full pentest toolset is included. To remove it, set `hacking = false;` in that file and run `upd`.
- `update` upgrades everything.
- If Windows is missing from the boot menu, run `upd` once more. You can always pick Windows from the BIOS boot menu (F11/F12).
- If a change breaks the system, choose an older entry from the boot menu (it keeps the last 5).
