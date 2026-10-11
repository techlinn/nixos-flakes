{ pkgs, ... }:
let
  # Python runtime with a few batteries. Add Python libs here, not in base.
  pythonEnv = pkgs.python3.withPackages (ps: with ps; [
    requests colorama pyautogui pyperclip pillow pygments
  ]);
in
{
  # CLI tools installed on every pwnbox machine.
  environment.systemPackages = with pkgs; [
    figlet

    # Core utilities + archives + sync.
    git git-lfs gh wget curl unzip zip p7zip rar rsync rclone jq bc
    tree file which psmisc plocate trash-cli man man-pages less

    # Shell UX.
    zsh fzf ripgrep fd eza bat zoxide direnv

    # Editors + multiplexers.
    micro vim neovim tmux screen

    # System inspection.
    htop lshw pciutils usbutils lm_sensors fastfetch
    # Reading and repairing the EFI boot entries on this dual-boot machine.
    efibootmgr
    # cudaSupport only adds autoAddDriverRunpath (no CUDA toolkit) so btop can
    # dlopen libnvidia-ml from /run/opengl-driver and show the GPU box.
    (btop.override { cudaSupport = true; })

    # Build toolchains kept lean — add more in packages/languages.nix.
    gcc gnumake pkg-config nodejs bun pnpm go

    # Nix formatting + linting.
    nixfmt statix deadnix

    pythonEnv
  ];
}
