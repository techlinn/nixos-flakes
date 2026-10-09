# vm-evasion — AI maintenance notes

Read the project rules file in the repo root first for the global rules. This file only covers
things specific to this module.

## Purpose

Makes a Windows guest on KVM look more like bare metal, so VM-detection
tools (VMAware, al-khaser, Pafish, anti-cheats) stop flagging it. Enabled
via `pwnbox.virtualisation.vmEvasion.enable` in the host file.

## Current baseline against VMAware (2/84, brand Unknown)

- virtual GPUs — DETECTED. Needs patched IddCx VDD; not addressed by this
  flake yet.
- hypervisor interception (VM::HYPERVISOR_HOOK, weight 150) — DETECTED on
  bare single-layer KVM. The check has four sub-tests and current KVM
  trips at least one. Only known fixes are nested L1 Hyper-V (ruled out
  by owner) or patching the detector itself. VM::HYPERVISOR_HOOK alone
  equals the likeliness threshold (150), so likeliness stays at 100%
  until this is flipped.

Everything else VMAware checks is NOT DETECTED thanks to the combination
of this module, the custom QEMU with the PIT ACPI patch, the custom OVMF
build, and the libvirt-domain-reference.xml VM configuration.

## Persistence rule

Every modification to the VM-evasion stack must land in a tracked file in
this directory (or in `hosts/<host>/`). Changing a running VM's libvirt XML
with `virsh define` and nothing else is NOT persistent for the flake —
`libvirt-domain-reference.xml` here must be refreshed too, or the change is
lost on reinstall.

Every kernel-level mitigation goes into `patches/` with a corresponding
entry in `default.nix`. Do not patch a running kernel module. Do not inject
behaviour via `/etc/modprobe.d/` written imperatively. All of it has to
rebuild from the flake on a fresh machine.

## What this module controls

Kernel patches (applied by `default.nix`, rebuild the kernel on `upd`):

| Patch | Targets |
| --- | --- |
| `patches/kvm-vmcall-ud.patch` | VMAware `VM::KVM_INTERCEPTION` |
| `patches/kvm-cpuid-fastpath.patch` | VMAware `VM::TIMER` ("timing anomalies") |
| `patches/kvm-no-db-intercept.patch` | VMAware `VM::HYPERVISOR_HOOK` DR0 sub-test |

Kernel boot params (applied by `default.nix`):

| Param | Reason |
| --- | --- |
| `kvm.nx_huge_pages=never` | reduce EPT walk variance |
| `kvm_intel.enable_shadow_vmcs=0` | reduce shadow-VMCS leakage |

## What this module does NOT control (out-of-flake pieces)

- `patches/qemu-pit-acpi.patch` is here for reference and gets re-applied by
  the custom QEMU build script. The custom QEMU binary itself lives under
  `~/VMs/custom-qemu/bin/` and is not managed by nix.
- Custom OVMF firmware lives under `~/VMs/build-ovmf/`.
- The libvirt domain XML lives under `/var/lib/libvirt/qemu/`.
  `libvirt-domain-reference.xml` in this directory is the flake-tracked
  snapshot. Any change to the live XML must be mirrored here with
  `virsh dumpxml` → overwrite the snapshot.

Build scripts for the out-of-flake pieces are in `scripts/`.

## Adding a new mitigation

1. Save the patch under `patches/`.
2. Add an entry to `boot.kernelPatches` in `default.nix` with a short
   descriptive name.
3. If the mitigation is a boot-param, add it to `boot.kernelParams` in
   `default.nix` instead.
4. Owner runs `upd` and reboots.
5. Update the project rules file's "Hard don'ts" or "Decision table" only if
   this patch adds a new category of change that isn't covered there.
6. Re-dump the libvirt reference XML if the mitigation requires a VM-side
   setting that lives in the domain config.

## Rollback

Every `upd` creates a new system generation. GRUB offers the previous five
on boot. A bad patch rolls back by selecting an older generation.
