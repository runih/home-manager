{ pkgs, ... }:

let
  testssl = pkgs.fetchFromGitHub {
  owner = "testssl";
  repo = "testssl.sh";
  rev = "6a5a69fcfd24d9a8e5ea0c30991fa673b2005e07";
  hash = "sha256-vVIskTJe2hQVh+FIjbnCilO2bmxs5kJS29jsbBWUTrQ=";
};
in
{
  home = {
    packages = with pkgs; [
      openssl
    ];
    file."bin/testssl" = {
      source = "${testssl}/testssl.sh";
      executable = true;
    };
    file."bin/showcrt" = {
      text = ''
      #!/usr/bin/env bash
      if ! command -v openssl >/dev/null 2>&1; then
        echo "Error: openssl is not installed."
        exit 1
      fi
      if [ -z "$1" ]; then
        echo "Usage: showcrt <host:port>"
        exit 1
      fi
      host_port="$1"
      if [[ "$host_port" != *:* ]]; then
        host_port="$host_port:443"
      fi
      echo | openssl s_client -connect "$host_port"
      '';
      executable = true;
    };
  };
}
