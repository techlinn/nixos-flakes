# Mullvad VPN daemon + GUI. Toggle with pwnbox.vpn.mullvad.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  enabled = config.pwnbox.vpn.mullvad;
  mullvad = lib.getExe' config.services.mullvad-vpn.package "mullvad";
in
{
  config = lib.mkMerge [
    {
      services.mullvad-vpn = {
        enable = enabled;
        package = pkgs.mullvad-vpn;
      };
    }

    (lib.mkIf enabled {
      # Mullvad sends its traffic through a tunnel with policy routing, so replies
      # can arrive on a different interface than the strict reverse-path checks
      # (the firewall's and the kernel's rp_filter = 1 from hardening.nix) expect.
      # "Loose" is what VPN clients need and what most distributions ship.
      networking.firewall.checkReversePath = "loose";
      boot.kernel.sysctl = {
        "net.ipv4.conf.all.rp_filter" = lib.mkForce 2;
        "net.ipv4.conf.default.rp_filter" = lib.mkForce 2;
      };

      # Loaded at boot so they are there when the daemon starts, even on a host
      # that locks kernel modules after boot (security.lockKernelModules).
      boot.kernelModules = [
        "wireguard"
        "tun"
        "nf_tables"
        "nf_conntrack"
        "nft_ct"
        "nft_reject"
        "nft_reject_inet"
        "nft_fib"
        "nft_fib_inet"
        "nft_limit"
        "nft_compat"
        "xt_mark"
      ];

      # Defaults applied once, the first time the daemon is up. Mullvad keeps its
      # settings itself, so they are only written once (a marker file) and anything
      # you change later in the app or with `mullvad` is left alone.
      #   - auto-connect: connect by itself at boot, once you are logged in;
      #   - local network: allowed, so Docker, libvirt VMs and lab networks on
      #     private addresses stay reachable while the VPN is on.
      # The kill switch (lockdown mode) is NOT turned on here: with it on and no
      # account, nothing would reach the network at all. Turn it on yourself with
      # `mullvad lockdown-mode set on` once you are logged in.
      # The account is yours to supply: `mullvad account login <account number>`.
      systemd.services.mullvad-defaults = {
        description = "Mullvad VPN: apply the default settings once";
        wantedBy = [ "multi-user.target" ];
        requires = [ "mullvad-daemon.service" ];
        after = [ "mullvad-daemon.service" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          StateDirectory = "pwnbox";
        };
        script = ''
          marker=/var/lib/pwnbox/mullvad-defaults-v1
          [ -e "$marker" ] && exit 0
          for _ in $(seq 1 60); do
            ${mullvad} status >/dev/null 2>&1 && break
            sleep 0.5
          done
          ${mullvad} auto-connect set on
          ${mullvad} lan set allow
          touch "$marker"
        '';
      };
    })
  ];
}
