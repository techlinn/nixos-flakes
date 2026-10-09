#!/usr/bin/env bash
# Build a custom QEMU 10.1.0 with the PIT ACPI patch and install it to
# ~/VMs/custom-qemu. Point your libvirt domain's <emulator> at
# ~/VMs/custom-qemu/bin/qemu-system-x86_64 to use it.
#
# Run this once on a fresh machine. Takes ~10 min on a 16-thread CPU.

set -euo pipefail

QEMU_VERSION="10.1.0"
SRC_DIR="$HOME/VMs/build/qemu-${QEMU_VERSION}"
INSTALL_DIR="$HOME/VMs/custom-qemu"
PATCH="$(dirname "$(readlink -f "$0")")/../patches/qemu-pit-acpi.patch"

mkdir -p "$HOME/VMs/build"
cd "$HOME/VMs/build"

if [ ! -d "$SRC_DIR" ]; then
  echo "==> Fetching QEMU $QEMU_VERSION source"
  curl -sSL "https://download.qemu.org/qemu-${QEMU_VERSION}.tar.xz" | tar -xJ
fi

cd "$SRC_DIR"

if ! grep -q build_pit_aml hw/i386/acpi-build.c; then
  echo "==> Applying PIT ACPI patch"
  patch -p1 < "$PATCH"
fi

if [ ! -d build ]; then
  echo "==> Configuring"
  nix-shell -p ninja meson pkg-config gcc glib pixman zlib python3 \
            snappy lzo dtc numactl vde2 libaio bzip2 libseccomp \
            liburing capstone \
            --run "./configure --target-list=x86_64-softmmu --prefix=$INSTALL_DIR"
fi

echo "==> Building"
nix-shell -p ninja meson pkg-config gcc glib pixman zlib python3 \
          snappy lzo dtc numactl vde2 libaio bzip2 libseccomp \
          liburing capstone \
          --run "ninja -C build qemu-system-x86_64"

mkdir -p "$INSTALL_DIR/bin"
cp build/qemu-system-x86_64 "$INSTALL_DIR/bin/"

echo "==> Done. Binary at $INSTALL_DIR/bin/qemu-system-x86_64"
