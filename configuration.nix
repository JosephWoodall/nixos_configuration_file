{ config, pkgs, ... }:

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

  # Packages (Neovim completely gone)
  environment.systemPackages = with pkgs; [
    git cmake gnumake tree-sitter gcc bottom wget unzip
    google-chrome
    networkmanagerapplet blueman steam wdisplays wl-clipboard fastfetch kitty
    gnome-tweaks nautilus file-roller gnome-calendar gnome-system-monitor
    nil nixd pyright rust-analyzer taplo marksman fzf ripgrep fd lazygit delta
    eza zoxide bat jq (python312.withPackages (ps: [ ps.pynvim ])) luajit
    imagemagick ghostscript mermaid-cli tectonic luarocks sqlite rustup
    zed-editor redis
  ];

  # Default editor (mouse-friendly now)
  environment.variables = {
    EDITOR = "gnome-text-editor";
    VISUAL = "gnome-text-editor";
  };

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
