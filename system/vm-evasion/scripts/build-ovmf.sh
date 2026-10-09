#!/usr/bin/env bash
# Build custom OVMF (EDK2) with scrubbed VM-identifying strings and install to
# ~/VMs/build-ovmf. Point your libvirt domain's <loader> at
# ~/VMs/build-ovmf/edk2/Build/OvmfX64/RELEASE_GCC5/FV/OVMF_CODE.fd.
#
# Run this once on a fresh machine. Takes ~20 min.

set -euo pipefail

OUT_DIR="$HOME/VMs/build-ovmf"
EDK2_DIR="$OUT_DIR/edk2"

mkdir -p "$OUT_DIR"
cd "$OUT_DIR"

if [ ! -d "$EDK2_DIR" ]; then
  echo "==> Cloning EDK2"
  git clone --branch edk2-stable202502 https://github.com/tianocore/edk2.git
  cd edk2
  git submodule update --init
  cd ..
fi

cd "$EDK2_DIR"

echo "==> Building BaseTools + OvmfPkg"
nix-shell -p gcc python3 nasm iasl util-linux acpica-tools --run '
  export PACKAGES_PATH="$PWD"
  export WORKSPACE="$PWD"
  make -C BaseTools
  source edksetup.sh BaseTools
  build -a X64 -t GCC5 -p OvmfPkg/OvmfPkgX64.dsc -b RELEASE \
        -D SECURE_BOOT_ENABLE=TRUE -D TPM2_ENABLE=TRUE \
        -D NETWORK_IP6_ENABLE=TRUE
'

echo "==> Done. Firmware at $EDK2_DIR/Build/OvmfX64/RELEASE_GCC5/FV/OVMF_CODE.fd"
