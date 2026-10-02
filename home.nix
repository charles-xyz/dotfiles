{ pkgs, ... }:

{
  home.username = "char";
  home.homeDirectory = "/Users/char";
  home.stateVersion = "24.11";

  home.packages = with pkgs; [
    wezterm
    neovim
  ];

  home.file.".wezterm.lua".source = ./config/wezterm/wezterm.lua;

  xdg.configFile."nvim" = {
    source = ./config/nvim;
    recursive = true;
  };

  programs.home-manager.enable = true;
}
