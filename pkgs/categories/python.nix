{ pkgs, ... }:
with pkgs;
[
  python3Packages.shodan
  python3Packages.python-nmap
]
