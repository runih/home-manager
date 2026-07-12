{ pkgs, ... }:
let
  postgresClientRepo = pkgs.fetchFromGitHub {
    owner = "runih";
    repo = "postgresql-client";
    rev = "c18cdecaa7a2e0c851bbfe6f8cf9ed91586e8725";
    hash = "sha256-dssf8PZVtvTnlPf0de7D0YanKEKn4Cr/lzeg+f6Uasg=";
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
