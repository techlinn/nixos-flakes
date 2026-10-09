# PolicyKit, GPG agent, rtkit — the plumbing apps use to ask for permissions.
{ pkgs, ... }:
{
  security.rtkit.enable = true;
  security.polkit.enable = true;

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  environment.systemPackages = with pkgs; [
    polkit_gnome
    libnotify
  ];
}
