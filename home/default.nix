{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "yannick";
  home.homeDirectory = "/home/yannick";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    comma
    yazi
    htop
    lsd
    zoxide
    bat
    ripgrep
    jq
    gh
    thefuck
    fzf
    delta
    silver-searcher
  ];

  programs.zsh = {
    enable = true;
    initExtra = ''
      alias ls='lsd'

      eval "$(zoxide init zsh)"
    '';
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "thefuck" ];
      theme = "robbyrussell";
    };
  };

  programs.helix = {
    enable = true;
    settings = {
      theme = "gruvbox";
      keys = {
        normal = {
          C-h = "jump_view_left";
          C-j = "jump_view_down";
          C-k = "jump_view_up";
          C-l = "jump_view_right";
          space = {
            space = "goto_last_accessed_file";
          };
        };
      };
    };
  };

  programs.neovim = {
    enable = true;
    vimAlias = true;
    extraConfig = builtins.readFile ./vim/extraConfig.vim;
    plugins = with pkgs.vimPlugins; [
      vim-sensible

      vim-nix
      vim-eunuch

      fzf-vim
      zoxide-vim
      vim-fugitive
      vim-commentary
      vim-surround
      vim-endwise
      vim-signature
      vim-dispatch

      lightline-vim
      gruvbox
    ];
  };

  programs.git = {
    enable = true;
    userName = "Yannick Mayeur";
    userEmail = "yannick.mayeur@proton.me";
    delta.enable = true;
    extraConfig = {
      init.defaultBranch = "main";
      delta = {
        navigate = true;
        side-by-side = true;
      };
    };
  };

  home.sessionVariables = {
    EDITOR = "vim";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}

