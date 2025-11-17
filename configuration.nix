{ config, pkgs, ... }:

let
  # This is the entire LazyVim setup — fully managed by Nix
    lazyvim = pkgs.neovim.override {
    configure = {
      customRC = /* vim */ ''
        lua << EOF
        local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
        if not vim.loop.fs_stat(lazypath) then
          vim.fn.system({
            "git", "clone", "--filter=blob:none",
            "https://github.com/folke/lazy.nvim.git",
            "--branch=stable", lazypath,
          })
        end
        vim.opt.rtp:prepend(lazypath)

        -- Force up-to-date pynvim
        vim.g.python3_host_prog = "${pkgs.python312.withPackages (ps: [ ps.pynvim ])}/bin/python"

        require("lazy").setup({
          spec = {
            { "LazyVim/LazyVim", import = "lazyvim.plugins" },

            -- Your extras (unchanged)
            { import = "lazyvim.plugins.extras.ui.mini-starter" },
            { import = "lazyvim.plugins.extras.coding.mini-surround" },
            { import = "lazyvim.plugins.extras.editor.harpoon2" },
            { import = "lazyvim.plugins.extras.util.mini-hipatterns" },

            -- FIX: Disable Nix Treesitter to avoid path conflicts with Lazy
            { "nvim-treesitter/nvim-treesitter", enabled = false },
            { "nvim-treesitter/nvim-treesitter-textobjects", enabled = false },
          },
          defaults = { lazy = true },
          install = { colorscheme = { "catppuccin", "tokyonight" } },
          checker = { enabled = true }, -- Auto-update to fix renames/bugs
          performance = {
            rtp = {
              disabled_plugins = {
                "netrwPlugin", "tutor", "tohtml", "gzip", "tarPlugin", "zipPlugin",
              },
            },
          },
        })

        vim.g.mapleader = " "
        vim.opt.number = true
        vim.opt.relativenumber = true
        vim.opt.mouse = "a"
        vim.opt.termguicolors = true
        EOF
      '';
      packages.all.start = with pkgs.vimPlugins; [
        lazy-nvim
        LazyVim
        catppuccin-nvim
        tokyonight-nvim
        plenary-nvim
        telescope-nvim
        which-key-nvim
        gitsigns-nvim
        lualine-nvim
        bufferline-nvim
        indent-blankline-nvim
        neo-tree-nvim
        nvim-lspconfig
        nvim-cmp
        cmp-nvim-lsp
        luasnip
      ];
    };
  };
in
{
  imports = [ ./hardware-configuration.nix ];

  ###########
  # BOOTLOADER
  ###########
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages;

  ###########
  # NETWORKING
  ###########
  networking.hostName = "redleadr";
  networking.networkmanager.enable = true;

  ############
  # GPU DRIVERS
  ############
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    open = true;
    modesetting.enable = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  #####################
  # TIMEZONE AND LOCALES
  #####################
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  ########
  # KEYMAP
  ########
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  ##############
  # USER ACCOUNT
  ##############
  users.users.redleadr = {
    isNormalUser = true;
    description = "redleadr";
    extraGroups = [ "networkmanager" "wheel" "video" ];
    packages = with pkgs; [];
  };

  ########################
  # UNFREE PACKAGES ENABLE
  ########################
  nixpkgs.config.allowUnfree = true;

  ######################################
  # DESKTOP ENVIRONMENT: GNOME (Wayland)
  ######################################
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.wayland = true; 
  services.xserver.desktopManager.gnome.enable = true;
services.xserver.desktopManager.gnome.extraGSettingsOverrides = ''
  # Set Kitty as the default terminal
  [org.gnome.desktop.default-applications.terminal]
  exec = 'kitty'
  exec-arg = '-e'
'';

  # Auto-login to GNOME
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "redleadr";

  #################
  # NEEDED PACKAGES
  #################
  environment.systemPackages = with pkgs; [
	git
	cmake
	gnumake
	tree-sitter
	gcc
    	bottom
    	wget
    	unzip
    	google-chrome
    	lazyvim        
    	networkmanagerapplet
    	blueman
    	steam
    	wdisplays
    	wl-clipboard
    	fastfetch
    	kitty
    	gnome-tweaks
    	nautilus
    	file-roller
    	gnome-calendar
    	gnome-system-monitor
    	nil
    	nixd
    	pyright
    	rust-analyzer
    	taplo
    	marksman
    	fzf
    	ripgrep 
    	fd 
    	lazygit
    	delta 
    	eza
    	zoxide
    	bat
    	jq
    	(python312.withPackages (ps: [ ps.pynvim ]))
    	luajit
    	imagemagick
    	ghostscript
    	mermaid-cli
    	tectonic
    	luarocks
    	sqlite
    	
    	#languages 
    	rustup
  ];

#####################
# FONTS (SYSTEM-WIDE)
#####################
fonts = {
  packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  fontconfig.defaultFonts.monospace = [ "JetBrainsMono Nerd Font" ];
};

###############################
# DEFAULT VARIABLES FOR SYSTEM
###############################
environment.variables = {
	EDITOR = "nvim";
	VISUAL = "nvim";
};

  ##########################
  # NEEDED PACKAGES SETTINGS
  ##########################
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;
	
programs.gnome-terminal.enable = false;

  # Steam
  programs.steam = {
    enable = true;
  };

  # NVIDIA VAAPI
  hardware.graphics.extraPackages = with pkgs; [    
    vaapiVdpau
    libvdpau-va-gl
    nvidia-vaapi-driver
  ];

  ######################
  # SYSTEM STATE VERSION
  ######################
  system.stateVersion = "25.05";
}
