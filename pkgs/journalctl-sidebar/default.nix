{ nixpkgs, ... }:
  let
    jqFmt = toString [
      "\\((.__REALTIME_TIMESTAMP | tonumber) / 1000000 | todate)"
      "\\(.SYSLOG_IDENTIFIER)"
      "priority:\\(.PRIORITY)"
      "\\(.USER_UNIT)\\n"
      "\\(.MESSAGE)\\n"
    ];

    inherit (nixpkgs) bash jq writeScriptBin;

  in
    writeScriptBin "journalctl-sidebar" ''
      #! ${bash}/bin/bash
      journalctl -f -o json | ${jq}/bin/jq -r '"${jqFmt}"'
    ''
