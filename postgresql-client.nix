{ pkgs, ... }:
let
  postgresClientRepo = pkgs.fetchFromGitHub {
    owner = "runih";
    repo = "postgresql-client";
    rev = "b16fec493718d58a844ba4e84fed935caafc39a8";
    hash = "sha256-+jK0S49Eb/paJhrNRt+FbesMhdpIIVLH7+yFVUpiPSQ=";
  };
  postgresWrapper = postgresClientRepo + "/scripts/command.sh";
  postgresClientMakeLink = postgresClientRepo + "/scripts/create_link.sh";
in
  {
  home.file = {
    "bin/psql-create-link".source = postgresClientMakeLink;
    "bin/psql".source = postgresWrapper;
    "bin/pg_dump".source = postgresWrapper;
    "bin/pg_restore".source = postgresWrapper;
  };
}
