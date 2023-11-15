{ nixpkgs, pkgScript, ... }:
  let
    jqFmt = toString [
      "\\((.__REALTIME_TIMESTAMP | tonumber) / 1000000 | todate)"
      "\\(.SYSLOG_IDENTIFIER)"
      "priority:\\(.PRIORITY)"
      "\\(.USER_UNIT)"
      "\\(.MESSAGE)"
    ];

    jq = "${nixpkgs.jq}/bin/jq";
  in
    pkgScript ''
      #! /bin/bash
      journalctl -f -o json | ${jq} -r '"${jqFmt}"'
    ''
