# Docker, libvirt (KVM for VMs), Wireshark. Toggle each in your host file.
{
  config,
  lib,
  ...
}:
let
  dockerKernelModules = [
    "overlay"
    "xt_addrtype"
    "nft_compat"
    "nft_chain_nat"
    "nft_nat"
    "nft_masq"
    "xt_MASQUERADE"
  ];
in
{
  virtualisation.docker.enable = config.pwnbox.virtualisation.docker;

  virtualisation.docker.enableOnBoot = config.pwnbox.virtualisation.dockerOnBoot;

  virtualisation.docker.daemon.settings.userland-proxy = false;

  boot.kernelModules = lib.optionals config.pwnbox.virtualisation.docker dockerKernelModules;

  virtualisation.libvirtd.enable = config.pwnbox.virtualisation.libvirtd;

  # Never start virtual machines by themselves at boot. The NixOS default is
  # "start", which brings back every VM that was running when the computer was
  # last shut down, and a running VM holds all of its memory (4 GB for the
  # analysis VM). VMs are started by hand in virt-manager.
  virtualisation.libvirtd.onBoot = lib.mkIf config.pwnbox.virtualisation.libvirtd "ignore";

  # Windows 11 needs a TPM 2.0 (swtpm) and Secure Boot firmware (OVMF), and
  # virt-manager is the window used to create and run the VMs.
  virtualisation.libvirtd.qemu.swtpm.enable = lib.mkIf config.pwnbox.virtualisation.libvirtd true;
  programs.virt-manager.enable = config.pwnbox.virtualisation.libvirtd;

  programs.wireshark.enable = config.pwnbox.virtualisation.wireshark;
}
