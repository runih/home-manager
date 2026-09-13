{ ... }:

# Personal email accounts (Thunderbird), split out of home.nix to keep
# that file focused on core `home.*` settings.
let
  mkOkkaraAccount = { primary ? false, realName, address, userName ? address }: {
    thunderbird = {
      enable = true;
      profiles = [ "default" ];
    };
    inherit primary realName address userName;
    imap = {
      host = "imap.websupport.se";
      tls.useStartTls = true;
    };
    smtp = {
      host = "smtp.websupport.se";
      tls.useStartTls = true;
    };
  };
in
{
  accounts.email.accounts = {
    "Okkara.NET" = mkOkkaraAccount {
      primary = true;
      realName = "Rúni H.Hansen";
      address = "runi.hansen@okkara.net";
    };
    "Admin" = mkOkkaraAccount {
      realName = "Admin";
      address = "admin@okkara.net";
    };
    "Tango" = mkOkkaraAccount {
      realName = "Tango";
      address = "tango@okkara.net";
    };
    "wilix" = mkOkkaraAccount {
      realName = "Rúni H.Hansen";
      address = "runi.hansen@wilix.com";
    };
  };
}
