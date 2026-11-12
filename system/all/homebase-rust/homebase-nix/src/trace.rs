use std::process::Command;

/// Whether `HOMEBASE_DEBUG` is set to a non-empty value.
pub fn debug_enabled() -> bool {
    std::env::var_os("HOMEBASE_DEBUG").is_some_and(|v| !v.is_empty())
}

/// Print `command` to stderr in the style of bash `set -x`.
pub fn trace_command(command: &Command) {
    eprintln!("HOMEBASE_DEBUG: {command:?}");
}
