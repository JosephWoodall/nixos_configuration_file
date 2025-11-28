{ config, pkgs, ... }:

let
  # Custom LazyVim configuration
  lazyVimConfig = pkgs.writeText "init.lua" ''
    -- Bootstrap lazy.nvim
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

    -- Load LazyVim
    require("lazy").setup({
      spec = {
        -- Import LazyVim base configuration
        { "LazyVim/LazyVim", import = "lazyvim.plugins" },
        
        -- Import all LazyVim extras you want
        { import = "lazyvim.plugins.extras.lang.rust" },
        { import = "lazyvim.plugins.extras.lang.python" },
        { import = "lazyvim.plugins.extras.lang.json" },
        { import = "lazyvim.plugins.extras.lang.markdown" },
        { import = "lazyvim.plugins.extras.coding.copilot" },
        { import = "lazyvim.plugins.extras.ui.mini-animate" },
        
        -- Your custom plugins can go here
      },
      defaults = {
        lazy = false,
        version = false,
      },
      install = { colorscheme = { "tokyonight" } },
      checker = { enabled = true },
      performance = {
        rtp = {
          disabled_plugins = {
            "gzip",
            "tarPlugin",
            "tohtml",
            "tutor",
            "zipPlugin",
          },
        },
      },
    })
   
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
  
  # Packages with LazyVim-configured Neovim
  environment.systemPackages = with pkgs; [
    # Neovim with LazyVim
    (neovim.override {
      configure = {
        customRC = ''
          luafile ${lazyVimConfig}
        '';
      };
    })
    
    # Development tools
    git cmake gnumake tree-sitter gcc bottom wget unzip
    nodejs  # Required by many LSP servers and LazyVim features
    cargo rustc rustup  # Rust toolchain
    (python312.withPackages (ps: [ ps.pynvim ]))
    luajit luarocks
    
    # LSP servers and formatters
    nil nixd pyright rust-analyzer taplo marksman
    
    # CLI utilities
    fzf ripgrep fd lazygit delta eza zoxide bat jq
    
    # Applications
    google-chrome
    networkmanagerapplet blueman steam wdisplays wl-clipboard 
    fastfetch kitty zed-editor redis
    
    # GNOME tools
    gnome-tweaks nautilus file-roller gnome-calendar gnome-system-monitor
    
    # Document processing
    imagemagick ghostscript mermaid-cli tectonic sqlite
  ];
  
  # Default editor
  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };
  
  # Git configuration (required for lazy.nvim and LazyVim)
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
