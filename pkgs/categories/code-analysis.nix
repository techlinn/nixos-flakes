{ pkgs, ... }:
with pkgs;
[
  semgrep
  codeql
  gitleaks
  trufflehog
  gosec
  golangci-lint
  govulncheck
  bearer
  cppcheck
  python3Packages.bandit

  shellcheck
  shfmt
  hadolint
  revive
  brakeman
  cargo-audit
  cargo-deny
]
