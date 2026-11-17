//! Shell completion script generation, via [clap_complete].
//!
//! Intended usage: `eval "$(homebase-nix shcomp)"`

use std::path::Path;

use yaffa::WrapErr as _;
use clap_complete::Shell;
use sysinfo::{Pid, ProcessRefreshKind, ProcessesToUpdate, System};

/// Print a completion script for `shell`, or else for the shell detected as
/// our parent process.
pub fn shcomp<C: clap::CommandFactory>(shell: Option<Shell>) -> yaffa::Result<()> {
    let shell = match shell {
        Some(shell) => shell,
        None => detect_parent_shell()?,
    };

    let mut cmd = C::command();
    let name = cmd.get_name().to_string();
    clap_complete::generate(shell, &mut cmd, name, &mut std::io::stdout());
    Ok(())
}

/// Detect the shell of our parent process.
///
/// Within `eval "$(homebase-nix shcomp)"` the parent is the (forked) shell
/// running the command substitution.
fn detect_parent_shell() -> yaffa::Result<Shell> {
    let ppid = Pid::from_u32(std::os::unix::process::parent_id());

    let mut sys = System::new().wrap_err("failed to inspect processes")?;
    sys.refresh_processes_specifics(
        ProcessesToUpdate::Some(&[ppid]),
        false,
        ProcessRefreshKind::nothing().with_exe(sysinfo::UpdateKind::OnlyIfNotSet),
    );

    let Some(proc) = sys.process(ppid) else {
        yaffa::bail!("could not inspect parent process {ppid}; pass SHELL explicitly");
    };

    // Prefer the executable path, falling back to the process name; login
    // shells may be named with a leading `-`, as in `-bash`.
    let candidates = proc
        .exe()
        .map(|p| p.as_os_str().to_owned())
        .into_iter()
        .chain([proc.name().to_owned()]);

    for candidate in candidates {
        let candidate = candidate.to_string_lossy();
        let candidate = candidate.trim_start_matches('-');
        if let Some(shell) = Shell::from_shell_path(Path::new(candidate)) {
            return Ok(shell);
        }
    }

    yaffa::bail!(
        "parent process {ppid} ({:?}) is not a recognized shell; pass SHELL explicitly",
        proc.name(),
    )
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn parses_login_shell_name() {
        let name = "-bash".trim_start_matches('-');
        assert_eq!(Shell::from_shell_path(Path::new(name)), Some(Shell::Bash));
    }
}
