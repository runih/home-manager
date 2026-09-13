{ pkgs, username, homeDirectory, ... }:
{
  imports = [
    ./dotfiles.nix
    ./email-accounts.nix
    ./shell-programs.nix
  ];

  home = {
    # Define the username for the home configuration
    username = "${username}";

    # Specify the home directory path
    homeDirectory = "${homeDirectory}";

    # Set the default editor for the session
    sessionVariables = {
      EDITOR = "nvim";
      PG_PASS = "${homeDirectory}/.pgpass";
      PG_NETWORK = "docker_my_network";
      PG_HISTORY = "${homeDirectory}/.psql_history";
      FZF_DEFAULT_OPTS = "--bind=ctrl-j:down,ctrl-k:up";
    };
    # Add custom paths to the session's PATH environment variable
    sessionPath = [
      "${homeDirectory}/.nix-profile/bin"
      "${homeDirectory}/bin"
      "${homeDirectory}/.local/bin"
    ];

    # Specify the state version for compatibility
    stateVersion = "26.05";

    # List of packages to be installed for the user (see ./packages-user.nix)
    packages = import ./packages-user.nix { inherit pkgs; };
  };
}
