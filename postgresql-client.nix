{ pkgs, ... }:
let
  postgresClientRepo = pkgs.fetchFromGitHub {
    owner = "runih";
    repo = "postgresql-client";
    rev = "954d60b031df7293de21761b9471ef22cbd800d2";
    hash = "sha256-UVPfKxepvDuqS2cRMnfMYoSHo9V2hNdLv/Nrbn6ycXg=";
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
