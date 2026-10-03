{ pkgs, lib, ... }:

let
  # GitHub account (added via `gh auth login`) used for github.com/santehq/*.
  santeUser = "charleslazaroni-sante";

  # Git credential helper that authenticates as the sante account regardless
  # of which account gh has active.
  santeGitCredential = pkgs.writeShellScript "git-credential-gh-sante" ''
    [ "$1" = get ] || exit 0
    token=$(${pkgs.gh}/bin/gh auth token --hostname github.com --user ${santeUser}) || exit 1
    echo username=${santeUser}
    echo password=$token
  '';

  # `gh` wrapper that mirrors the git routing below: a command that targets
  # github.com/santehq/* (via -R/--repo, GH_REPO, a santehq/... argument, or a
  # remote of the current repo) runs as the sante account; everything else runs
  # as gh's active (personal) account. Shadows pkgs.gh's bin/gh via hiPrio.
  ghAccountRouter = pkgs.writeShellScriptBin "gh" ''
    gh=${pkgs.gh}/bin/gh
    git=${pkgs.git}/bin/git

    # Already pinned to an account, or managing accounts: leave gh alone.
    if [ -n "''${GH_TOKEN-}" ] || [ -n "''${GITHUB_TOKEN-}" ] || [ "''${1-}" = auth ]; then
      exec "$gh" "$@"
    fi

    # Whole-argument shapes that point at santehq (repo, URL, or API path).
    is_sante() {
      case "$1" in
        santehq/*|github.com/santehq/*|https://github.com/santehq/*) return 0 ;;
        git@github.com:santehq/*|ssh://git@github.com/santehq/*) return 0 ;;
        repos/santehq/*|/repos/santehq/*|orgs/santehq|orgs/santehq/*) return 0 ;;
        /orgs/santehq|/orgs/santehq/*) return 0 ;;
      esac
      return 1
    }

    # An explicit target (-R/--repo, then GH_REPO) wins over everything else.
    repo=''${GH_REPO-}
    prev=
    for arg in "$@"; do
      case "$prev" in -R|--repo) repo=$arg ;; esac
      case "$arg" in --repo=*) repo=''${arg#--repo=} ;; -R?*) repo=''${arg#-R} ;; esac
      prev=$arg
    done

    use_sante=
    if [ -n "$repo" ]; then
      is_sante "$repo" && use_sante=1
    else
      for arg in "$@"; do
        is_sante "$arg" && use_sante=1
      done
      if [ -z "$use_sante" ]; then
        while read -r _ url; do
          is_sante "$url" && use_sante=1
        done < <("$git" config --get-regexp '^remote\..*\.url$' 2>/dev/null)
      fi
    fi

    if [ -n "$use_sante" ]; then
      token=$("$gh" auth token --hostname github.com --user ${santeUser}) || {
        echo "gh: no token for ${santeUser}; run 'gh auth login' as that account" >&2
        exit 1
      }
      export GH_TOKEN=$token
    fi
    exec "$gh" "$@"
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
    postgresql
    (lib.hiPrio ghAccountRouter)
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
