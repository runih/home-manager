{ pkgs, ... }:

# Fetch the testssl.sh tool from GitHub at a specific revision
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
    # Add required packages to the user's environment
    packages = with pkgs; [
      openssl
    ];

    # Install testssl.sh as an executable in ~/bin
    file."bin/testssl" = {
      source = "${testssl}/testssl.sh";
      executable = true;
    };

    # Create a helper script 'showcrt' in ~/bin to display SSL certificates
    file."bin/showcrt" = {
      text = ''
      #!/usr/bin/env bash
      # Check if openssl is installed
      if ! command -v openssl >/dev/null 2>&1; then
        echo "Error: openssl is not installed."
        exit 1
      fi
      # Ensure a host argument is provided
      if [ -z "$1" ]; then
        echo "Usage: showcrt <host:port>"
        exit 1
      fi
      host_port="$1"
      # Default to port 443 if not specified
      if [[ "$host_port" != *:* ]]; then
        host_port="$host_port:443"
      fi
      # Display the SSL certificate using openssl
      echo | openssl s_client -connect "$host_port"
      '';
      executable = true;
    };
  };
}
