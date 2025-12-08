{ config, pkgs, ... }:

let
  nvimConfig = pkgs.writeText "init.lua" ''
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

    -- Basic options
    vim.g.mapleader = " "
    vim.o.number = true
    vim.o.relativenumber = true
    vim.o.expandtab = true
    vim.o.shiftwidth = 2
    vim.o.tabstop = 2
    vim.o.smartindent = true
    vim.o.wrap = false
    vim.o.termguicolors = true

    -- Load plugins via lazy.nvim (start empty, you can add plugins later)
    require("lazy").setup({})
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
  ruff
  rust-analyzer
  marksman
  yaml-language-server
  nixd
 # Formatters
  nodePackages.prettier
  black
  rustfmt
  nixfmt-classic

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
