//! Everything for homebase-nix.

mod develop;
mod paths;
mod search;
mod trace;

use std::process::ExitCode;

use clap::{CommandFactory, Parser, Subcommand};

/// Everything for homebase-nix.
#[derive(Debug, Parser)]
#[command(name = "homebase-nix", version)]
struct Options {
    #[command(subcommand)]
    cmd: Option<Cmd>,
}

#[derive(Debug, Subcommand)]
enum Cmd {
    /// Enter a 'nix develop' interactive bash shell for the flake in the
    /// current directory
    ///
    /// Enter a 'nix develop' interactive bash shell for the flake in the
    /// current directory. If CMD is given, run it in that shell. Renames the
    /// zellij tab when run inside zellij outside of a nix shell.
    Develop {
        /// A command (and its arguments) to run inside the shell
        #[arg(trailing_var_arg = true, allow_hyphen_values = true)]
        cmd: Vec<String>,
    },

    /// Search the pinned nixpkgs for packages matching REGEX
    #[command(long_about = search_long_about())]
    Search {
        /// A case-insensitive regex matched against attribute paths and package names
        regex: String,
    },
}

fn search_long_about() -> String {
    format!(
        "Search the nixpkgs revision this flake is pinned to for packages \
         whose attribute path or package name matches REGEX \
         (case-insensitive). The pinned nixpkgs is:\n{}",
        paths::NIXPKGS_REF,
    )
}

fn main() -> ExitCode {
    if trace::debug_enabled() {
        eprintln!("[homebase debug enabled]");
    }

    let opts = Options::parse();
    let result = match opts.cmd {
        None => Options::command()
            .print_long_help()
            .map_err(anyhow::Error::from),
        Some(Cmd::Develop { cmd }) => develop::develop(&cmd),
        Some(Cmd::Search { regex }) => search::search(&regex),
    };

    match result {
        Ok(()) => ExitCode::SUCCESS,
        Err(e) => {
            eprintln!("\x1b[33mhomebase-nix error: {e:#}\x1b[0m");
            ExitCode::FAILURE
        }
    }
}
