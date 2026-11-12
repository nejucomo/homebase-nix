//! Dependency paths baked in at compile time.
//!
//! The nix build sets these environment variables to nix store paths so the
//! binary is hermetic. A plain `cargo build` without them falls back to
//! `$PATH` lookup (and no custom dev-shell bashrc).

/// The `nix` executable.
pub const NIX: &str = env!("HOMEBASE_NIX_NIX_BIN");

/// The interactive `bash` executable used for `develop` shells.
pub const BASH: &str = env!("HOMEBASE_NIX_BASH_BIN");

/// The rcfile for `develop` shells, if any.
pub const DEV_SHELL_BASHRC: Option<&str> = option_env!("HOMEBASE_NIX_DEV_SHELL_BASHRC");

/// The exact nixpkgs flake reference this homebase is pinned to, for `search`.
pub const NIXPKGS_REF: &str = env!("HOMEBASE_NIX_NIXPKGS_REF");
