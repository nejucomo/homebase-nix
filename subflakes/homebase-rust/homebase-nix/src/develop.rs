use std::os::unix::process::CommandExt;
use std::process::Command;

use yaffa::WrapErr as _;

use crate::paths;
use crate::trace::trace_command;

/// Enter a `nix develop` interactive bash shell for the flake in the current
/// directory, optionally running `cmd` in it. On success this never returns
/// because the process is replaced via `exec`.
pub fn develop(cmd: &[String]) -> yaffa::Result<()> {
    let title = match cmd.first() {
        None => "nixdev".to_string(),
        Some(first) => format!("nixdev: {first}"),
    };

    if is_unset_or_empty("IN_NIX_SHELL") && !is_unset_or_empty("ZELLIJ") {
        rename_zellij_tab(&title)?;
    }

    let mut command = Command::new(paths::NIX);
    command.args(["develop", ".", "--command", paths::BASH]);
    if let Some(rcfile) = paths::DEV_SHELL_BASHRC {
        command.args(["--rcfile", rcfile]);
    }
    command.arg("-i");
    if !cmd.is_empty() {
        command.arg("-c").args(cmd);
    }

    // Always trace this command, as the original script did with `set -x`:
    trace_command(&command);
    let err = command.exec();
    Err(err).with_context(|| format!("failed to exec {}", paths::NIX))
}

fn rename_zellij_tab(title: &str) -> yaffa::Result<()> {
    let status = Command::new("zellij")
        .args(["action", "rename-tab", title])
        .status()
        .context("failed to run zellij")?;

    if !status.success() {
        yaffa::bail!("zellij action rename-tab failed: {status}");
    }
    Ok(())
}

fn is_unset_or_empty(var: &str) -> bool {
    std::env::var_os(var).is_none_or(|v| v.is_empty())
}
