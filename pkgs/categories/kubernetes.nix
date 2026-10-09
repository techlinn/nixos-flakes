{ pkgs, ... }:
with pkgs;
[
  kubectl
  k9s
  kind
  kustomize

  kube-hunter
  kubeaudit
  kubescape
  popeye
  kube-bench
  kubesec
  kubeconform
  conftest

  kubernetes-helm
  helmfile
  kubectx
  stern
  velero
  kube-score
  polaris
]
