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
}
