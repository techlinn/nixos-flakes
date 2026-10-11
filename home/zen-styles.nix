# Serves the recoloured Zen site styles on localhost so the extension can reload them live.
{ pkgs, ... }:
{
  systemd.user.services.pwnbox-styles = {
    Unit.Description = "pwnbox Zen site styles";
    Service = {
      ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p %h/.cache/pwnbox/theme/userstyles";
      ExecStart =
        "${pkgs.python3}/bin/python3 -m http.server 8311"
        + " --bind 127.0.0.1 -d %h/.cache/pwnbox/theme/userstyles";
      Restart = "on-failure";
      RestartSec = 5;
    };
    # default.target, not graphical-session.target: Hyprland here only exports
    # the dbus environment and never activates that target (it stays inactive).
    Install.WantedBy = [ "default.target" ];
  };
}
