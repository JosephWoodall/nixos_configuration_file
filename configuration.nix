{ config, pkgs, ... }:

let
  nvimConfig = pkgs.writeText "init.lua" ''
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

    -- Basic options
    vim.g.mapleader = " "
    vim.o.number = true
    vim.o.relativenumber = true
    vim.o.expandtab = true
    vim.o.shiftwidth = 4
    vim.o.tabstop = 4
    vim.o.smartindent = true
    vim.o.wrap = false
    vim.o.termguicolors = true
    vim.opt.mouse = "a"
    vim.cmd("syntax on")

    -- Load plugins via lazy.nvim
    require("lazy").setup({
    
    	-- LSP
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

    -- Rust Analyzer
vim.lsp.config("rust_analyzer", {
  settings = {
    ["rust-analyzer"] = {
      cargo = { allFeatures = true },
      checkOnSave = { command = "clippy" },
    },
  },
})

-- Pyright
vim.lsp.config("pyright", {})

    -- LSP keymaps
    local opts = { noremap=true, silent=true }
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
  end,
},

-- Treesitter
{
  "nvim-treesitter/nvim-treesitter",
  run = ":TSUpdate",
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = {"python", "rust", "json" }, 
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
    })
  end,
},
    	
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
      
      --Auto complete brackets/parenthesis
        {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup {}
    end,
  },
  
	-- Formatter
	{
    "stevearc/conform.nvim",
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          lua = { "stylua" },
          python = { "black" },
          rust = { "rustfmt" },
          -- add more per‑language formatters
        },
        format_on_save = {
          timeout_ms = 500,
          lsp_format = "fallback",
        },
      })
    end,
  },
  
  	--Which Key
{
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = {
          preset = "helix", 
          delay = 0, 
        },
        config = function(_, opts)
          local wk = require("which-key")
          wk.setup(opts)

          wk.add({
            { "<leader>c", group = "Code" },
            { "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", desc = "Code Action" },
            { "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", desc = "Rename Symbol" },

            { "<leader>e", "<cmd>Neotree toggle<CR>", desc = "File Explorer" },

            { "<leader>f", group = "Find / Fuzzy" },
            { "<leader>fb", "<cmd>Telescope buffers<CR>", desc = "Buffers" },
            { "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "Find Files" },
            { "<leader>fg", "<cmd>Telescope live_grep<CR>", desc = "Live Grep" },

          })
        end,
      },
    	
    	})
  '';
 in
{
  imports = [ ./hardware-configuration.nix ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "redleadr";
  networking.networkmanager.enable = true;

  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    open = true;
    modesetting.enable = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";
  services.xserver.xkb.layout = "us";

  users.users.redleadr = {
    isNormalUser = true;
    description = "redleadr";
    extraGroups = [ "networkmanager" "wheel" "video" ];
  };

  nixpkgs.config.allowUnfree = true;

  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.wayland = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "redleadr";


environment.systemPackages = with pkgs; [

#############
# DEVELOPMENT
############
    (neovim.override {
      configure = {
        customRC = ''
          luafile ${nvimConfig}
        '';
      };
    })
# LSP servers
  pyright
  rust-analyzer
 # Formatters
  nodePackages.prettier
  black
  rustfmt
  nixfmt-classic
 # Clipboard
 xclip
 # Compiler
 gcc

##############
# IN-MEMORY DB
##############
redis 

##########
# TERMINAL
##########
ghostty

###########
# UTILITIES
###########
lazygit
fzf
ripgrep
bottom
fastfetch

##################
# INTERNET BROWSER
##################
google-chrome

#######
# STEAM
#######
steam 

];

  ################################################################################
  # Environment variables
  ################################################################################
  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  programs.git.enable = true;
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;
  programs.steam.enable = true;

  system.stateVersion = "25.05";
}






