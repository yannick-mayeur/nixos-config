{ config, pkgs, harpoon, bat-catppuccin, ... }:

let
  harpoon2 = pkgs.vimUtils.buildVimPlugin {
    name = "harpoon";
    src = harpoon;
  };
in
{
  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "Hack" "DroidSansMono" ]; })
    comma
    htop
    lsd
    zoxide
    bat
    ripgrep
    fd
    jq
    gh
    thefuck
    fzf
    delta
    silver-searcher
    nixpkgs-fmt
    unstable.ruby_3_2
  ];

  programs.bat = {
    enable = true;
    config = {
      theme = "catppuccin";
    };
    themes = {
      catppuccin = {
        src = bat-catppuccin;
        file = "themes/Catppuccin Frappe.tmTheme";
      };
    };
  };

  programs.tmux = {
    enable = true;
    escapeTime = 10;
    keyMode = "vi";
    customPaneNavigationAndResize = true;
    mouse = true;
    terminal = "tmux-256color";
    tmuxinator.enable = true;
    extraConfig = ''
      set-option -sa terminal-features ',xterm-256color:RGB'
      bind C-b select-window -l
    '';
    plugins = with pkgs; [
      {
        plugin = tmux-catppuccin.tmuxPlugins.catppuccin;
        extraConfig = ''
          set -g @catppuccin_flavour 'frappe'

          set -g @catppuccin_window_right_separator "█ "
          set -g @catppuccin_window_number_position "right"
          set -g @catppuccin_window_middle_separator "  █"

          set -g @catppuccin_window_default_fill "number"

          set -g @catppuccin_window_current_fill "number"
          set -g @catppuccin_window_default_text "#W"
          set -g @catppuccin_window_current_text "#W"

          set -g @catppuccin_status_modules_right "directory user host date_time"
          set -g @catppuccin_status_left_separator  " "
          set -g @catppuccin_status_right_separator ""
          set -g @catppuccin_status_fill "icon"
          set -g @catppuccin_status_connect_separator "no"

          set -g @catppuccin_directory_text "#{pane_current_path}"
        '';
      }
    ];
  };

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
      catppuccin-nvim

      nvim-cmp

      nvim-treesitter.withAllGrammars
      comment-nvim
      nvim-surround
      vim-matchup

      lsp-zero-nvim
      lspkind-nvim
      nvim-lspconfig

      cmp-nvim-lsp
      luasnip

      copilot-lua
      copilot-cmp

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
      nodejs_21
      nodePackages.typescript
      nodePackages.typescript-language-server
      unstable.rubyPackages_3_2.solargraph
      unstable.rubyPackages_3_2.rubocop
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
