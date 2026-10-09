# Per-user home-manager config. Everything that lives in your home dir.
{ ... }:
{
  imports = [
    ./dotfiles     # ~/.config/*, ~/.scripts, launcher wrappers, activation hooks
    ./shell.nix    # zsh + aliases + prompt
    ./packages.nix # user-only extras
    ./gtk.nix      # GTK theme (icons, cursor, dark mode)
    ./neovim.nix   # neovim plugins + config
  ];
}
