{ pkgs, inputs, ... }:
let
  pretty-folds = pkgs.vimUtils.buildVimPlugin {
    name = "vim-pretty-folds";
    src = inputs.vim-pretty-folds;
  };
in
{
    package = pkgs.neovim-nightly;

    luaLoader.enable = true;
    extraPlugins = with pkgs.vimPlugins; [
      vim-nix
      vim-rooter
      lexima-vim
      pretty-fold-nvim
      tabout-nvim
      litee-nvim
      litee-calltree-nvim
      litee-symboltree-nvim
      base16-nvim
      vim-airline-themes
      vim-localvimrc
      nvim-web-devicons
      {
        plugin = neo-tree-nvim;
        config = ''
          lua << EOF
            require("neo-tree").setup {
              enable_git_status = true,
              enable_diagnostics = true,

              filesystem = {
                follow_current_file = {
                  enabled = true,
                  leave_dirs_open = true,
                },
                group_empty_dirs = true,
                use_libuv_file_watcher = true,
              },

              buffers = {
                follow_current_file = {
                  enabled = true,
                  leave_dirs_open = true,
                },
              },
            }
          EOF
        '';
      }
      {
        plugin = hover-nvim;
        config = ''
          lua << EOF
            require("hover").setup {
              init = function()
              -- Require providers
              require("hover.providers.lsp")
              -- require('hover.providers.gh')
              -- require('hover.providers.gh_user')
              -- require('hover.providers.jira')
              -- require('hover.providers.man')
              -- require('hover.providers.dictionary')
              end,
              preview_opts = {
                border = 'single'
              },
              -- Whether the contents of a currently open hover window should be moved
              -- to a :h preview-window when pressing the hover keymap.
              preview_window = false,
              title = true,
            }

            -- Setup keymaps
            vim.keymap.set("n", "K", require("hover").hover, {desc = "hover.nvim"})
            vim.keymap.set("n", "gK", require("hover").hover_select, {desc = "hover.nvim (select)"})
            vim.keymap.set("n", "<C-p>", function() require("hover").hover_switch("previous") end, {desc = "hover.nvim (previous source)"})
            vim.keymap.set("n", "<C-n>", function() require("hover").hover_switch("next") end, {desc = "hover.nvim (next source)"})

            -- Mouse support
            vim.keymap.set('n', '<MouseMove>', require('hover').hover_mouse, { desc = "hover.nvim (mouse)" })
          EOF
        '';
      }
    ];

    clipboard.register = "unnamedplus";
    clipboard.providers.wl-copy.enable = true;

    autoCmd = [
      {
        event = "BufWritePre";
        callback = {
          __raw = ''
            function()
              local extension = "~" .. vim.fn.strftime("%Y-%m-%d-%H%M%S")
              vim.o.backupext = extension
            end
          '';
        };
      }
    ];

    keymaps = [
      {
        key = "<leader>op";
        action = "<cmd>Neotree toggle<cr>";
      }
      {
        key = "<leader>cx";
        action = "<cmd>Trouble<cr>";
      }
    ];

    # colorschemes.vscode.enable = true;
    colorschemes.catppuccin = {
      enable = true;
      settings = {
        transparent_background = true;
        flavour = "latte";
        term_colors = true;
        show_end_of_buffer = true;
      };
    };

    plugins = {
      lualine.enable = true;
      commentary.enable = true;
      cmp.enable = true;
      surround.enable = true;
      cmp-nvim-lsp.enable = true;
      cmp-nvim-lsp-document-symbol.enable = true;
      cmp-nvim-lsp-signature-help.enable = true;
      cmp-tabnine.enable = true;
      cmp.settings = {
        mapping = {
          __raw = ''
            cmp.mapping.preset.insert({
              ['<C-b>'] = cmp.mapping.scroll_docs(-4),
              ['<C-f>'] = cmp.mapping.scroll_docs(4),
              ['<C-Space>'] = cmp.mapping.complete(),
              ['<C-e>'] = cmp.mapping.abort(),
              ['<CR>'] = cmp.mapping.confirm({ select = true }),
            })
          '';
        };
        snippet = {
          expand = "function(args) require('luasnip').lsp_expand(args.body) end";
        };
        sources = [
          { name = "nvim_lsp"; }
          { name = "luasnip"; }
          { name = "path"; }
          { name = "buffer"; }
          { name = "nvim_lsp_document_symbol"; }
          { name = "nvim_lsp_signature_help"; }
          { name = "cmp_tabnine"; }
        ];
      };
      direnv.enable = true;
      fzf-lua.enable = true;
      fzf-lua.keymaps = {
        "<leader>ff" = {
          action = "files";
          options = {
            desc = "Fzf-Lua Files";
            silent = true;
          };
        };
        "<leader>ss" = {
          action = "blines";
          options = { desc = "Fzf-Lua Buffer Lines"; };
        };
        "<leader> " = {
          action = "git_files";
          options = { desc = "Fzf-Lua Git Files"; };
        };
        "<leader>sp" = {
          action = "live_grep";
          options = { desc = "Fzf-lua Live Grep"; };
        };
        "<leader>fr" = {
          action = "oldfiles";
          options = { desc = "Fzf-lua Oldfiles"; };
        };
        "<leader>bb" = {
          action = "buffers";
          options = { desc = "Fzf-lua Buffers"; };
        };
      };
      lastplace.enable = true;
      luasnip.enable = true;
      lsp = {
        enable = true;
        onAttach = ''
          if client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
            vim.lsp.inlay_hint.enable()
          end
        '';
        servers = {
          clangd.enable = true;
          cmake.enable = true;
          dockerls.enable = true;
          nixd.enable = true;
          pyright.enable = true;
          typst-lsp.enable = true;
          rust-analyzer = {
            enable = true;
            installCargo = true;
            installRustc = true;
          };
        };

        keymaps = {
          diagnostic = {
            "]]" = "goto_next";
            "[[" = "goto_prev";
          };
          lspBuf = {
            K = "hover";
            gD = "references";
            gd = "definition";
            gi = "implementation";
            gt = "type_definition";
          };
        };
      };
      lsp-format.enable = true;
      gitsigns.enable = true;
      trouble.enable = true;
      treesitter.enable = true;
      typst-vim.enable = true;

      which-key.enable = true;
      codeium-vim = {
        enable = true;
        keymaps = {
          accept = "<C-a>";
          complete = "<C-;>";
          prev = "<M-[";
          next = "<M-]";
        };
        settings = {
          disable_bindings = true;
          manual = true;
        };
      };
    };

    viAlias = true;
    vimAlias = true; # I use vim for non lsp configuration

    opts = {
      number = true; # Show line numbers
      relativenumber = true; # Show relative line numbers

      shiftwidth = 2; # Tab width should be 2
      guicursor = "n-v-c-i:block";
      cursorline = true;

      backupdir = [ "~/.cache/nvim/backup" "/tmp" ];
      directory = [ "~/.cache/nvim/swap" "/tmp" ];
      undodir = [ "~/.cache/nvim/undo" "/tmp" ];
      backup = true;
      undofile = true;
      swapfile = true;

      foldmethod = "expr";
      foldexpr = "nvim_treesitter#foldexpr()";
      foldenable = false;
    };

    globals = {
      mapleader = " ";
      rooter_patterns = [ ".git" "_darcs" ".hg" ".bzr" ".svn" "Makefile" "package.json" ".root" ".envrc" ];
    };

    extraConfigLuaPost = ''
      require('tabout').setup {
        tabkey = '<Tab>', -- key to trigger tabout, set to an empty string to disable
        backwards_tabkey = '<S-Tab>', -- key to trigger backwards tabout, set to an empty string to disable
        act_as_tab = true, -- shift content if tab out is not possible
        act_as_shift_tab = false, -- reverse shift content if tab out is not possible (if your keyboard/terminal supports <S-Tab>)
        default_tab = '<C-t>', -- shift default action (only at the beginning of a line, otherwise <TAB> is used)
        default_shift_tab = '<C-d>', -- reverse shift default action,
        enable_backwards = true, -- well ...
        completion = false, -- if the tabkey is used in a completion pum
        tabouts = {
          { open = "'", close = "'" },
          { open = '"', close = '"' },
          { open = '`', close = '`' },
          { open = '(', close = ')' },
          { open = '[', close = ']' },
          { open = '{', close = '}' }
        },
        ignore_beginning = true, --[[ if the cursor is at the beginning of a filled element it will rather tab out than shift the content ]]
        exclude = {} -- tabout will ignore these filetypes
      }

      -- configure the litee.nvim library
      require('litee.lib').setup({})
      -- configure litee-calltree.nvim
      require('litee.calltree').setup({})

      -- terminal
      vim.opt.shell='/usr/bin/env fish'

      -- configure codeium keymaps
      vim.keymap.set('i', '<C-;>', function () return vim.fn['codeium#CycleOrComplete']() end, {expr = true})
      vim.keymap.set('i', '<C-a>', function () return vim.fn['codeium#Accept']() end, {expr = true})

      -- configure tabby
      vim.o.showtabline = 2
      vim.api.nvim_set_keymap("n", "<leader><tab><tab>", ":tabs<cr>", { noremap = true })
      vim.api.nvim_set_keymap("n", "<leader><tab>c", ":$tabnew<CR>", { noremap = true })
      vim.api.nvim_set_keymap("n", "<leader><tab>n", ":$tabnew<CR>", { noremap = true })
      vim.api.nvim_set_keymap("n", "<leader><tab>d", ":tabclose<CR>", { noremap = true })
      vim.api.nvim_set_keymap("n", "<leader><tab>o", ":tabonly<CR>", { noremap = true })
      vim.api.nvim_set_keymap("n", "<leader><tab>j", ":tabn<CR>", { noremap = true })
      vim.api.nvim_set_keymap("n", "<leader><tab>k", ":tabp<CR>", { noremap = true })
      -- move current tab to previous position
      vim.api.nvim_set_keymap("n", "<leader><tab>h", ":-tabmove<CR>", { noremap = true })
      -- move current tab to next position
      vim.api.nvim_set_keymap("n", "<leader><tab>l", ":+tabmove<CR>", { noremap = true })
      for i = 1, 9 do
        vim.api.nvim_set_keymap("n", "<leader><tab>" .. i, ":tabn " .. i .. "<CR>", { noremap = true })
        vim.api.nvim_set_keymap("n", "<M-" .. i .. ">", ":tabn " .. i .. "<CR>", { noremap = true })
        vim.api.nvim_set_keymap("i", "<M-" .. i .. ">", "<C-O>:tabn " .. i .. "<CR>", { noremap = true })
      end

      -- configure neovide
      if vim.g.neovide then
        -- Put anything you want to happen only in Neovide here
        vim.g.neovide_cursor_animate_command_line = false
        vim.o.guifont = "0xProto Nerd Font Mono,LXGW WenKai Mono:h18:"
        vim.g.neovide_transparency = 0.9
        vim.g.neovide_input_ime = true
      end
    '';
}
