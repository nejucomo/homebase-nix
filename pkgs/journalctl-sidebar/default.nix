{ nixpkgs, ... }:
  let
    jqFmt = toString [
      "\((.__REALTIME_TIMESTAMP | tonumber) / 1000000 | todate)"
      "\(.SYSLOG_IDENTIFIER)"
      "priority:\(.PRIORITY)"
      "\(.USER_UNIT)\n"
      "\(.MESSAGE)\n"
    ];
    bash = "${nixpkgs.bash}/bin/bash";
    jq = "${nixpkgs.jq}/bin/jq";
  in
    writeScriptBin "journalctl-sidebar" ''
      #! ${bash}
      journalctl -f -o json | ${jq} -r '"${jqFmt}"'
    ''
