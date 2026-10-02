{ pkgs, ... }:

{
  home.username = "sante";
  home.homeDirectory = "/Users/sante";
  home.stateVersion = "24.11";

  home.packages = with pkgs; [
    wezterm
    neovim
    ripgrep
    fd
    jq
    tree-sitter
  ];

  home.file.".wezterm.lua".source = ./config/wezterm/wezterm.lua;

  xdg.configFile."nvim" = {
    source = ./config/nvim;
    recursive = true;
  };

  programs.git = {
    enable = true;
    settings.user = {
      name = "Charles Lazaroni";
      email = "charles.lazaroni@santehq.com";
    };
  };

  programs.zsh = {
    enable = true;
    # Carried over from the old hand-written ~/.zshrc
    initContent = ''
      # Pi
      export PATH="$HOME/.pi/agent/bin:$PATH"

      export NVM_DIR="$HOME/.nvm"
      [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
      [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
      export PATH="$HOME/.local/bin:$PATH"
    '';
  };

  programs.starship.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.fzf.enable = true;

  programs.home-manager.enable = true;
}
