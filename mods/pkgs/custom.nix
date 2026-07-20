# Our own packages, built from templates under ./pkg via templatePackage.
#
# `git-clone-canonical` here is the wrapper script (adds
# `--update-hack-links`), not the raw upstream flake package - it owns
# that name in `packages`, matching the old merged-profile precedence
# where the wrapper's bin/git-clone-canonical shadowed upstream's. See
# mods/flakepkgs.nix, which no longer exposes the raw package directly.
{
  perSystem =
    { pkgs, inputs', ... }:
    let
      templatePackage = import ../../lib/templatePackage {
        basePkgs.nix = pkgs;
        attrsets = pkgs.lib.attrsets;
      };

      upstreamGitCloneCanonical = inputs'.git-clone-canonical.packages.default;

      hbdeps = {
        bash-postlude = templatePackage ../pkg/bash-postlude "lib" { };

        git-current-branch = templatePackage ../pkg/git-current-branch "bin" {
          inherit (hbdeps) bash-postlude;
          inherit (pkgs) git sd;
        };

        git-summarize-dirt = templatePackage ../pkg/git-summarize-dirt "bin" {
          inherit (hbdeps) bash-postlude git-current-branch;
          inherit (pkgs) git sd;
        };

        bashrc-dir = templatePackage ../pkg/bashrc-dir "etc/bashrc-dir" {
          inherit (pkgs) sd;
          inherit (hbdeps) git-summarize-dirt;
        };

        git-user-hooks = templatePackage ../pkg/git-user-hooks "lib/git-user-hooks" {
          inherit (hbdeps) bash-postlude set-symlink;
          git-clone-canonical = upstreamGitCloneCanonical;
        };

        xdg-config = templatePackage ../pkg/xdg-config "etc/xdg" {
          inherit (pkgs) nixfmt;
          inherit (hbdeps) git-user-hooks bashrc-dir;
        };

        nix = templatePackage ../pkg/nix "bin" {
          inherit (hbdeps) bash-postlude;
          inherit (pkgs) nix;
        };

        set-symlink = templatePackage ../pkg/set-symlink "bin" {
          inherit (hbdeps) bash-postlude;
          inherit (pkgs) coreutils;
        };
      };
    in
    {
      packages = hbdeps // {
        bash = templatePackage ../pkg/bash "bin" {
          inherit (hbdeps) bashrc-dir xdg-config;
          inherit (pkgs) bashInteractive;
        };

        bash-scripts = templatePackage ../pkg/bash-scripts "bin" { inherit (hbdeps) bash-postlude; };

        cargo-depgraph-svg = templatePackage ../pkg/cargo-depgraph-svg "bin" {
          inherit (pkgs) cargo-depgraph graphviz;
        };

        wormhole = templatePackage ../pkg/wormhole "bin" { inherit (pkgs) magic-wormhole; };

        git-clone-canonical = templatePackage ../pkg/git-clone-canonical "bin" {
          inherit (hbdeps) bash-postlude set-symlink;
          git-clone-canonical = upstreamGitCloneCanonical;
        };

        git-log-fork = templatePackage ../pkg/git-log-fork "bin" {
          inherit (hbdeps) bash-postlude;
          inherit (pkgs) bash git;
        };

        git-copy-remotes = templatePackage ../pkg/git-copy-remotes "bin" {
          inherit (hbdeps) bash-postlude;
          inherit (pkgs) bash git;
        };

        zellij = templatePackage ../pkg/zellij "bin" {
          inherit (hbdeps) xdg-config;
          inherit (pkgs) zellij;
        };

        homebase-nix-develop = templatePackage ../pkg/homebase-nix-develop "bin" {
          inherit (hbdeps) bashrc-dir nix;
          inherit (pkgs) bashInteractive;
        };
      };
    };
}
