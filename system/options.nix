# All pwnbox.* options are declared here (username, host, desktop toggles, VM
# evasion, package categories). Host files set them.
{
  lib,
  pkgs,
  inputs ? { },
  ...
}:
let
  inherit (lib) mkOption mkEnableOption types;

  categories = import ../pkgs/categories.nix {
    inherit pkgs inputs;
    system = pkgs.stdenv.hostPlatform.system;
  };
in
{
  options.pwnbox = {
    username = mkOption {
      type = types.str;
      default = "pwnbox";
      description = "Name of the primary user account.";
    };

    fullName = mkOption {
      type = types.str;
      default = "pwnbox";
      description = "Full name (GECOS) of the primary user.";
    };

    email = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Optional git e-mail address for the primary user.";
    };

    hostName = mkOption {
      type = types.str;
      default = "nixos";
      description = "Network hostname.";
    };

    timeZone = mkOption {
      type = types.str;
      default = "Europe/Berlin";
      description = "System time zone.";
    };

    locale = mkOption {
      type = types.str;
      default = "en_US.UTF-8";
      description = "Default system locale.";
    };

    extraGroups = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Extra groups to add to the primary user.";
    };

    desktop = {
      enable = mkEnableOption "the Hyprland + GNOME Wayland desktop, sessions and login manager";

      resolution = mkOption {
        type = types.str;
        default = "preferred";
        example = "2560x1440@144";
        description = ''
          Preferred mode applied to every monitor by Hyprland
          (`monitor = , <resolution>, auto, auto`).  Set to `preferred` to
          always use each monitor's native mode instead.
        '';
      };

      monitors = mkOption {
        type = types.listOf types.str;
        default = [ ];
        example = [
          "HDMI-A-1, 1920x1080@60, 0x0, 1"
          "DP-2, 1920x1080@164.5, 1920x0, 1"
        ];
        description = ''
          Explicit Hyprland `monitor =` rules for this machine: one entry per
          monitor, "name, mode, position, scale".  Names come from
          `hyprctl monitors`.  Monitors not listed here fall back to
          `resolution`.  Leave empty on a machine with one screen.
        '';
      };

      loginManager = mkOption {
        type = types.enum [
          "sddm"
          "ly"
        ];
        default = "sddm";
        description = ''
          Which login screen to use.  `sddm` is the graphical one, coloured
          from the current theme to match the lock screen.  `ly` is the
          console TUI that came before it; switching back is this one line
          plus `upd`.
        '';
      };

      accessibility = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Enable the at-spi2-core accessibility bus.  Disabling it stops the
          `at-spi-dbus-bus` / `org.a11y.atspi.Registry` user services and sets
          `NO_AT_BRIDGE=1` / `GTK_A11Y=none` for every session.  Turn it off if
          you do not use assistive technologies; GNOME force-enables it, so
          this option overrides that when set to `false`.
        '';
      };
    };

    vpn = {
      mullvad = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Install and run the Mullvad VPN daemon + GUI.  When disabled, the
          always-resident `mullvad-daemon` (~27 MB) is not started and the
          package is not installed.
        '';
      };
    };

    virtualisation = {
      docker = mkEnableOption "Docker";
      dockerOnBoot = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Start the Docker daemon (`dockerd`) on boot.  When disabled (the
          default), dockerd is not started at boot in order to keep idle
          RAM/CPU usage minimal.  The Docker socket is still enabled, so the
          daemon starts on demand the first time the `docker` command is used.
        '';
      };
      libvirtd = mkEnableOption "libvirt / KVM virtualisation";
      wireshark = mkEnableOption "Wireshark and the wireshark group";
      vmEvasion.enable = mkEnableOption "KVM anti-VM-detection hardening (kernel patches + boot tuning; see system/vm-evasion/README.md)";
    };

    packages = {
      gaming = mkEnableOption "gaming and entertainment applications";
      creative = mkEnableOption "creative, media and office applications";
      hacking = mkEnableOption "pentesting and security tooling (the full pwnbox toolset)";

      toolset = lib.genAttrs (builtins.attrNames categories) (name: {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Install the '${name}' pentest tool category.";
        };
      });
    };
  };
}
