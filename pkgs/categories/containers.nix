{ pkgs, ... }:
with pkgs;
[
  docker
  podman
  distrobox

  trivy
  grype
  syft
  dive

  buildah
  skopeo
  crun
  runc
  ctop
  lazydocker
]
