# ly: console TUI login manager, used when pwnbox.desktop.loginManager = "ly".
{
  config,
  lib,
  ...
}:
lib.mkIf (config.pwnbox.desktop.enable && config.pwnbox.desktop.loginManager == "ly") {
  services.displayManager.ly = {
    enable = true;

    settings = {
      bg = "0x00080808";
      fg = "0x00cccccc";
      border_fg = "0x00353535";
      error_bg = "0x00080808";
      error_fg = "0x01ffffff";

      full_color = true;

      animation = "none";
      hide_version_string = true;
      hide_key_hints = true;

      clock = "%H:%M";
      edge_margin = 1;
    };
  };
}