# Everything that ends up in your home directory. One file per concern.
{ ... }:
{
  imports = [
    ./configs.nix          # ~/.config/* symlinks
    ./scripts.nix          # ~/.scripts + launcher wrappers
    ./desktop-entries.nix  # .desktop files for launcher icons
    ./activations.nix      # per-rebuild seed/copy scripts
  ];
}
