{ config, pkgs, ... }:

let
  neovimConfig = pkgs.writeText "init.lua" ''
    -- Basic settings
    vim.g.mapleader = " "
    vim.g.maplocalleader = " "

    vim.opt.number = true
    vim.opt.relativenumber = true
    vim.opt.mouse = "a"
    vim.opt.ignorecase = true
    vim.opt.smartcase = true
    vim.opt.hlsearch = false
    vim.opt.wrap = false
    vim.opt.tabstop = 4
    vim.opt.shiftwidth = 4
    vim.opt.expandtab = true
    vim.opt.termguicolors = true
    vim.opt.signcolumn = "yes"
    vim.opt.updatetime = 250
    vim.opt.clipboard = "unnamedplus"

    -- Bootstrap lazy.nvim plugin manager
    local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
    if not vim.loop.fs_stat(lazypath) then
      vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
      })
    end
    vim.opt.rtp:prepend(lazypath)

    -- Plugin specifications
    require("lazy").setup({
      -- Colorscheme
      {
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000,
        config = function()
          require("tokyonight").setup({
            style = "night",
            transparent = false,
          })
          vim.cmd([[colorscheme tokyonight]])
        end,
      },

      -- File explorer
      {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        dependencies = {
          "nvim-lua/plenary.nvim",
          "nvim-tree/nvim-web-devicons",
          "MunifTanjim/nui.nvim",
        },
        config = function()
          require("neo-tree").setup({
            close_if_last_window = true,
            window = {
              width = 30,
            },
            filesystem = {
              follow_current_file = {
                enabled = true,
              },
              filtered_items = {
                hide_dotfiles = false,
                hide_gitignored = false,
              },
            },
          })
          vim.keymap.set("n", "<leader>e", ":Neotree toggle<CR>", { silent = true })
        end,
      },

      -- Fuzzy finder
      {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
          require("telescope").setup({})
          local builtin = require("telescope.builtin")
          vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
          vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})
          vim.keymap.set("n", "<leader>fb", builtin.buffers, {})
        end,
      },

      -- Git integration
      {
        "lewis6991/gitsigns.nvim",
        config = function()
          require("gitsigns").setup({
            signs = {
              add = { text = "│" },
              change = { text = "│" },
              delete = { text = "_" },
              topdelete = { text = "‾" },
              changedelete = { text = "~" },
            },
            current_line_blame = true,
            current_line_blame_opts = {
              delay = 300,
            },
          })
        end,
      },

      -- LSP Configuration
      {
        "neovim/nvim-lspconfig",
        dependencies = {
          "williamboman/mason.nvim",
          "williamboman/mason-lspconfig.nvim",
        },
        config = function()
          require("mason").setup()
          require("mason-lspconfig").setup({
            ensure_installed = { "rust_analyzer", "pyright" },
            automatic_installation = true,
          })

          -- Use modern vim.lsp.config API
          local configs = require("lspconfig.configs")
          
          -- Rust Analyzer
          vim.lsp.config("rust_analyzer", {
            cmd = { "rust-analyzer" },
            filetypes = { "rust" },
            root_markers = { "Cargo.toml" },
            settings = {
              ["rust-analyzer"] = {
                cargo = {
                  allFeatures = true,
                },
                checkOnSave = {
                  command = "clippy",
                },
              },
            },
          })

          -- Pyright
          vim.lsp.config("pyright", {
            cmd = { "pyright-langserver", "--stdio" },
            filetypes = { "python" },
            root_markers = { "pyproject.toml", "setup.py", "requirements.txt", ".git" },
          })

          -- Enable LSP servers
          vim.lsp.enable("rust_analyzer")
          vim.lsp.enable("pyright")

          -- Keybindings for LSP
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, {})
          vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, {})
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, {})
        end,
      },

      -- Autocompletion
      {
        "hrsh7th/nvim-cmp",
        dependencies = {
          "hrsh7th/cmp-nvim-lsp",
          "hrsh7th/cmp-buffer",
          "hrsh7th/cmp-path",
          "L3MON4D3/LuaSnip",
          "saadparwaiz1/cmp_luasnip",
        },
        config = function()
          local cmp = require("cmp")
          local luasnip = require("luasnip")

          cmp.setup({
            snippet = {
              expand = function(args)
                luasnip.lsp_expand(args.body)
              end,
            },
            mapping = cmp.mapping.preset.insert({
              ["<C-b>"] = cmp.mapping.scroll_docs(-4),
              ["<C-f>"] = cmp.mapping.scroll_docs(4),
              ["<C-Space>"] = cmp.mapping.complete(),
              ["<C-e>"] = cmp.mapping.abort(),
              ["<CR>"] = cmp.mapping.confirm({ select = true }),
              ["<Tab>"] = cmp.mapping(function(fallback)
                if cmp.visible() then
                  cmp.select_next_item()
                else
                  fallback()
                end
              end, { "i", "s" }),
            }),
            sources = cmp.config.sources({
              { name = "nvim_lsp" },
              { name = "luasnip" },
            }, {
              { name = "buffer" },
              { name = "path" },
            }),
          })
        end,
      },

      -- Statusline
      {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
          require("lualine").setup({
            options = {
              theme = "tokyonight",
              component_separators = { left = "|", right = "|" },
              section_separators = { left = "", right = "" },
            },
            sections = {
              lualine_a = { "mode" },
              lualine_b = { "branch", "diff", "diagnostics" },
              lualine_c = { "filename" },
              lualine_x = { "encoding", "fileformat", "filetype" },
              lualine_y = { "progress" },
              lualine_z = { "location" },
            },
          })
        end,
      },

      -- Treesitter for better syntax highlighting
      {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
          require("nvim-treesitter.configs").setup({
            ensure_installed = { "rust", "python", "lua", "vim" },
            highlight = { enable = true },
            indent = { enable = true },
          })
        end,
      },

      -- Which-key to show keybindings
      {
        "folke/which-key.nvim",
        event = "VeryLazy",
        config = function()
          require("which-key").setup({})
        end,
      },

      -- Commenting plugin
      {
        "numToStr/Comment.nvim",
        config = function()
          require("Comment").setup()
        end,
      },
    })

    -- Open Neo-tree on startup
    vim.api.nvim_create_autocmd("VimEnter", {
      callback = function()
        if vim.fn.argc() == 0 then
          vim.cmd("Neotree show")
        end
      end,
    })

    -- Simple terminal toggle with Ctrl+\
    vim.keymap.set("n", "<C-\\>", function()
      vim.cmd("botright 15split | terminal")
      vim.cmd("startinsert")
    end, { noremap = true, silent = true })
    
    -- Close terminal with Ctrl+\ when in terminal mode
    vim.keymap.set("t", "<C-\\>", "<C-\\><C-n>:q<CR>", { noremap = true, silent = true })
    
    -- Exit terminal mode with Esc
    vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { noremap = true, silent = true })

    -- Window navigation with Ctrl + arrow keys
    vim.keymap.set("n", "<C-Left>", "<C-w>h", { noremap = true, silent = true })
    vim.keymap.set("n", "<C-Down>", "<C-w>j", { noremap = true, silent = true })
    vim.keymap.set("n", "<C-Up>", "<C-w>k", { noremap = true, silent = true })
    vim.keymap.set("n", "<C-Right>", "<C-w>l", { noremap = true, silent = true })
    
    -- Window navigation from terminal mode
    vim.keymap.set("t", "<C-Left>", "<C-\\><C-n><C-w>h", { noremap = true, silent = true })
    vim.keymap.set("t", "<C-Down>", "<C-\\><C-n><C-w>j", { noremap = true, silent = true })
    vim.keymap.set("t", "<C-Up>", "<C-\\><C-n><C-w>k", { noremap = true, silent = true })
    vim.keymap.set("t", "<C-Right>", "<C-\\><C-n><C-w>l", { noremap = true, silent = true })

    -- Modern editor keybinds
    -- Ctrl+A to select all
    vim.keymap.set("n", "<C-a>", "ggVG", { noremap = true, silent = true })
    
    -- Ctrl+S to save
    vim.keymap.set("n", "<C-s>", ":w<CR>", { noremap = true, silent = true })
    vim.keymap.set("i", "<C-s>", "<Esc>:w<CR>a", { noremap = true, silent = true })
    
    -- Ctrl+Z to undo
    vim.keymap.set("n", "<C-z>", "u", { noremap = true, silent = true })
    vim.keymap.set("i", "<C-z>", "<Esc>ua", { noremap = true, silent = true })
    
    -- Ctrl+Y to redo
    vim.keymap.set("n", "<C-y>", "<C-r>", { noremap = true, silent = true })
    vim.keymap.set("i", "<C-y>", "<Esc><C-r>a", { noremap = true, silent = true })
    
    -- Ctrl+F to find in file
    vim.keymap.set("n", "<C-f>", "/", { noremap = true })
    
    -- Ctrl+D to duplicate line
    vim.keymap.set("n", "<C-d>", "yyp", { noremap = true, silent = true })
    vim.keymap.set("i", "<C-d>", "<Esc>yypa", { noremap = true, silent = true })
    
    -- Ctrl+/ to toggle comment (requires commenting plugin)
    vim.keymap.set("n", "<C-_>", "gcc", { noremap = false, silent = true })
    vim.keymap.set("v", "<C-_>", "gc", { noremap = false, silent = true })
  '';
in
{
  imports = [ ./hardware-configuration.nix ];
  
  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages;
  
  # Networking
  networking.hostName = "redleadr";
  networking.networkmanager.enable = true;
  
  # GPU / Nvidia
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    open = true;
    modesetting.enable = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
  
  # Timezone & locale
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF8";
    LC_MEASUREMENT = "en_US.UTF8";
    LC_MONETARY = "en_US.UTF8";
    LC_NAME = "en_US.UTF8";
    LC_NUMERIC = "en_US.UTF8";
    LC_PAPER = "en_US.UTF8";
    LC_TELEPHONE = "en_US.UTF8";
    LC_TIME = "en_US.UTF8";
  };
  
  # Keyboard
  services.xserver.xkb.layout = "us";
  
  # User
  users.users.redleadr = {
    isNormalUser = true;
    description = "redleadr";
    extraGroups = [ "networkmanager" "wheel" "video" ];
  };
  
  # Allow unfree
  nixpkgs.config.allowUnfree = true;
  
  # GNOME + Wayland
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.wayland = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.desktopManager.gnome.extraGSettingsOverrides = ''
    [org.gnome.desktop.default-applications.terminal]
    exec = 'kitty'
    exec-arg = '-e'
  '';
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "redleadr";
  
  # Packages with Neovim
  environment.systemPackages = with pkgs; [
    # Neovim with custom config
    (neovim.override {
      configure = {
        customRC = ''
          luafile ${neovimConfig}
        '';
      };
    })
    
    # Existing packages
    git cmake gnumake tree-sitter gcc bottom wget unzip
    google-chrome
    networkmanagerapplet blueman steam wdisplays wl-clipboard fastfetch kitty
    gnome-tweaks nautilus file-roller gnome-calendar gnome-system-monitor
    nil nixd pyright rust-analyzer taplo marksman fzf ripgrep fd lazygit delta
    eza zoxide bat jq (python312.withPackages (ps: [ ps.pynvim ])) luajit
    imagemagick ghostscript mermaid-cli tectonic luarocks sqlite rustup
    zed-editor redis
    
    # Additional tools for Neovim
    nodejs  # Required by some LSP servers
    cargo   # For Rust (you already have rustup, but this ensures cargo is available)
    rustc
  ];
  
  # Default editor
  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };
  
  # Git configuration (required for lazy.nvim)
  programs.git.enable = true;
  
  # Misc
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;
  programs.gnome-terminal.enable = false;
  programs.steam.enable = true;
  hardware.graphics.extraPackages = with pkgs; [
    vaapiVdpau libvdpau-va-gl nvidia-vaapi-driver
  ];
  
  system.stateVersion = "25.05";
}
