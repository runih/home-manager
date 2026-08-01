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
      # GTK4 (4.20+/GNOME 49) dropped its built-in dead-key/compose fallback when no
      # IME is running, breaking things like the Swedish dead-key tilde in Ghostty.
      # Kitty/foot aren't GTK apps so they're unaffected. GTK_IM_MODULE=simple
      # restores basic dead-key handling without requiring ibus/fcitx.
      package = pkgs.symlinkJoin {
        name = "ghostty";
        paths = [ pkgs.ghostty ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/ghostty --set GTK_IM_MODULE simple
        '';
        passthru = { inherit (pkgs.ghostty) vim; };
      };
    };
  };
  xdg.configFile."ghostty/config".text = ''
    window-padding-color = background
    theme = Dark Pastel
    custom-shader = "shaders/cursor_blaze.glsl"
    background-opacity = 0.75
    macos-titlebar-style = hidden
    gtk-titlebar = false
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
