//! [clap] commandline option types
use std::path::PathBuf;

use clap::{Args, Subcommand};

use crate::hack::Template;

/// Generate new projects from templates
#[derive(derive_more::Debug, Args)]
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
