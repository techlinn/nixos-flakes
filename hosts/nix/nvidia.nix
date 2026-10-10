# NVIDIA driver + GPU settings for this machine (RTX 4060, no iGPU).
{ ... }:
{
  # RTX 4060 (no integrated GPU), so the NVIDIA driver is required for the desktop.
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    open = true; # the open kernel modules support RTX 20-series and newer
    modesetting.enable = true;
    powerManagement.enable = false;
  };
}
