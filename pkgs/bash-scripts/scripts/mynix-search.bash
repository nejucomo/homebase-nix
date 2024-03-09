JQ_EXPR='to_entries | .[] | "\(.value.pname) \(.value.version) \(.key) \(.value.description)"'

function main {
  exec nix search --json nixpkgs "$@" \
    | jq -r "$JQ_EXPR" \
    | column --table --table-columns-limit 4
}
