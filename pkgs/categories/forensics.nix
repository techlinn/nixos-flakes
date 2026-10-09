{ pkgs, ... }:
with pkgs;
[
  sleuthkit
  ddrescue
  foremost
  testdisk
  extundelete
  ntfs3g
  dislocker

  volatility3
  bulk_extractor
  exiftool
  hivex

  smartmontools
  nvme-cli

  hayabusa
  chainsaw

  dc3dd
  scalpel
  libewf
  afflib
  regripper
]
