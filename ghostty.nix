{ ... }:
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
    background-opacity = 0.75
    macos-titlebar-style = hidden
    cursor-color = #ff0000
    cursor-style-blink = true
    adjust-cursor-height = 30%
    font-family = "Iosevka Nerd Font Propo"
    font-size = 14
    keybind = global:shift+cmd+space=toggle_quick_terminal
    '';
}
