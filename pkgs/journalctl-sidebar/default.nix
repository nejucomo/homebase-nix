{ nixpkgs, writeScriptBin, pkgName, ... }:
  let
    jqFmt = toString [
      "\\((.__REALTIME_TIMESTAMP | tonumber) / 1000000 | todate)"
      "\\(.SYSLOG_IDENTIFIER)"
      "priority:\\(.PRIORITY)"
      "\\(.USER_UNIT)\\n"
      "\\(.MESSAGE)\\n"
    ];

    jq = "${nixpkgs.jq}/bin/jq";
  in
    writeScriptBin pkgName ''
      #! /bin/bash
      journalctl -f -o json | ${jq} -r '"${jqFmt}"'
    ''
