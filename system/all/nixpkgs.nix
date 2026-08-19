{
  perSystem = { pkgs, ... }: {
    packages = {
      inherit (pkgs)
        # cargo-autoinherit
        # cargo-checkmate
        # cargo-expand
        # cargo-udeps
        # clang
        # firefox
        # logseq
        # man-pages
        # man-pages-posix
        # niri
        # nix-index
        # numbat
        # penumbra
        # radicle
        # sapling
        # sccache
        fd
        file
        findutils
        gawk
        git
        gnugrep
        gnused
        gzip
        helix
        jq
        jujutsu
        less
        man
        meld
        nixfmt
        ps
        pstree
        ripgrep
        rustup
        sd
        tokei
        toml2json
        which
        ;

      # llvmPackages_bintools = pkgs.llvmPackages.bintools;
    };
  };
}
