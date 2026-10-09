{ ... }:
{
  # Volatile logs: journald lives in RAM, /var/log is tmpfs, nothing hits disk.
  services.journald.extraConfig = ''
    Storage=volatile
    RuntimeMaxUse=64M
    RuntimeKeepFree=16M
    MaxLevelStore=warning
    MaxLevelSyslog=warning
    MaxLevelKMsg=none
    MaxLevelConsole=none
    MaxLevelWall=none
    Audit=no
    ForwardToSyslog=no
    ForwardToKMsg=no
    ForwardToConsole=no
    ForwardToWall=no
  '';
  services.journald.forwardToSyslog = false;
  services.journald.upload.enable = false;

  fileSystems."/var/log" = {
    device = "none";
    fsType = "tmpfs";
    options = [ "size=64M" "mode=0755" "nosuid" "nodev" "noexec" ];
  };

  # Temp dirs also in RAM.
  boot.tmp.useTmpfs = true;
  boot.tmp.cleanOnBoot = true;
  fileSystems."/var/tmp" = {
    device = "none";
    fsType = "tmpfs";
    options = [ "size=512M" "mode=1777" "nosuid" "nodev" ];
  };

  # No coredumps.
  systemd.coredump.enable = false;
  boot.kernel.sysctl."kernel.core_pattern" = "/dev/null";
}
