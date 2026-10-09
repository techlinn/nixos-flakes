# Privacy

pwnbox is built to leave as little on disk as possible. Privacy and messaging
apps are installed by default and the system is hardened.

## No logs

- `journald` is **volatile**. Logs live in RAM only (`Storage=volatile`),
  capped at 64 MB, and only warnings and above are kept.
- `/var/log` is a `tmpfs` (64 MB, `nosuid,nodev,noexec`).
- `ForwardToSyslog` / `ForwardToKMsg` / `ForwardToWall` are off and crash
  uploads are disabled.
- Core dumps are disabled (`systemd.coredump.enable = false`,
  `kernel.core_pattern = /dev/null`).
- The boot console is silenced (`quiet loglevel=0`, `consoleLogLevel = 0`).

## No plaintext on disk

- **No swap partition.** `zramSwap` only (`memoryPercent = 50`).
- **RAM-backed `/tmp`** and `/var/tmp` (`boot.tmp.useTmpfs`, `cleanOnBoot`).
- No hibernation (`nohibernate`).

## Hardened kernel & network

- Strict sysctls: `kptr_restrict=2`, `dmesg_restrict=1`,
  `perf_event_paranoid=3`, `yama.ptrace_scope=1`, `kexec_load_disabled=1`,
  `unprivileged_bpf_disabled=2`, `randomize_kstack_offset=on`, `oops=panic`.
- Memory protections: `init_on_alloc=1`, `init_on_free=1`, `slab_nomerge`,
  `page_alloc.shuffle=1`, `vsyscall=none`, `debugfs=off`.
- IOMMU forced and strict; early PCI DMA disabled.
- Network: reverse-path filtering, no source routing/redirects, syncookies,
  RFC 1337, IPv6 privacy addresses and `ip_forward` off.
- Dangerous/legacy filesystems and protocols are block-listed (`dccp`, `sctp`,
  `rds`, `tipc`, `firewire`, `thunderbolt`, `hfs`, `udf`, `can`, …).
- AppArmor, `protectKernelImage` and `forcePageTableIsolation` are on.
- `lockKernelModules` prevents loading modules at runtime.

## Services & accounts

- Firewall on; refused connections are not logged.
- No SSH, Avahi, printing, `fwupd` or geolocation.
- Root login is locked (`hashedPassword = "!"`).
- `sudo-rs`, wheel-only, always asks for a password.
- No autologin.
- Garbage collection runs daily and keeps 7 days.

## Privacy apps

Signal, SimpleX, Element (Matrix), Dino (XMPP), qTox, Tor Browser and
`tor`/`torsocks` are included.

## Mullvad VPN

On by default (`pwnbox.vpn.mullvad`, in `hosts/<name>/default.nix`). It installs
the daemon and the app and starts the daemon at boot. The flake also:

- sets the firewall's reverse-path check and the kernel's `rp_filter` to
  "loose", which VPN clients need (`hardening.nix` otherwise makes them strict);
- loads the WireGuard and nftables modules at boot, so Mullvad still works on a
  host that locks kernel modules after boot;
- applies two defaults **once** (`mullvad-defaults.service`, a marker in
  `/var/lib/pwnbox`): connect automatically at boot, and allow the local
  network, so Docker, libvirt VMs and lab networks keep working. Anything you
  change afterwards, in the app or with `mullvad`, is left alone.

The account is yours to supply. After the first rebuild:

```bash
mullvad account login <your account number>
mullvad connect            # it connects by itself at boot from now on
mullvad status
```

The kill switch is not turned on for you, because with it on and no account
nothing reaches the network. Turn it on once you are logged in:
`mullvad lockdown-mode set on`. To run one program outside the VPN (a CTF
VPN, for example): `mullvad-exclude <command>`. To remove Mullvad completely, set
`pwnbox.vpn.mullvad = false` and run `upd`.

## Filesystem hygiene

- `/etc/nixos` on the installed machine only holds the hardware config and a
  pointer back to this flake.
- Shell history is not persisted (`HISTFILE=/dev/null`).
- `remember-recent-files` is off; old trash and temp files are removed.
- `zramSwap` means secrets in memory are never written to a swap device.
