use std::process::Command;

/// Whether `HOMEBASE_DEBUG` is set to a non-empty value.
pub fn debug_enabled() -> bool {
    std::env::var_os("HOMEBASE_DEBUG").is_some_and(|v| !v.is_empty())
}

/// Print `command` to stderr in the style of bash `set -x`.
pub fn trace_command(command: &Command) {
    let words = std::iter::once(command.get_program())
        .chain(command.get_args())
        .map(|w| shell_quote(&w.to_string_lossy()))
        .collect::<Vec<_>>();
    eprintln!("+ {}", words.join(" "));
}

/// Quote `word` for display so it could be pasted into a shell.
fn shell_quote(word: &str) -> String {
    let safe = !word.is_empty()
        && word
            .chars()
            .all(|c| c.is_ascii_alphanumeric() || "-_./:=+@%,".contains(c));
    if safe {
        word.to_string()
    } else {
        format!("'{}'", word.replace('\'', r"'\''"))
    }
}

#[cfg(test)]
mod tests {
    use super::shell_quote;

    #[test]
    fn quoting() {
        assert_eq!(shell_quote("develop"), "develop");
        assert_eq!(
            shell_quote("/nix/store/x-bash/bin/bash"),
            "/nix/store/x-bash/bin/bash"
        );
        assert_eq!(shell_quote(""), "''");
        assert_eq!(shell_quote("a b"), "'a b'");
        assert_eq!(shell_quote("it's"), r"'it'\''s'");
    }
}
