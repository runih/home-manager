{ ... }:

# Misc dotfiles dropped into $HOME via home.file. Split out of home.nix to
# keep that file focused on core `home.*` settings.
{
  home.file = {
    # Force zen-beta to use VA-API hardware video decode and skip AV1 (this
    # Kaby Lake iGPU has no AV1 decode block, so it'd fall back to slow
    # software decode) in favor of VP9, which is hardware-accelerated.
    # NOTE: targets the existing profile dir by its randomly-generated name
    # (see ~/.config/zen/profiles.ini) — won't apply to a freshly created
    # profile without updating this path.
    ".config/zen/dwdoa3o0.Default Profile/user.js".text = ''
      user_pref("media.hardware-video-decoding.force-enabled", true);
      user_pref("media.ffmpeg.vaapi.enabled", true);
      user_pref("media.av1.enabled", false);
    '';

    # Custom Compose sequences (Right Alt is the compose key, set via
    # kb_options = "...,compose:ralt" in hyprland.nix). "%L" pulls in the
    # locale's stock Compose table; the previous copy of this file (dropped
    # by some prior omarchy-* tool run, not managed by this repo) instead
    # included "/usr/share/omarchy/default/xcompose", a path that doesn't
    # exist on this machine — that dangling include made xkbcommon fail to
    # parse the file entirely, which crashed wezterm on startup as soon as
    # the compose key was wired up.
    ".XCompose".text = ''
      include "%L"

      # Identification
      <Multi_key> <space> <n> : ""
      <Multi_key> <space> <e> : ""
    '';

    ".config/wireplumber/wireplumber.conf.d/51-macbook-cs4208-softvol.conf".text = ''
      monitor.alsa.rules = [
        {
          matches = [ { device.name = "alsa_card.pci-0000_00_1f.3" } ]
          actions = { update-props = { api.alsa.soft-mixer = true } }
        }
      ]
    '';
  };
}
