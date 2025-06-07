# home-manager

My nix home manager setup

# experimental-features

The following experimental features is needed

```nix
nix.settings.experimental-features = [ "nix-command" "flakes" ];
```

Or add to `~/.config/nix/nix.conf`:

```nix
experimental-features = nix-command flakes
```

# usage

`home-manager` is not installed by default. Run the following command to start using `home-manager`:

```bash
nix-shell -p home-manager --run "home-manager switch --impure"
```

This will install Home Manager and apply your setup.

Afterwards, use `hm` to reapply your configuration at any time.
