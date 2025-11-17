{ config, pkgs, ... }:

let
  # This is the entire LazyVim setup — fully managed by Nix
  lazyvim = pkgs.neovim.override {
    configure = {
      customRC = /* vim */ ''
        " Bootstrap lazy.nvim + LazyVim on first launch
        lua << EOF
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

        require("lazy").setup({
          spec = {
            -- Import the official LazyVim distribution
            { "LazyVim/LazyVim", import = "lazyvim.plugins" },
            -- All the popular extras most people enable
            { import = "lazyvim.plugins.extras.ui.mini-starter" },
            { import = "lazyvim.plugins.extras.coding.mini-surround" },
            { import = "lazyvim.plugins.extras.editor.harpoon2" },
            { import = "lazyvim.plugins.extras.util.mini-hipatterns" },
          },
          defaults = { lazy = true },
          install = { colorscheme = { "catppuccin", "tokyonight" } },
          checker = { enabled = true },
          performance = {
            rtp = {
              disabled_plugins = {
                "netrwPlugin", "tutor", "tohtml", "gzip", "tarPlugin", "zipPlugin",
              },
            },
          },
        })

        -- Basic LazyVim defaults everyone loves
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

        # Core plugins that LazyVim expects (automatically pulled otherwise, but we pin them)
        catppuccin-nvim
        tokyonight-nvim
        nvim-treesitter.withAllGrammars
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

  #######
  # KEYMAP
  #######
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  #############
  # USER ACCOUNT
  #############
  users.users.redleadr = {
    isNormalUser = true;
    description = "redleadr";
    extraGroups = [ "networkmanager" "wheel" "video" ];
    packages = with pkgs; [];
  };

  #######################
  # UNFREE PACKAGES ENABLE
  #######################
  nixpkgs.config.allowUnfree = true;

  ##################################
  # DESKTOP ENVIRONMENT: GNOME (Wayland)
  ##################################
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.wayland = true; 
  services.xserver.desktopManager.gnome.enable = true;

  # Auto-login to GNOME
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "redleadr";

  ################
  # NEEDED PACKAGES
  ################
  environment.systemPackages = with pkgs; [
	git
	cmake
	gnumake
	tree-sitter
	gcc
    	htop
    	wget
    	unzip
    	google-chrome
    	# neovim → replaced with our full LazyVim build
    	lazyvim            # ← THIS IS YOUR NEW NEOVIM
    	networkmanagerapplet
    	blueman
    	steam
    	wdisplays
    	fastfetch
    	gnome-tweaks
    	gnome-terminal
    	nautilus
    	file-roller
    	gnome-calendar
    	gnome-system-monitor
    	# Optional but recommended: common LSP servers available globally
    	nil
    	nixd
    	pyright
    	rust-analyzer
    	taplo
    	marksman
  ];
  
##############################
# DEFAULT VARIABLES FOR SYSTEM
################################
environment.variables = {
	EDITOR = "nvim";
	VISUAL = "nvim";
};

  #########################
  # NEEDED PACKAGES SETTINGS
  #########################
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

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

  #####################
  # SYSTEM STATE VERSION
  #####################
  system.stateVersion = "25.05";
}
