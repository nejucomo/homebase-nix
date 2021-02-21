let
  nixpkgs = import <nixpkgs> {};
  inherit (nixpkgs) stdenv writeScript;
  pname = builtins.baseNameOf ./.;
  vimReal = "${nixpkgs.vim}/bin/vim";
  vimrc = ./vimrc;
in
  stdenv.mkDerivation {
    inherit pname vimReal;

    version = "0.1";
    src = vimrc;
    buildInputs = [ nixpkgs.vim ]; 

    vimWrapped = writeScript "${pname}" ''
      #! /bin/bash
      exec "${vimReal}" -u "${vimrc}" "$@"
    '';

    builder = writeScript "${pname}-builder.sh" ''
      source "$stdenv/setup"
      mkdir -p "$out/bin"
      install -m 555 "$vimWrapped" "$out/bin/vim"
      chmod -R u+w "$out"
      patchShebangs "$out"
      ln -s "$vimReal" "$out/bin/vim-real"
    '';
  }

