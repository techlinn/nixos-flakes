{ ... }:
{
  # Boot-time kernel options: quiet boot, memory hardening, IOMMU on, no hibernate.
  boot.kernelParams = [
    "quiet"
    "loglevel=0"
    "rd.udev.log_level=0"
    "systemd.show_status=false"

    "init_on_alloc=1"
    "init_on_free=1"
    "page_alloc.shuffle=1"
    "slab_nomerge"
    "vsyscall=none"
    "debugfs=off"

    "nohibernate"

    "iommu=force"
    "iommu.strict=1"
    "amd_iommu=on"
    "efi=disable_early_pci_dma"

    "random.trust_cpu=off"
    "randomize_kstack_offset=on"

    "oops=panic"
    "panic=10"
  ];
  boot.consoleLogLevel = 0;
  boot.initrd.verbose = false;

  # Legacy / obscure network and filesystem modules — denied at modprobe level.
  boot.blacklistedKernelModules = [
    "dccp" "sctp" "rds" "tipc"
    "firewire_core" "firewire_ohci" "thunderbolt"
    "cramfs" "freevxfs" "jffs2" "hfs" "hfsplus" "udf"
    "vivid"
    "atm" "appletalk" "decnet" "ipx" "p8022" "psnap"
    "ax25" "x25" "rose" "netrom" "n_hdlc" "can" "can_raw"
    "floppy" "pcspkr" "snd_pcsp"
  ];

  # Keep only the last 5 generations in GRUB.
  boot.loader.grub.configurationLimit = 5;

  # PTI (Spectre v2) + lock down kernel memory + no late-loaded modules.
  security.protectKernelImage = true;
  security.forcePageTableIsolation = true;
  security.lockKernelModules = true;

  security.apparmor.enable = true;
}
