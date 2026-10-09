{ config, lib, pkgs, inputs ? null, ... }:
let
  # Pulls the 26 pentest-tool categories defined in pkgs/categories/*.nix.
  categories = import ../../pkgs/categories.nix {
    inherit pkgs;
    inputs = if inputs == null then { } else inputs;
    system = pkgs.stdenv.hostPlatform.system;
  };
  # Only install categories you flipped on in pwnbox.packages.toolset.<name>.enable.
  enabledToolCategories = lib.filter
    (n: config.pwnbox.packages.toolset.${n}.enable)
    (builtins.attrNames categories);
  pentestTools = pkgs.buildEnv {
    name = "pwnbox-tools";
    paths = lib.flatten (map (n: categories.${n}) enabledToolCategories);
    ignoreCollisions = true;
  };
in
{
  # The pentest toolset. Toggle with pwnbox.packages.hacking = true;
  environment.systemPackages = lib.mkIf config.pwnbox.packages.hacking [ pentestTools ];

  # Some pentest tools pin old / insecure deps on purpose. Allow them only when
  # the hacking toolset is on so a regular desktop install stays strict.
  nixpkgs.config = lib.mkIf config.pwnbox.packages.hacking {
    allowInsecurePredicate = _: true;
  };

  # Expose wordlists path to env for tools that look them up.
  environment.sessionVariables = lib.mkIf
    (config.pwnbox.packages.hacking && config.pwnbox.packages.toolset.wordlists.enable)
    {
      SECLISTS_DIR = "${pkgs.seclists}/share/wordlists/seclists";
      WORDLISTS_DIR = "${pkgs.wordlists}/share/wordlists";
    };
}
