# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A single Nix flake that produces `home-manager` configurations for multiple personal machines (macOS and Linux, Intel/ARM). There is no application code, build step, or test suite — this is declarative dotfiles/environment config.

## Commands

Apply a configuration on the machine it belongs to:

```bash
home-manager switch --impure --flake ~/.config/home-manager#<name>
```

`<name>` must match one of the attribute names under `homeConfigurations` in the root `flake.nix` (e.g. `runih@BlackMac`, `runih@macnix`, `runih@nixos-pi5`, `minecraft@nixos-pi5`, `nas`). Note the `hm` shell alias defined in `zsh.nix` is hardcoded to `#nas` — it is only correct on the `nas` host; on every other host run the `switch` command above with the right `<name>` explicitly.

First-time bootstrap on a machine without home-manager installed:

```bash
nix-shell -p home-manager --run "home-manager switch --impure"
```

Requires flakes enabled (`nix.settings.experimental-features = [ "nix-command" "flakes" ];` or `experimental-features = nix-command flakes` in `~/.config/nix/nix.conf`).

To validate the flake without applying anything: `nix flake check`.

## Architecture

### Two-level flake composition

The root `flake.nix` does **not** reference the per-host flakes as flake inputs. Instead it uses a `callHost` helper that imports each `hosts/**/flake.nix` as a plain Nix file and calls its `outputs` function directly, passing in the root flake's own `nixpkgs`/`home-manager` (and per-host extras like `zen-browser` or `nixpkgs-unstable`) plus a dummy `self = {}`:

```nix
callHost = path: args:
  let flake = import path;
  in flake.outputs (args // { self = {}; });
```

This means:
- Every host `flake.nix` has its own `inputs` block (and some even have their own `flake.lock`, e.g. `hosts/mac/BlackMac`, `hosts/linux/macnix`) but **those inputs are ignored** when the config is built through the root flake — the root's versions of `nixpkgs`/`home-manager`/etc. are injected instead via `args`. The per-host `inputs` blocks only matter if that host's `flake.nix` is evaluated standalone.
- When adding a new input a host needs (e.g. `nixpkgs-unstable` for a specific package), it must be threaded through explicitly in the root `flake.nix`'s `let` block (see `macnixArgs`, `nasArgs`) and added to that host's `outputs` function signature — declaring it only in the host's own `inputs` is not sufficient.
- Each host's `outputs` function must accept exactly the args the root passes (`nixpkgs`, `home-manager`, plus whatever extras are merged into its `*Args` set).

### Host layout

- `hosts/mac/<HostName>/flake.nix` — macOS machines (`aarch64-darwin`), homeConfiguration name matches the mac hostname.
- `hosts/linux/<hostname>/flake.nix` — Linux machines, system is `x86_64-linux` or `aarch64-linux` depending on hardware (e.g. `nixos-pi5` is ARM). Some hosts define more than one `homeConfigurations` entry (e.g. `nixos-pi5` also defines a separate `minecraft` user config).
- Host `flake.nix` files build a `home-manager.lib.homeManagerConfiguration`, composing shared root-level `*.nix` modules with any host-specific modules that live next to it (e.g. `hosts/linux/macnix/home.nix`, `hyprland.nix`, `waybar.nix`).
- `username` and `homeDirectory` are passed into every module via `extraSpecialArgs` from the host `flake.nix` (usually derived from `builtins.getEnv "USER"`), not hardcoded in shared modules. `hosts/linux/nas/home.nix` and `hosts/linux/nas/flake.nix` are the exception — username/home directory are hardcoded there for the fixed NAS account.

### Shared root modules

The root-level `*.nix` files are mixins included a la carte by host flakes — there's no single "base" module every host uses. Notable groupings:
- `basic-linux.nix` / `basic-mac.nix` — core package set + `home.username`/`homeDirectory`/`stateVersion`, platform-specific.
- Terminal multiplexer: three variants exist (`tmux.nix`, `simple-tmux.nix`, `my-tmux.nix`) — pick the one already used by similar hosts, don't assume they're interchangeable.
- Terminal emulators: `wezterm.nix`, `foot.nix`, `ghostty.nix`.
- Editors: `vim.nix`, `neovim.nix`, `neovide.nix`.
- `niri.nix` and `hosts/linux/macnix/hyprland.nix`/`waybar.nix` — Linux Wayland compositor configs (macnix runs Hyprland with waybar + hyprlock, whose lockscreen background asset lives at `hosts/linux/macnix/hyprlock/key7.png`).
- `pass.nix`, `zoxide.nix`, `nerd-fonts.nix`, `java.nix`, `postgresql-client.nix`, `testssl.nix`, `yazi.nix` — single-purpose tool configs.
- `minecraft.nix` / `esh-minecraft.nix` — Minecraft-related setups for specific hosts.

### Unstable packages

A couple of hosts (`macnix`, `nas`) pull specific packages (`claude-code`, `gh`) from `nixpkgs-unstable` for latest versions while keeping the rest of the system on the pinned stable `nixpkgs` release. Pattern: import a separate `pkgs-unstable` set scoped to the host's system, then inject just the needed package via an inline `{ home.packages = [ pkgs-unstable.<pkg> ]; }` module rather than switching the whole host to unstable.

## Conventions

- Commit messages follow Conventional Commits with a host/scope prefix, e.g. `feat(macnix): ...`, `fix(nas): ...`, `feat(nix): ...`.
- `nixpkgs`/`home-manager` are pinned to a specific release branch (currently `nixos-26.05` / `release-26.05`) across root and host flakes — keep these in sync when bumping.
