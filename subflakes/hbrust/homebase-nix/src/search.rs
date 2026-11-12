use std::collections::BTreeMap;
use std::io::Write;
use std::process::{Command, Stdio};

use anyhow::{Context, Result, bail};
use regex::{Regex, RegexBuilder};
use serde::Deserialize;

use crate::paths;
use crate::trace::{debug_enabled, trace_command};

/// A single entry of `nix search --json` output.
#[derive(Debug, Deserialize)]
struct Entry {
    pname: Option<String>,
    version: Option<String>,
    description: Option<String>,
}

/// Search the pinned nixpkgs for packages whose attribute path or package
/// name matches `pattern` (case-insensitive).
pub fn search(pattern: &str) -> Result<()> {
    let re = RegexBuilder::new(pattern)
        .case_insensitive(true)
        .build()
        .with_context(|| format!("invalid regex: {pattern:?}"))?;

    let mut command = Command::new(paths::NIX);
    command
        .args(["search", "--json", paths::NIXPKGS_REF, pattern])
        .stdin(Stdio::null())
        .stderr(Stdio::inherit());
    if debug_enabled() {
        trace_command(&command);
    }

    let output = command
        .output()
        .with_context(|| format!("failed to run {}", paths::NIX))?;
    if !output.status.success() {
        bail!("nix search failed: {}", output.status);
    }

    let entries: BTreeMap<String, Entry> = serde_json::from_slice(&output.stdout)
        .context("failed to parse `nix search --json` output")?;

    let mut stdout = std::io::stdout().lock();
    for line in render(&re, &entries) {
        stdout.write_all(line.as_bytes())?;
    }
    Ok(())
}

/// Render matching entries. `nix search` also matches descriptions, so this
/// narrows results to attribute path or package name matches.
fn render<'a>(
    re: &'a Regex,
    entries: &'a BTreeMap<String, Entry>,
) -> impl Iterator<Item = String> + 'a {
    entries.iter().filter_map(move |(key, entry)| {
        let attr = strip_system_prefix(key);
        let pname = entry.pname.as_deref().unwrap_or("");
        if !(re.is_match(attr) || re.is_match(pname)) {
            return None;
        }
        Some(format!(
            "* {attr} ({})\n  {}\n\n",
            entry.version.as_deref().unwrap_or(""),
            entry.description.as_deref().unwrap_or(""),
        ))
    })
}

/// Strip a leading `<output>.<system>.` such as `legacyPackages.x86_64-linux.`
fn strip_system_prefix(key: &str) -> &str {
    match key.splitn(3, '.').collect::<Vec<_>>().as_slice() {
        [_, _, rest] => rest,
        _ => key,
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn strips_prefix() {
        assert_eq!(
            strip_system_prefix("legacyPackages.x86_64-linux.python3Packages.foo"),
            "python3Packages.foo"
        );
        assert_eq!(strip_system_prefix("a.b"), "a.b");
    }

    #[test]
    fn filters_and_renders() {
        let json = r#"{
            "legacyPackages.aarch64-darwin.ripgrep": {"pname": "ripgrep", "version": "14.1.1", "description": "fast grep"},
            "legacyPackages.aarch64-darwin.other": {"pname": "other", "version": "1.0", "description": "mentions RipGrep"},
            "legacyPackages.aarch64-darwin.rg-alias": {"pname": "RIPGREP-all", "version": "0.1"}
        }"#;
        let entries: BTreeMap<String, Entry> = serde_json::from_str(json).unwrap();
        let re = RegexBuilder::new("ripgrep")
            .case_insensitive(true)
            .build()
            .unwrap();
        let out: String = render(&re, &entries).collect();
        assert_eq!(
            out,
            "* rg-alias (0.1)\n  \n\n* ripgrep (14.1.1)\n  fast grep\n\n"
        );
    }
}
