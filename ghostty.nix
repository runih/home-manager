{ pkgs, ... }:
let
ghostty-shaders = pkgs.fetchFromGitHub {
  owner = "0xhckr";
  repo = "ghostty-shaders";
  rev = "aa6121ba2ddd5251ac75b92729c758fe41256e55";
  hash = "sha256-2AeIjV59d/a+JdEbcPT1dLfUVdegRYIyFLI55daZ0LI=";
};
in
{
  programs = {
    ghostty = {
      enable = true;
      enableZshIntegration = true;
      installVimSyntax = true;
    };
  };
  xdg.configFile."ghostty/config".text = ''
    window-padding-color = background
    theme = Dark Pastel
    custom-shader = shaders/cursor_blaze.glsl
    #custom-shader = shaders/cubes.glsl
    background-opacity = 0.75
    macos-titlebar-style = hidden
    cursor-color = #ffff00
    cursor-style-blink = true
    cursor-style = block
    adjust-cursor-height = 30%
    font-family = "Iosevka Nerd Font Propo"
    font-size = 14
    keybind = global:shift+cmd+space=toggle_quick_terminal
    keybind = global:shift+ctrl+r=reload_config
    '';
  xdg.configFile."ghostty/shaders" = {
    source = ghostty-shaders;
    recursive = true;
  };
}
