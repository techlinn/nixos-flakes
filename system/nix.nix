# Nix daemon tuning: flakes on, parallel builds, garbage collection, nix-ld libs.
{ pkgs, ... }:
{
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    # Build parallelism: 2 derivations in parallel, each with 12 threads.
    # Tuned for a 16-thread CPU — leaves 4 threads for the host.
    max-jobs = 2;
    cores = 12;
    trusted-users = [
      "root"
      "@wheel"
    ];
    auto-optimise-store = true;
    keep-outputs = false;
    keep-derivations = false;
  };

  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 7d";
    # Without this a GC missed while the machine was off runs during the next
    # boot, where it cost ~7s of disk against everything else starting.
    randomizedDelaySec = "45min";
  };

  nixpkgs.config.allowUnfree = true;

  # Lets downloaded Linux programs (e.g. IDA Pro in ~/IDA) find the system
  # libraries they expect. nix-ld on its own provides none of these.
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc
      zlib
      glib
      libxkbcommon
      libGL
      fontconfig
      freetype
      dbus
      libx11
      libxext
      libxtst
      libxcb
      libxrender
      libxi
      libxfixes
      libxcomposite
      libxcursor
      libxdamage
      libxrandr
      libxkbfile
      xcbutil
      xcbutilwm
      xcbutilimage
      xcbutilkeysyms
      xcbutilrenderutil
      xcbutilcursor
      libsm
      libice
      wayland
      krb5
      openssl
      libsecret
    ];
  };
}
