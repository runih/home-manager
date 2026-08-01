{ pkgs, ...}:
{
  home = {
    packages = with pkgs; [
      # Java and Maven packages
      maven
    ];

  };
  programs = {
    java = {
      enable = true;                  # Enable Java
    };
  };
}
