{ config, pkgs, ... }:

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

  # ────────────────────── 2025 TERMINAL ENDGAME STACK (Micro-Centric) ──────────────────────
  environment.systemPackages = with pkgs; [
    # Keeping zellij just for session management (if you still want the `dev` command)
    zellij micro lazygit # Removed 'lf'
    fzf ripgrep fd eza bat zoxide delta bottom fastfetch

    pyright
    ruff
    rust-analyzer
    gopls
    marksman
    taplo
    yaml-language-server

    kitty google-chrome steam zed-editor redis
  ];

  # Global `dev` command
  environment.interactiveShellInit = ''
    # The 'dev' command now just launches a single pane running micro
    dev() { zellij --layout dev; }
  '';

  # 1. 🧹 SIMPLIFIED ZELLIJ LAYOUT (Single Pane for Micro)
  environment.etc."zellij/layouts/dev.kdl".text = ''
    layout {
      tab {
        pane command="micro" { args "."; }
      }
    }
  '';

  system.activationScripts.zellijLayout.text = ''
    mkdir -p /home/redleadr/.config/zellij/layouts
    ln -sf /etc/zellij/layouts/dev.kdl /home/redleadr/.config/zellij/layouts/dev.kdl
    chown -R redleadr:users /home/redleadr/.config/zellij
  '';

  # Zellij config (Ctrl+arrows) - UNCHANGED
  environment.etc."zellij/config.kdl".text = ''
    theme "catppuccin-mocha"
    keybinds clear-defaults=true {
      normal {
        bind "Ctrl Left"  { MoveFocus "Left"; }
        bind "Ctrl Right" { MoveFocus "Right"; }
        bind "Ctrl Up"    { MoveFocus "Up"; }
        bind "Ctrl Down"  { MoveFocus "Down"; }
      }
    }
  '';

  # 2. 🔌 MICRO CONFIG: Global Settings and Bindings

  # Settings
  environment.etc."micro/settings.json".text = builtins.toJSON {
    "*.go" = { tabsize = 4; };
    "*.rs" = { tabsize = 4; };
    "*.py" = { tabsize = 4; };
    "*.nix" = { tabsize = 2; };

    tabsize = 2;
    tabstospaces = true;
    autosu = true;
    colorcolumn = 100;
    diffgutter = true;
    linter = true;
    scrollbar = true;
    lsp = true;
  };
  
  # Bindings for the file manager (Ctrl-O to toggle)
  environment.etc."micro/bindings.json".text = builtins.toJSON {
    "Ctrl-o" = "command-edit: filemanager";
  };
  
  system.activationScripts.microConfig.text = ''
    mkdir -p /home/redleadr/.config/micro
    ln -sf /etc/micro/settings.json /home/redleadr/.config/micro/settings.json
    ln -sf /etc/micro/bindings.json /home/redleadr/.config/micro/bindings.json
    chown -R redleadr:users /home/redleadr/.config/micro
  '';


  # 3. 💾 PLUGIN INSTALLATION: LSP and Filemanager
  system.activationScripts.microLspPlugin.text = ''
    if [ ! -d /home/redleadr/.config/micro/plugins/lsp ]; then
      sudo -u redleadr micro --plugin install lsp || true
    fi
  '';

  system.activationScripts.microFileManagerPlugin.text = ''
    if [ ! -d /home/redleadr/.config/micro/plugins/filemanager ]; then
      # Install the filemanager plugin
      sudo -u redleadr micro --plugin install filemanager || true
    fi
  '';
  
  # 4. ❌ CLEANUP: Removed all lf/lfrc/lfConfig logic.
  # Note: You may need to manually remove the old /home/redleadr/.config/lf directory if it exists.


  environment.variables = {
    EDITOR = "micro";
    VISUAL = "micro";
  };

  programs.git.enable = true;
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;
  programs.steam.enable = true;

  system.stateVersion = "25.05";
}
