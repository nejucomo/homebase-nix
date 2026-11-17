//! The `hack` subcommand: generate new project dirs from templates

mod options;
mod template;

use std::path::Path;
use std::process::Command;

use logging_options::backend::Backend;

pub use self::options::Options;
use self::template::Template;

/// The hook script a template may provide, run in the new project dir after expansion
pub const INIT_SCRIPT_PATH: &str = ".hacknow/hooks/init";

/// Run the `hack` subcommand
pub fn run(opts: Options) -> yaffa::Result<()> {
    use self::options::{Command::*, NewOptions};

    log::debug!("initializing logging");
    env_logger::Logger::init_from_options(&opts.logging);
    log::debug!("initialized logging for {:#?}", opts);

    match opts.cmd {
        ListTemplates => {
            println!("{}", Template::describe_names());
            Ok(())
        }
        New(NewOptions { template, dest }) => expand_and_init(template, &dest),
    }
}

fn expand_and_init(template: Template, dest: &Path) -> yaffa::Result<()> {
    template.expand_into(dest)?;
    run_init_script(dest)?;
    Ok(())
}

fn run_init_script(dest: &Path) -> yaffa::Result<()> {
    let pb = dest.join(INIT_SCRIPT_PATH);

    if pb.is_file() {
        log::info!("in {:?} executing {:?}", dest.display(), pb.display());
        set_executable_permissions(&pb)?;
        let relpath = pb.strip_prefix(dest)?;
        let mut cmd = Command::new(relpath);
        cmd.current_dir(dest);

        log::debug!("Running: {cmd:?}");
        cmd.status()?.exit_ok()?;
    } else {
        log::debug!("hook script {:?} not found.", pb.display());
    }
    Ok(())
}

fn set_executable_permissions(bin: &Path) -> yaffa::Result<()> {
    use std::os::unix::fs::PermissionsExt;

    const USER_EXECUTABLE_MASK: u32 = 0o100;

    let mut perms = fs_err::metadata(bin)?.permissions();
    if perms.mode() & USER_EXECUTABLE_MASK == 0 {
        log::debug!("setting exec bit (0o100) on {:?}", bin.display());

        perms.set_mode(perms.mode() | 0o111);
        fs_err::set_permissions(bin, perms)?;
    }
    Ok(())
}

#[cfg(test)]
mod tests;
