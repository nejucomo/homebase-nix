//! [clap] commandline option types
use std::path::PathBuf;

use clap::{Args, Parser, Subcommand};

use crate::Template;

/// Project templating / management system
#[derive(derive_more::Debug, Parser)]
pub struct Options {
    /// The [logging_options::StandardConsole] options
    #[debug(skip)]
    #[command(flatten)]
    pub logging: logging_options::StandardConsole,

    #[allow(missing_docs)]
    #[command(subcommand)]
    pub cmd: Command,
}

/// Required subcommand
#[derive(Debug, Subcommand)]
pub enum Command {
    /// List the available templates
    ListTemplates,

    #[allow(missing_docs)]
    New(NewOptions),
}

/// Create a new project
#[derive(Debug, Args)]
pub struct NewOptions {
    /// The template
    pub template: Template,

    /// The path to initialize
    pub dest: PathBuf,
}
