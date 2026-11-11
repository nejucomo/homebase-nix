use std::path::Path;
use std::process::Command;

use logging_options::backend::Backend;
use yaffa::{App, RunWith};

use crate::Template;
use crate::options::Options;

pub const INIT_SCRIPT_PATH: &str = ".hacknow/hooks/init";

/// A [yaffa::App] for the `hacknow` binary and utility library
#[derive(Copy, Clone, Debug, Default)]
pub struct Hacknow;

impl App for Hacknow {
    type Options = Options;
}

impl RunWith<Options> for Hacknow {
    fn run_with(self, opts: Options) -> yaffa::Result<()> {
        use crate::options::{Command::*, NewOptions};

        log::debug!("initializing logging");
        env_logger::Logger::init_from_options(&opts.logging);
        log::debug!("initialized logging for {:#?}", opts);

        match opts.cmd {
            ListTemplates => {
                println!("{}", Template::describe_names());
                Ok(())
            }
            New(NewOptions { template, dest }) => Hacknow.expand_and_init(template, &dest),
        }
    }
}

impl Hacknow {
    fn expand_and_init(self, template: Template, dest: &Path) -> yaffa::Result<()> {
        template.expand_into(dest)?;
        self.run_init_script(dest)?;
        Ok(())
    }

    fn run_init_script(&self, dest: &Path) -> yaffa::Result<()> {
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
