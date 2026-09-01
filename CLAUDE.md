# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A single Nix flake that produces `home-manager` configurations for multiple personal machines (macOS and Linux, Intel/ARM). There is no application code, build step, or test suite — this is declarative dotfiles/environment config.

## Commands

Apply a configuration on the machine it belongs to:

```bash
home-manager switch --impure --flake ~/.config/home-manager#<name>
```

`<name>` must match one of the attribute names under `homeConfigurations` in the root `flake.nix` (e.g. `runih@BlackMac`, `runih@macnix`, `runih@nixos-pi5`, `minecraft@nixos-pi5`, `nas`).

The `hm` shell alias (`modules/shells/zsh.nix`) runs `home-manager switch --impure --flake ~/.config/home-manager#$USER@$(hostname)`, which resolves correctly on any host where `$(hostname)` matches the flake attribute suffix. `hosts/linux/nas/home.nix` overrides it with `lib.mkForce` to hardcode `#nas`, since that host's `homeConfigurations` attribute is just `"nas"` (no `@hostname`).

First-time bootstrap on a machine without home-manager installed:

```bash
nix-shell -p home-manager --run "home-manager switch --impure"
```

Requires flakes enabled (`nix.settings.experimental-features = [ "nix-command" "flakes" ];` or `experimental-features = nix-command flakes` in `~/.config/nix/nix.conf`).

To validate the flake without applying anything: `nix flake check`.

## Architecture

### Two-level flake composition

The root `flake.nix` does **not** reference the per-host flakes as flake inputs. Instead it uses a `callHost` helper that imports each `hosts/**/flake.nix` as a plain Nix file and calls its `outputs` function directly, passing in the root flake's own `nixpkgs`/`home-manager`/`sharedModules` (and per-host extras like `zen-browser` or `nixpkgs-unstable`) plus a dummy `self = {}`:

```nix
callHost = path: args:
  let flake = import path;
  in flake.outputs (args // { self = {}; });
```

This means:
- Every host `flake.nix` has its own `inputs` block (and some even have their own `flake.lock`, e.g. `hosts/mac/BlackMac`, `hosts/linux/macnix`) but **those inputs are ignored** when the config is built through the root flake — the root's versions of `nixpkgs`/`home-manager`/etc. are injected instead via `args`. The per-host `inputs` blocks only matter if that host's `flake.nix` is evaluated standalone.
- When adding a new input a host needs (e.g. `nixpkgs-unstable` for a specific package), it must be threaded through explicitly in the root `flake.nix`'s `let` block (see `blackMacArgs`, `macnixArgs`, `nasArgs`, `pi5Args`) and added to that host's `outputs` function signature — declaring it only in the host's own `inputs` is not sufficient.
- Each host's `outputs` function must accept exactly the args the root passes (`nixpkgs`, `home-manager`, `sharedModules`, plus whatever extras are merged into its `*Args` set).

### Module registry and home builder

- `modules/default.nix` is a flat name → path registry of all shared modules, grouped by category (platform, shells, editors, terminals, tmux, desktop, tools, ai, gaming). The root flake imports it once as `sharedModules` and passes it to every host; each host binds it to `m` and picks modules by name (`m.vim`, `m.zsh`, ...). Adding a new shared module means creating the file under `modules/<category>/` and registering it here — hosts never reference module paths directly.
- `lib/mkHome.nix` is the shared `home-manager.lib.homeManagerConfiguration` builder every host calls. It takes `system`, `username`, `homeDirectory`, `modules`, optional `allowUnfree`, and optional `nixpkgsUnstable`. If `nixpkgsUnstable` is given, it imports that nixpkgs and exposes it to modules as `pkgsUnstable`. It sets `extraSpecialArgs = { inherit username homeDirectory pkgsUnstable; }`, which is how every module (shared or host-specific) receives `username`/`homeDirectory` — they are never hardcoded in shared modules. `hosts/linux/nas/home.nix` only differs in that its caller passes a Synology-specific `homeDirectory` prefix (`/var/services/homes/<user>` instead of `/home/<user>`); the username itself is still derived from `$USER` like every other host.

### Host layout

- `hosts/mac/<HostName>/flake.nix` — macOS machines (`aarch64-darwin`), homeConfiguration name matches the mac hostname.
- `hosts/linux/<hostname>/flake.nix` — Linux machines, system is `x86_64-linux` or `aarch64-linux` depending on hardware (e.g. `nixos-pi5` is ARM). Some hosts define more than one `homeConfigurations` entry (e.g. `nixos-pi5` also defines a separate `minecraft` user config).
- Host `flake.nix` files call `mkHome`, composing modules picked from the shared registry (`m.<name>`) with any host-specific `.nix` files that live next to it (e.g. `hosts/linux/macnix/home.nix`, `hyprland.nix`, `waybar.nix`, `theme-switcher.nix`, `theme-lib.nix`, `themes.nix`). `hosts/linux/nixos`, `nixos2`, and `madakara-nixos` are near-identical (separate physical/virtual Linux boxes), and are kept as independent host flakes rather than parameterized into one.

`hosts/linux/macnix/nixos/` is different from every other file next to it: it's a **verbatim mirror of that machine's `/etc/nixos`** (system-level NixOS config — bootloader, kernel modules, services, users, the custom out-of-tree `macbook12-audio.nix` speaker driver), not home-manager modules, and it is never imported by this flake or `mkHome`. `/etc/nixos` on macnix has no git remote, so its real files live here instead and get backed up with everything else. It has its own `flake.nix`/`flake.lock` pinning `nixpkgs` to `nixos-26.05` — the same release home-manager pins — so system packages and home-manager packages stay on matching library versions (a stray unpinned system config previously drifted onto rolling `nixos-unstable`, causing `fontconfig` schema-mismatch warnings during `hm` because home-manager's older pinned fontconfig couldn't parse config generated by the system's newer one).

Applied with `nixos-switch` (a `home.nix` shell alias for `sudo nixos-rebuild switch --flake ~/.config/home-manager/hosts/linux/macnix/nixos#macnix`), never a bare `sudo nixos-rebuild switch` — `/etc/nixos` intentionally has no `configuration.nix`/`flake.nix` of its own, since a shim there that just `import`s this repo's `flake.nix` fails (nix's flake front end needs a literal attribute set at the top of `flake.nix` to statically read `inputs` before evaluation, so that indirection errors with "must be an attribute set"; unlike the old classic `configuration.nix` shim, which worked fine since a plain NixOS module import has no such restriction). Edit the files here, they take effect on that machine's next `nixos-switch` without any copying step. Run `hosts/linux/macnix/nixos/clear-etc-nixos.sh` if `/etc/nixos` ever accumulates a stale `configuration.nix`/`flake.nix` (e.g. after cloning onto a fresh machine).

### Shared modules (`modules/`)

Mixins picked a la carte by host flakes via the registry in `modules/default.nix` — there's no single "base" every host uses. Notable groupings:
- `platform/` — `basic-linux.nix` / `basic-mac.nix` (core package set + `home.username`/`homeDirectory`/`stateVersion`), `imac.nix` (iMac-only extras), `allowUnfree.nix`.
- `tmux/` — three variants (`tmux.nix`, `simple-tmux.nix`, `my-tmux.nix`) that pull different config sources — pick the one already used by similar hosts, don't assume they're interchangeable.
- `terminals/` — `wezterm.nix`, `foot.nix`, `ghostty.nix`.
- `editors/` — `vim.nix`, `neovim.nix`, `neovide.nix`, `doom-emacs.nix` (clones/bootstraps Doom Emacs via `home.activation`, config files under `doom.d/`).
- `desktop/` — `niri.nix` (Wayland compositor config) and `nerd-fonts.nix`. `hosts/linux/macnix` additionally has its own Hyprland setup (`hyprland.nix` + `waybar.nix` + theme files) living next to its host flake rather than in `modules/`, and currently ships both `m.niri` and the host's Hyprland config side by side.

  `macnix` also has an experimental **Omarchy toggle**: `enableOmarchy` in `hosts/linux/macnix/flake.nix` (default `false`). When `true`, the hand-rolled desktop stack (`hyprland.nix` + `waybar.nix` + `theme-switcher.nix` + `desktop-local.nix` + `m.niri`) and the shared `ghostty`/`zsh`/`zoxide` modules are swapped out for [`omarchy-nix`](https://github.com/henrysipp/omarchy-nix)'s home-manager module. `omarchy-nix` is threaded from the root flake (`macnixArgs`) and only evaluated when the toggle is on. Its HM module assumes it runs as part of a NixOS system, so `hosts/linux/macnix/flake.nix` shims a minimal `_module.args.osConfig` (settings + `services.xserver.videoDrivers`). The lock-screen / wofi / wallpaper pieces that used to live in `home.nix` were split into `desktop-local.nix` so the toggle can drop them cleanly — with the toggle off the generated config is byte-identical to before. The system half is a separate opt-in: `enableOmarchy` in `hosts/linux/macnix/nixos/flake.nix` + the conflict notes in `hosts/linux/macnix/nixos/omarchy.nix`.
- `tools/`, `ai/` (`claude-code.nix`, `copilot-cli.nix` — these only manage `~/.claude`/`~/.copilot` settings/statusline, not the package itself, see below), `gaming/` (`minecraft.nix` / `esh-minecraft.nix`) — single-purpose configs.

### Unstable packages

A few hosts (`BlackMac`, `macnix`, `nas`, `nixos-pi5`) pull specific packages (`claude-code`, `gh`) from `nixpkgs-unstable` for latest versions while keeping the rest of the system on the pinned stable `nixpkgs` release. Pattern: `mkHome` is given `nixpkgsUnstable`, then the host's `modules` list includes an inline `({ pkgsUnstable, ... }: { home.packages = [ pkgsUnstable.claude-code ]; })` module rather than switching the whole host to unstable. This is also why `m.claude-code`/`m.copilot-cli` only configure settings files — the actual package is supplied separately by each host (from either `pkgsUnstable` or stable `pkgs`, host's choice).

## Conventions

- Commit messages follow Conventional Commits with a host/scope prefix, e.g. `feat(macnix): ...`, `fix(nas): ...`, `feat(nix): ...`.
- `nixpkgs`/`home-manager` are pinned to a specific release branch (currently `nixos-26.05` / `release-26.05`) across root and host flakes — keep these in sync when bumping.
