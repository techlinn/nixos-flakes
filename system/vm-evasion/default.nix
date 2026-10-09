{ config, lib, ... }:
let
  cfg = config.pwnbox.virtualisation.vmEvasion;
in
{
  # KVM anti-detection: kernel patches + boot tuning so a Windows guest looks
  # more like bare metal to malware / anti-cheat probes (VMAware, al-khaser).
  # Toggle with `pwnbox.vmEvasion.enable = true;` in your host config.

  config = lib.mkIf cfg.enable {
    boot.kernelPatches = [
      { name = "kvm-vmcall-ud"; patch = ./patches/kvm-vmcall-ud.patch; }
      { name = "kvm-cpuid-fastpath"; patch = ./patches/kvm-cpuid-fastpath.patch; }
      { name = "kvm-no-db-intercept"; patch = ./patches/kvm-no-db-intercept.patch; }
      { name = "kvm-ept-sync"; patch = ./patches/kvm-ept-sync.patch; }
    ];

    boot.kernelParams = [
      "kvm.nx_huge_pages=never"
      "kvm_intel.enable_shadow_vmcs=0"
      "kvm_intel.pml=0"
      "kvm.tdp_mmu=0"
      "kvm_intel.flexpriority=0"
      "kvm_intel.vpid=0"
      "kvm_intel.enable_apicv=0"
      "kvm.ignore_msrs=1"
    ];
  };
}
