{ config, lib, pkgs, ... }:
{
  # Desktop packages: only installed when pwnbox.desktop.enable = true.
  environment.systemPackages = lib.mkIf config.pwnbox.desktop.enable (with pkgs; [
    # Hyprland + shell.
    hyprlock hypridle hyprshot hyprpicker hyprpolkitagent quickshell
    wlr-randr fuzzel rofi pywal16 swaybg wl-clipboard cliphist wtype
    brightnessctl playerctl pamixer pavucontrol easyeffects
    gnome-keyring libsecret

    # Screenshots + screen recording.
    grim slurp swappy

    # Image/video/pdf viewers + ffmpeg.
    imv mpv ffmpeg imagemagick

    # Terminals + file browsers.
    kitty ranger zathura hyfetch

    # Audio clients + visualizer.
    mpc cmus cava

    # Theming.
    nwg-look adwaita-icon-theme papirus-icon-theme
    pwnbox.colloid-cursors
    (colloid-icon-theme.override { colorVariants = [ "grey" ]; })
    gnome-themes-extra gsettings-desktop-schemas

    # XDG + mounting.
    xdg-utils xdg-user-dirs xdg-desktop-portal xdg-desktop-portal-gtk
    gvfs udisks2 udiskie ntfs3g exfat exfatprogs

    # X11 compatibility.
    xwayland xrandr xrdb xsetroot xdotool wmctrl xclip

    # Media downloaders.
    yt-dlp spotdl
  ]);

  # Terminal entry for xdg-terminal-exec.
  xdg.terminal-exec = lib.mkIf config.pwnbox.desktop.enable {
    enable = true;
    settings.default = [ "kitty.desktop" ];
  };
}
