# System hardening — one file per concern. To soften one area, open its file
# or delete its line from the imports list below.
{ ... }:
{
  imports = [
    ./logging.nix    # journald volatile + /var/log tmpfs + no coredumps
    ./kernel.nix     # kernel params + blacklisted modules + apparmor
    ./sysctl.nix     # info-leak + fs + memory sysctls
    ./network.nix    # network sysctls + firewall
    ./services.nix   # disable avahi/printing/ssh/geoclue + lock root
    ./sudo.nix       # sudo-rs: wheel-only, password required
  ];
}

