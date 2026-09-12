# AGENTS.md

Nix flake producing `home-manager` configs for multiple personal machines. No app code, no build/test suite — this is declarative dotfiles config. Full architecture details live in `CLAUDE.md`; read that before making structural changes. This file is just the quick-reference.

## Commands

- Apply a config: `home-manager switch --impure --flake ~/.config/home-manager#<name>` where `<name>` matches an attribute under `homeConfigurations` in root `flake.nix` (e.g. `runih@BlackMac`, `runih@macnix`, `runih@nixos-pi5`, `minecraft@nixos-pi5`, `nas`).
- The `hm` shell alias does this automatically as `#$USER@$(hostname)` (overridden to `#nas` on the `nas` host).
- Validate without applying: `nix flake check`.
- No unit tests exist — "testing" a change means running the switch command on the affected host (or at least `nix flake check`).

## Critical gotchas

- **Per-host `inputs` blocks in `hosts/**/flake.nix` are ignored** when built through the root flake — the root's `nixpkgs`/`home-manager`/`sharedModules` are injected via `callHost` instead. A new input for a host must be threaded through the root `flake.nix`'s `let` block (see `blackMacArgs`, `macnixArgs`, `nasArgs`, `pi5Args`) AND added to that host's `outputs` function signature — adding it only to the host's own `inputs` does nothing.
- Shared modules are registered in `modules/default.nix` (flat name → path, e.g. `m.vim`, `m.zsh`). New shared modules must be added there; hosts never reference module paths directly.
- `hosts/linux/macnix/nixos/` and `hosts/linux/nixos-pi5/nixos/` are **verbatim mirrors of those machines' `/etc/nixos`** (system-level NixOS config, not home-manager) — they are never imported by the root flake or `mkHome`. Apply macnix's with `nixos-switch` (never bare `sudo nixos-rebuild switch` — see CLAUDE.md for why). nixos-pi5 boots via a tryboot flow (`nixos-rebuild boot`, not activated live) — see CLAUDE.md before touching `tryboot.nix`.
- `nixpkgs`/`home-manager` are pinned to `nixos-26.05` across root and host flakes — keep in sync when bumping. `hosts/linux/macnix/nixos/flake.lock` also pins `nixpkgs-unstable` (Hyprland only) and must match the root flake's `nixpkgs-unstable` rev.
- A few hosts pull specific packages (`claude-code`, `gh`) from `nixpkgsUnstable` via an inline module (`home.packages = [ pkgsUnstable.claude-code ]`) rather than switching the whole host to unstable.

## Conventions

- Commit messages: Conventional Commits with host/scope prefix, e.g. `feat(macnix): ...`, `fix(nas): ...`, `feat(nix): ...`.
