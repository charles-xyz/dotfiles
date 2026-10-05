# Dotfiles configuration

- This repository (`~/Programming/dotfiles`) is the source of truth for this machine's Home Manager / Nix configuration. Do not edit the generated, read-only files in `~/.config` or the Nix store directly.
- Neovim configuration: `config/nvim/init.lua` (and `config/nvim/lazy-lock.json`), linked to `~/.config/nvim` by `home.nix`.
- WezTerm configuration: `config/wezterm/wezterm.lua`, linked to `~/.wezterm.lua` by `home.nix`.
- Other managed settings and installed packages (including shell, git, gh, and Neovim): `home.nix`; flake entry point: `flake.nix`.
- Apply changes from this repo with `home-manager switch --flake .#sante`, then verify the active configuration. Do not replace Home Manager symlinks with local copies.
