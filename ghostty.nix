{ ... }:
{
  nixpkgs.config.allowBroken = true;  # Allow broken packages.
   programs.ghostty = {
     enable = true;
     settings = {
       window-padding-color = "background";
       theme = "Dark Pastel";
       background-opacity = "0.75";
       macos-titlebar-style = "hidden";
       cursor-color = "#ffff00";
       cursor-style-blink = true;
       adjust-cursor-height = "30%";
       font-family = "Iosevka Nerd Font Mono";
       font-size = 18;
       keybind = "global:shift+cmd+space=toggle_quick_terminal";
     };
   };
}
