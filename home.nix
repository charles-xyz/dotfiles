{ pkgs, ... }:

let
  # Git credential helper that authenticates as the sante GitHub account
  # (added via `gh auth login`) regardless of which account gh has active.
  santeGitCredential = pkgs.writeShellScript "git-credential-gh-sante" ''
    [ "$1" = get ] || exit 0
    token=$(${pkgs.gh}/bin/gh auth token --hostname github.com --user charleslazaroni-sante) || exit 1
    echo username=charleslazaroni-sante
    echo password=$token
  '';
in
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
    python312
    uv
    bat
  ];


  home.file.".wezterm.lua".source = ./config/wezterm/wezterm.lua;

  xdg.configFile."nvim" = {
    source = ./config/nvim;
    recursive = true;
  };

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Charles Lazaroni";
        email = "charleslazaroni@gmail.com";
      };
      # github.com/santehq/* uses the sante account; every other GitHub URL
      # falls through to gh's active (personal) account via programs.gh below.
      credential."https://github.com/santehq".helper = [ "" "${santeGitCredential}" ];
    };

    # Repos whose remote is under santehq commit as the sante address;
    # everything else keeps the personal default above.
    includes = [
      {
        condition = "hasconfig:remote.*.url:https://github.com/santehq/**";
        contents.user.email = "charles.lazaroni@santehq.com";
      }
      {
        condition = "hasconfig:remote.*.url:git@github.com:santehq/**";
        contents.user.email = "charles.lazaroni@santehq.com";
      }
    ];
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

      # macOS path_helper puts /usr/bin first; make Nix-provided tools win
      export PATH="$HOME/.nix-profile/bin:$PATH"

      # Copy a file to the clipboard as a file (like Cmd+C in Finder)
      copyfile() {
        osascript -e "set the clipboard to (POSIX file \"$(realpath "$1")\")"
      }
    '';
  };

  # Also registers gh as git's credential helper for github.com
  programs.gh = {
    enable = true;
    settings.git_protocol = "https";
  };

  programs.starship.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.fzf.enable = true;

  programs.home-manager.enable = true;
}
