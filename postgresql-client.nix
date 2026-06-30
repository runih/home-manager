{ pkgs, ... }:
let
  postgresClientRepo = pkgs.fetchFromGitHub {
    owner = "runih";
    repo = "postgresql-client";
    rev = "614e9d6a9bf28618724d0904a01c57d3eb55da04";
    hash = "sha256-ohYa+gFnBhUhrtup1fffl4OWjcjQ/oVgpI8m/hwWhLQ=";
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
