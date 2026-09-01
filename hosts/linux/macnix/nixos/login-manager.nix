# Login / display manager for macnix.
#
# ┌─ useGreetd = true  → greetd (see `greeter` below)
# └─ useGreetd = false → GDM (the previous setup)
#
# greeter = "regreet"  → graphical GTK greeter, wallpaper + Tokyo-Night card
#         = "tuigreet"  → plain TTY greeter (lightest, always works)
#
# Getting GDM back if the greeter misbehaves:
#   * Fastest: reboot and pick the previous NixOS generation in the
#     bootloader menu — it still runs GDM. Nothing here is permanent until
#     you `nixos-switch` again.
#   * Permanent: set `useGreetd = false` below, then from a TTY
#     (Ctrl+Alt+F2, log in) run `nixos-switch`. TTY logins keep working
#     even if the greeter is completely broken.
#
# The Wayland session list (Hyprland, Hyprland (uwsm), Niri, Omarchy,
# GNOME) is the same regardless — all paths read
# services.displayManager.sessionPackages.

{ lib, pkgs, config, ... }:

let
  useGreetd = true;
  greeter = "regreet"; # "regreet" | "tuigreet"

  waylandSessions =
    "${config.services.displayManager.sessionData.desktops}/share/wayland-sessions";

  # Tokyo Night palette — matches the hyprlock screen and the omarchy theme.
  tn = {
    bg = "#1a1b26";
    bgHl = "#24283b";
    fg = "#c0caf5";
    accent = "#7aa2f7";
  };
in
{
  services.displayManager.defaultSession = "hyprland";

  # Keep the GNOME session selectable as a fallback. (Drop this line later
  # for a lighter closure once greetd feels solid — the session list still
  # has the tiling compositors without it.)
  services.desktopManager.gnome.enable = true;

  # GNOME would otherwise pull GDM back in as mkDefault.
  services.displayManager.gdm.enable = lib.mkForce (!useGreetd);

  services.greetd = lib.mkMerge [
    # Hand off straight from the Plymouth splash (see systemd block below).
    (lib.mkIf useGreetd { greeterManagesPlymouth = true; })

    # ── tuigreet ────────────────────────────────────────────────────────
    (lib.mkIf (useGreetd && greeter == "tuigreet") {
      enable = true;
      useTextGreeter = true;
      settings.default_session = {
        command = lib.concatStringsSep " " [
          "${pkgs.greetd.tuigreet}/bin/tuigreet"
          "--time"
          "--remember"
          "--remember-session"
          "--asterisks"
          "--theme 'border=blue;text=cyan;prompt=green;time=blue;action=blue;button=magenta;container=black;input=white'"
          "--greeting 'macnix'"
          "--sessions ${waylandSessions}"
        ];
        user = "greeter";
      };
    })
  ];

  # ── ReGreet (graphical) ─────────────────────────────────────────────────
  programs.regreet = lib.mkIf (useGreetd && greeter == "regreet") {
    enable = true;

    font = {
      package = pkgs.fira;
      name = "Fira Sans";
      size = 14;
    };
    cursorTheme = {
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
    };
    theme = {
      package = pkgs.gnome-themes-extra;
      name = "Adwaita-dark";
    };

    settings = {
      background = {
        path = ../hyprlock/key7.png;
        fit = "Cover";
      };
      GTK = {
        application_prefer_dark_theme = true;
        cursor_blink = true;
      };
      appearance.greeting_msg = "welcome back";
      widget.clock.format = "%A  %H:%M";
      commands = {
        reboot = [ "systemctl" "reboot" ];
        poweroff = [ "systemctl" "poweroff" ];
      };
    };

    # Frosted Tokyo-Night card over the wallpaper. Widget names are from
    # ReGreet 0.3.0's templates.rs (`frame.background` = the login card and
    # the clock bar; `#message_label` = the greeting).
    extraCss = ''
      /* solid dark on the toplevel so there's no white flash before the
         wallpaper Picture paints */
      window { background-color: ${tn.bg}; }

      frame.background {
        background-color: alpha(${tn.bg}, 0.60);
        border: 1px solid alpha(${tn.accent}, 0.35);
        border-radius: 18px;
        box-shadow: 0 18px 60px alpha(black, 0.55);
      }

      label { color: ${tn.fg}; }
      #message_label { color: ${tn.accent}; font-size: 13pt; }
      #error_info, #error_label { color: #f7768e; font-weight: 700; }

      entry, entry.password, .password, combobox, combobox button {
        background: alpha(${tn.bgHl}, 0.92);
        color: ${tn.fg};
        border: 1px solid alpha(${tn.accent}, 0.30);
        border-radius: 10px;
        min-height: 34px;
        padding: 4px 10px;
      }
      entry:focus, entry.password:focus, combobox:focus {
        border-color: ${tn.accent};
        box-shadow: 0 0 0 2px alpha(${tn.accent}, 0.35);
      }

      button {
        background: alpha(${tn.bgHl}, 0.92);
        color: ${tn.fg};
        border: 1px solid alpha(${tn.accent}, 0.30);
        border-radius: 10px;
        min-height: 34px;
        padding: 4px 14px;
      }
      button:hover { background: alpha(${tn.accent}, 0.28); }
      button.suggested-action {
        background: alpha(${tn.accent}, 0.90);
        color: ${tn.bg};
        font-weight: 700;
        border-color: transparent;
      }
      button.suggested-action:hover { background: ${tn.accent}; }
      button.destructive-action { color: #f7768e; }
    '';
  };

  security.pam.services.greetd.enableGnomeKeyring = lib.mkIf useGreetd true;

  # ── Clean handoff: no console text, no white flash ─────────────────────
  # greeterManagesPlymouth (set above) stops greetd waiting for
  # plymouth-quit-wait, which otherwise flashes the bare console before the
  # greeter. ExecStartPre tears the splash down right before greetd starts
  # the compositor, keeping the last frame on the fb (--retain-splash) so
  # there's no black/white gap.
  systemd.services.greetd = lib.mkIf useGreetd {
    serviceConfig = {
      ExecStartPre = "-${pkgs.plymouth}/bin/plymouth quit --retain-splash";
      # Keep greetd / cage / regreet stderr and any late boot logs off the
      # screen (the "debug text" before and after the login window).
      StandardError = "journal";
      TTYPath = "/dev/tty1";
      TTYReset = true;
      TTYVHangup = true;
      TTYVTDisallocate = true;
    };
  };
}
