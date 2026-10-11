# nixpkgs overlay: tweak upstream packages before they reach the system.
final: prev: {
  kitty = prev.kitty.overrideAttrs (old: {
    postPatch = (old.postPatch or "") + ''
      substituteInPlace kitty/shaders.c \
        --replace-fail 'w->live_resize.num_of_resize_events > 1' '0'
    '';
  });

  # GitHub Desktop, with sign-in through the browser fixed. See the comments in
  # pkgs/github-desktop.nix.
  github-desktop = final.callPackage ../pkgs/github-desktop.nix {
    github-desktop = prev.github-desktop;
  };

  pwnbox = {
    dotfiles = final.callPackage ../pkgs/dotfiles.nix { };
    manrope = final.callPackage ../pkgs/manrope.nix { };
    colloid-cursors = final.callPackage ../pkgs/colloid-cursors.nix { };
    gnome-fonts = final.callPackage ../pkgs/gnome-fonts.nix { };

    colloid-dark-grey = final.callPackage ../pkgs/colloid-dark-grey.nix {
      accent = "#454545";
    };

    tg-config = final.callPackage ../pkgs/tg-config.nix { };
    sddm-theme = final.callPackage ../pkgs/sddm-theme.nix { };
  };
}
