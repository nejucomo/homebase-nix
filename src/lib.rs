//! A tool to generate new project dirs
#![feature(exit_status_error)]
#![forbid(unsafe_code)]
#![deny(missing_docs)]

mod app;
mod template;

pub mod options;
pub use crate::app::Hacknow;
pub use crate::template::Template;

/// Run the main process; the `hacknow` binary is a minimal delegation to this function
pub fn run() -> yaffa::Result<()> {
    use yaffa::App as _;

    Hacknow::run_main_default()
}

#[cfg(test)]
mod tests;
