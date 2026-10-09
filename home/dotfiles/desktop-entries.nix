# Launcher .desktop entries (rename AyuGram → Telegram, Equibop → Discord, …).
{ config, lib, pwnboxDisplay ? "preferred", pwnboxMonitors ? [ ], ... }:
let
  h = import ./_lib.nix { inherit config lib pwnboxDisplay pwnboxMonitors; };
in
{
  # Spotify .desktop that routes through pwnbox-spotify (patched Spicetify).
  xdg.dataFile."applications/spotify.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Spotify
    GenericName=Music Player
    Comment=Spotify (Spicetify, pwnbox theme)
    Exec=${h.homeDir}/.scripts/pwnbox-spotify launch %U
    TryExec=${h.homeDir}/.scripts/pwnbox-spotify
    Icon=spotify-client
    Terminal=false
    MimeType=x-scheme-handler/spotify;
    Categories=Audio;Music;Player;AudioVideo;
    StartupWMClass=spotify
  '';

  # Show AyuGram as "Telegram" in the launcher.
  xdg.desktopEntries."com.ayugram.desktop" = {
    name = "Telegram";
    comment = "Telegram (AyuGram client)";
    exec = "env DESKTOPINTEGRATION=1 AyuGram -- %U";
    icon = "com.ayugram.desktop";
    terminal = false;
    type = "Application";
    categories = [ "Chat" "Network" "InstantMessaging" "Qt" ];
    mimeType = [ "x-scheme-handler/tg" "x-scheme-handler/tonsite" ];
    settings = {
      StartupWMClass = "AyuGram";
      Keywords = "tg;chat;im;messaging;messenger;sms;telegram;tdesktop;ayugram;";
    };
    actions.quit = {
      name = "Quit Telegram";
      exec = "AyuGram -quit";
      icon = "application-exit";
    };
  };

  # Show Equibop (Discord client) as "Discord" in the launcher.
  xdg.desktopEntries.equibop = {
    name = "Discord";
    genericName = "Internet Messenger";
    exec = "equibop %U";
    icon = "equibop";
    terminal = false;
    type = "Application";
    categories = [ "Network" "InstantMessaging" "Chat" ];
    settings = {
      StartupWMClass = "Equibop";
      Keywords = "discord;equibop;electron;chat";
    };
  };
}
