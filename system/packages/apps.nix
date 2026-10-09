{ config, lib, pkgs, inputs ? null, ... }:
let
  # Zen browser comes from a separate flake input; skip if the input is absent.
  zenBrowser =
    if inputs != null && inputs ? zen-browser
    then inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    else null;
in
{
  # GUI apps everyone gets. Mullvad is only installed if the VPN is enabled.
  environment.systemPackages =
    (with pkgs; [
      chromium

      # Messaging.
      signal-desktop ayugram-desktop element-desktop
      simplex-chat-desktop dino qtox equibop session-desktop

      # Productivity + notes + password mgmt + mail.
      obsidian zed-editor github-desktop geary keepassxc

      # Media + torrents.
      spotify spicetify-cli qbittorrent vlc obs-studio cutter

      # File manager + archive manager (WinRAR-style) + reverse shells.
      thunar peazip pwncat

      # Tor browsing.
      tor-browser tor torsocks
    ])
    ++ lib.optionals config.pwnbox.vpn.mullvad [ pkgs.mullvad-vpn ]
    ++ lib.optionals (zenBrowser != null) [ zenBrowser ];

  # Allow .AppImage to run directly.
  programs.appimage.enable = true;

  # Zen is the default handler for web stuff.
  xdg.mime.defaultApplications = {
    "text/html" = "zen.desktop";
    "text/xml" = "zen.desktop";
    "application/xhtml+xml" = "zen.desktop";
    "application/vnd.mozilla.xul+xml" = "zen.desktop";
    "x-scheme-handler/http" = "zen.desktop";
    "x-scheme-handler/https" = "zen.desktop";
    "x-scheme-handler/about" = "zen.desktop";
    "x-scheme-handler/unknown" = "zen.desktop";

    # Archives open in PeaZip on double-click.
    "application/vnd.rar" = "peazip.desktop";
    "application/x-rar" = "peazip.desktop";
    "application/x-rar-compressed" = "peazip.desktop";
    "application/zip" = "peazip.desktop";
    "application/x-7z-compressed" = "peazip.desktop";
  };
}
