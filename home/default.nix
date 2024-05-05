{ config, pkgs, harpoon, ... }:

let
  harpoon2 = pkgs.vimUtils.buildVimPlugin {
    name = "harpoon";
    src = harpoon;
  };
in
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
    plugins = with pkgs.vimPlugins; [
      tokyonight-nvim

      nvim-treesitter.withAllGrammars
      comment-nvim

      lsp-zero-nvim
      nvim-lspconfig
      nvim-cmp
      cmp-nvim-lsp
      conform-nvim

      lualine-nvim
      telescope-nvim
      telescope-fzf-native-nvim
      vim-fugitive

      plenary-nvim
      harpoon2

      nvim-surround
      undotree

      vim-rails
    ];

    extraPackages = with pkgs; [
      nodePackages.typescript
      nodePackages.typescript-language-server
      rubyPackages_3_2.solargraph
      rubyPackages_3_2.rubocop
      vscode-langservers-extracted
      lua-language-server
      tree-sitter

    ];
  };

  home.file."./.config/nvim" = {
    source = ./common/nvim;
    recursive = true;
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

