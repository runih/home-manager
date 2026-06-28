{ pkgs, ... }:
let
  postgresClientRepo = pkgs.fetchFromGitHub {
    owner = "runih";
    repo = "postgresql-client";
    rev = "819a70e51178166d11586c79b0121d5ba6ce1974";
    hash = "sha256-xE2vUKYIqU+vH6ztCNbp2TfKkEeKNalf6Ocgu/uSfd4=";
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
