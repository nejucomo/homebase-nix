//! Mark a directory as trusted in the Claude Code state, non-interactively.
//!
//! Claude Code records per-directory state under the `projects` key of its
//! global state file (`~/.claude.json`, or `$CLAUDE_CONFIG_DIR/.claude.json`),
//! keyed by absolute path. Accepting the "do you trust this folder?" dialog
//! sets `hasTrustDialogAccepted` to `true` there; this tool sets it directly
//! without running `claude`.

use std::fs;
use std::io::{ErrorKind, Write as _};
use std::path::{Path, PathBuf};

use clap::Parser;
use serde_json::{Map, Value};
use yaffa::WrapErr as _;

/// The project key Claude Code sets when the trust dialog is accepted.
const TRUST_KEY: &str = "hasTrustDialogAccepted";

fn main() -> yaffa::Result<()> {
    use yaffa::App as _;

    TrustApp.run_main()
}

#[derive(Copy, Clone, Debug, Default)]
struct TrustApp;

impl yaffa::App for TrustApp {
    type Options = Options;
}

impl yaffa::RunWith<Options> for TrustApp {
    fn run_with(self, opts: Options) -> yaffa::Result<()> {
        let dir = fs::canonicalize(&opts.path)
            .with_context(|| format!("failed to resolve {}", opts.path.display()))?;
        yaffa::ensure!(dir.is_dir(), "not a directory: {}", dir.display());
        let key = dir
            .to_str()
            .ok_or_else(|| yaffa::format_err!("path is not UTF-8: {}", dir.display()))?;

        let state_path = state_path()?;
        let mut state = read_state(&state_path)?;

        if mark_trusted(&mut state, key)? {
            write_state(&state_path, &state)?;
            println!("trusted {key}");
        } else {
            println!("already trusted {key}");
        }
        Ok(())
    }
}

/// Mark a directory as trusted in the Claude Code state, non-interactively.
#[derive(Debug, Parser)]
#[command(name = "claude-trust-dir", version)]
struct Options {
    /// The directory to trust
    #[arg(default_value = ".")]
    path: PathBuf,
}

/// The location of the Claude Code global state file.
fn state_path() -> yaffa::Result<PathBuf> {
    let dir = match std::env::var_os("CLAUDE_CONFIG_DIR").filter(|v| !v.is_empty()) {
        Some(dir) => PathBuf::from(dir),
        None => std::env::home_dir().ok_or_else(|| yaffa::format_err!("no home directory"))?,
    };
    let path = dir.join(".claude.json");

    // Write through a symlink to its target rather than replacing the link:
    match fs::canonicalize(&path) {
        Ok(target) => Ok(target),
        Err(e) if e.kind() == ErrorKind::NotFound => Ok(path),
        Err(e) => Err(e).with_context(|| format!("failed to resolve {}", path.display())),
    }
}

/// Read the state file, treating a missing file as an empty state.
fn read_state(path: &Path) -> yaffa::Result<Value> {
    match fs::read_to_string(path) {
        Ok(text) => serde_json::from_str(&text)
            .with_context(|| format!("failed to parse {}", path.display())),
        Err(e) if e.kind() == ErrorKind::NotFound => Ok(Value::Object(Map::new())),
        Err(e) => Err(e).with_context(|| format!("failed to read {}", path.display())),
    }
}

/// Set the trust flag for project `key`, returning whether `state` changed.
fn mark_trusted(state: &mut Value, key: &str) -> yaffa::Result<bool> {
    let project = state
        .as_object_mut()
        .ok_or_else(|| yaffa::format_err!("state is not a JSON object"))?
        .entry("projects")
        .or_insert_with(|| Value::Object(Map::new()))
        .as_object_mut()
        .ok_or_else(|| yaffa::format_err!("state `projects` is not a JSON object"))?
        .entry(key)
        .or_insert_with(|| Value::Object(Map::new()))
        .as_object_mut()
        .ok_or_else(|| yaffa::format_err!("state `projects[{key:?}]` is not a JSON object"))?;

    if project.get(TRUST_KEY) == Some(&Value::Bool(true)) {
        return Ok(false);
    }
    project.insert(TRUST_KEY.to_string(), Value::Bool(true));
    Ok(true)
}

/// Atomically replace the state file, keeping the existing file's permissions
/// (or owner-only permissions for a new file, as it may hold credentials).
fn write_state(path: &Path, state: &Value) -> yaffa::Result<()> {
    use std::os::unix::fs::PermissionsExt as _;

    let mut text = serde_json::to_string_pretty(state)?;
    text.push('\n');

    let perms = match fs::metadata(path) {
        Ok(md) => md.permissions(),
        Err(e) if e.kind() == ErrorKind::NotFound => fs::Permissions::from_mode(0o600),
        Err(e) => return Err(e).with_context(|| format!("failed to stat {}", path.display())),
    };

    let mut tmp_name = path.file_name().unwrap_or_default().to_os_string();
    tmp_name.push(format!(".claude-trust-dir.{}.tmp", std::process::id()));
    let tmp = path.with_file_name(tmp_name);

    let result = (|| -> yaffa::Result<()> {
        let mut f = fs::File::create(&tmp)?;
        f.set_permissions(perms)?;
        f.write_all(text.as_bytes())?;
        f.sync_all()?;
        fs::rename(&tmp, path)?;
        Ok(())
    })();
    if result.is_err() {
        let _ = fs::remove_file(&tmp);
    }
    result.with_context(|| format!("failed to write {}", path.display()))
}

#[cfg(test)]
mod tests {
    use super::*;
    use serde_json::json;

    #[test]
    fn creates_missing_entries() {
        let mut state = json!({});
        assert!(mark_trusted(&mut state, "/a").unwrap());
        assert_eq!(state, json!({"projects": {"/a": {TRUST_KEY: true}}}));
    }

    #[test]
    fn preserves_existing_fields() {
        let mut state = json!({"x": 1, "projects": {"/a": {"y": 2, TRUST_KEY: false}}});
        assert!(mark_trusted(&mut state, "/a").unwrap());
        assert_eq!(
            state,
            json!({"x": 1, "projects": {"/a": {"y": 2, TRUST_KEY: true}}})
        );
    }

    #[test]
    fn already_trusted_is_unchanged() {
        let mut state = json!({"projects": {"/a": {TRUST_KEY: true}}});
        assert!(!mark_trusted(&mut state, "/a").unwrap());
    }

    #[test]
    fn rejects_malformed_state() {
        assert!(mark_trusted(&mut json!([]), "/a").is_err());
        assert!(mark_trusted(&mut json!({"projects": 3}), "/a").is_err());
    }
}
