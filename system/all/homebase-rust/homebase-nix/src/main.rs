//! Everything for homebase-nix.
#![feature(exit_status_error)]

mod develop;
mod hack;
mod paths;
mod search;
mod trace;

use clap::{Parser, Subcommand};

fn main() -> yaffa::Result<()> {
    use yaffa::App as _;

    HbApp.run_main()
}

#[derive(Copy, Clone, Debug, Default)]
struct HbApp;

impl yaffa::App for HbApp {
    type Options = Options;
}

impl yaffa::RunWith<Options> for HbApp {
    fn run_with(self, opts: Options) -> yaffa::Result<()> {
        use Command::*;

        match opts.cmd {
            Develop { cmd } => develop::develop(&cmd),
            Hack(opts) => hack::run(opts),
            Search { regex } => search::search(&regex),
        }
    }
}

/// Everything for homebase-nix.
#[derive(Debug, Parser)]
#[command(name = "homebase-nix", version)]
struct Options {
    #[command(subcommand)]
    cmd: Command,
}

#[derive(Debug, Subcommand)]
enum Command {
    /// Wrap 'nix develop' shell w/ some homebase love
    Develop {
        /// A command (and its arguments) to run inside the shell
        #[arg(trailing_var_arg = true, allow_hyphen_values = true)]
        cmd: Vec<String>,
    },

    /// Generate new projects from templates
    Hack(hack::Options),

    /// Search the pinned nixpkgs for packages matching REGEX
    #[command(long_about = search_long_about())]
    Search {
        /// A case-insensitive regex matched against attribute paths and package names
        regex: regex::Regex,
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
