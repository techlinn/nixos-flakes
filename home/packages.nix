# User-level packages (installed only for your user, not globally).
{ pkgs, lib, ... }:
{
  # Optional extras kept on this machine only.
  imports = lib.optional (builtins.pathExists ./packages-local.nix) ./packages-local.nix;

  home.packages = with pkgs; [
    keepassxc
    flameshot
    pavucontrol

    pkgs.pwnbox.tg-config

    opencode

    (writeShellScriptBin "zed" ''exec ${zed-editor}/bin/zeditor "$@"'')
  ];
}
