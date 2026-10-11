{ ... }:
{
  # Disable services that broadcast your machine's presence or expose it.
  services.avahi.enable = false;
  services.printing.enable = false;
  services.fwupd.enable = false;
  services.geoclue2.enable = false;
  services.openssh.enable = false;

  # No auto-login, no root password (locked).
  services.displayManager.autoLogin.enable = false;
  users.users.root.hashedPassword = "!";

  # A locked root makes systemd's emergency and rescue shells refuse to start
  # ("the root account is locked"), so one failed mount turns into a live-USB
  # recovery. Physical access already means root here (GRUB has no password),
  # so let the console shell open instead of being locked out of the machine.
  systemd.services.emergency.environment.SYSTEMD_SULOGIN_FORCE = "1";
  systemd.services.rescue.environment.SYSTEMD_SULOGIN_FORCE = "1";
}
