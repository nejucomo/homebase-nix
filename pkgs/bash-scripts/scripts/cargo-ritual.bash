function main {
  while [ $# -gt 0 ]
  do
    ritual "$1"
  done
}

function ritual {
  parse-args 'path' "$@"
  local crate="${RITUAL_PREFIX:-}$(echo "$path" | sed 's|^\./||; s|/$||; s|/|-|g')"

  set -x
  cargo check -p "$crate"
  cargo doc -p "$crate" --open
  cargo test -p "$crate"
  cargo fmt -p "$crate" -- --check
  set +x
}

