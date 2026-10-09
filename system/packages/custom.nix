{ pkgs, ... }:
{
  # Custom packages defined in pkgs/custom.nix (manrope font, overlays, etc).
  environment.systemPackages = import ../../pkgs/custom.nix { inherit pkgs; };
}
