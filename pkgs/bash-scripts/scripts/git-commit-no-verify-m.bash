function main
{
  parse-args 'msg *opts' "$@"
  exec git commit --no-verify $opts -m "[no-verify] $msg"
}
