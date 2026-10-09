{ pkgs, ... }:
{
  # Language toolchains — add/remove to taste. These install globally; most
  # projects should pin via devShells or language-specific lockfiles instead.
  environment.systemPackages = with pkgs; [
    clang clang-tools

    rustc cargo rust-analyzer

    zig zls

    dotnet-sdk

    jdk21 kotlin scala

    uv pipx

    ruby php perl lua5_4 luajit

    deno typescript

    elixir erlang

    ghc cabal-install stack

    ocaml nim R julia clojure groovy crystal

    powershell dart
  ];
}
