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
      gruvbox

      nvim-treesitter
      nvim-treesitter-parsers.ruby
      nvim-treesitter-parsers.typescript
      nvim-treesitter-parsers.javascript
      nvim-treesitter-parsers.nix

      lsp-zero-nvim
      nvim-lspconfig
      nvim-cmp
      cmp-nvim-lsp

      vim-nix

      lightline-vim
      telescope-nvim
      vim-fugitive

      plenary-nvim
      harpoon2
    ];

    extraPackages = with pkgs; [
      nodePackages.typescript
      nodePackages.typescript-language-server
      solargraph
    ];

    extraLuaConfig = ''
      vim.cmd('colorscheme gruvbox')

      vim.g.mapleader = ' '
      vim.g.maplocalleader = ' '

      vim.g.hlsearch = true
      vim.keymap.set('n', '<cr>', ':noh<cr>')

      vim.o.number = true

      vim.o.tabstop = 4
      vim.o.shiftwidth = 4

      vim.keymap.set('c', '%%', '<C-R>=expand(\'%:h\').\'/\'<cr>')

      vim.keymap.set('n', '<leader>e', ':edit %%', { remap = true })

      vim.keymap.set('n', '<C-J>', '<C-W><C-J>')
      vim.keymap.set('n', '<C-K>', '<C-W><C-K>')
      vim.keymap.set('n', '<C-L>', '<C-W><C-L>')
      vim.keymap.set('n', '<C-H>', '<C-W><C-H>')

      vim.keymap.set({'n', 'v'}, '<leader>y', '"+y')
      vim.keymap.set({'n', 'v'}, '<leader>p', '"+p')
      vim.keymap.set({'n', 'v'}, '<leader>P', '"+P')

      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<leader>fj', builtin.find_files, {})
      vim.keymap.set('n', '<leader>fk', builtin.live_grep, {})
      vim.keymap.set('n', '<leader>fh', builtin.buffers, {})
      vim.keymap.set('n', '<leader>fl', builtin.help_tags, {})

      require'nvim-treesitter.configs'.setup {
        highlight = {
          enable = true,
          -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
          -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
          -- Using this option may slow down your editor, and you may see some duplicate highlights.
          -- Instead of true it can also be a list of languages
          additional_vim_regex_highlighting = false,
        },
      }

      local lsp_zero = require('lsp-zero')

      lsp_zero.on_attach(function(client, bufnr)
        lsp_zero.default_keymaps({buffer = bufnr})
      end)

      require('lspconfig').tsserver.setup({})
      require('lspconfig').solargraph.setup({})

      local cmp = require('cmp')
      local cmp_action = require('lsp-zero').cmp_action()
      
      cmp.setup({
        mapping = cmp.mapping.preset.insert({
          -- `Enter` key to confirm completion
          ['<CR>'] = cmp.mapping.confirm({select = false}),
      
          -- Ctrl+Space to trigger completion menu
          ['<C-Space>'] = cmp.mapping.complete(),
      
          -- Scroll up and down in the completion documentation
          ['<C-u>'] = cmp.mapping.scroll_docs(-4),
          ['<C-d>'] = cmp.mapping.scroll_docs(4),
        }),
      })

      local harpoon = require("harpoon")

      -- REQUIRED
      harpoon:setup()
      -- REQUIRED
      
      vim.keymap.set("n", "<leader>dj", function() harpoon:list():add() end)
      vim.keymap.set("n", "<leader>dk", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)
      vim.keymap.set("n", "<leader>dl", function() harpoon:list():clear() end)
      
      -- vim.keymap.set("n", "<leader>dy", function() harpoon:list():select(1) end)
      -- vim.keymap.set("n", "<leader>du", function() harpoon:list():select(2) end)
      -- vim.keymap.set("n", "<leader>di", function() harpoon:list():select(3) end)
      -- vim.keymap.set("n", "<leader>do", function() harpoon:list():select(4) end)
      
      -- Toggle previous & next buffers stored within Harpoon list
      vim.keymap.set("n", "<C-S-P>", function() harpoon:list():prev() end)
      vim.keymap.set("n", "<C-S-N>", function() harpoon:list():next() end)
    '';
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

