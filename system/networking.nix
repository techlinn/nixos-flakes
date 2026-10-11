# Hostname, NetworkManager, encrypted DNS (DoT via systemd-resolved).
{
  config,
  lib,
  ...
}:
{
  networking.hostName = config.pwnbox.hostName;

  networking.networkmanager = {
    enable = true;
    dns = "systemd-resolved";

    wifi.scanRandMacAddress = true;
  };

  # `nm-online -s` waits for NetworkManager to finish with every device, and the
  # disconnected wifi card keeps it busy for ~12s after ethernet is already up.
  # Everything ordered after network-online.target waits that out, which on this
  # machine means the login screen. Wait for a usable connection instead.
  systemd.services.NetworkManager-wait-online.serviceConfig.ExecStart = [
    ""
    "${lib.getExe' config.networking.networkmanager.package "nm-online"} -q -t 10"
  ];

  services.resolved = {
    enable = true;
    settings.Resolve = {
      DNSOverTLS = "opportunistic";
      DNSSEC = "allow-downgrade";
      LLMNR = false;
      MulticastDNS = false;
      Cache = true;
      FallbackDNS = [
        "9.9.9.9"
        "149.112.112.112"
      ];
    };
  };
}
