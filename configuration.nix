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

  # ────────────────────── 2025 TERMINAL ENDGAME STACK (micro edition) ──────────────────────
  environment.systemPackages = with pkgs; [
    zellij micro lf lazygit
    fzf ripgrep fd eza bat zoxide delta bottom fastfetch

    pyright
    ruff
    rust-analyzer
    gopls
    marksman
    taplo
    yaml-language-server

    # Nerd fonts (optional)
    # pkgs.nerd-fonts.fira-code
    # pkgs.nerd-fonts.hack

    kitty google-chrome steam zed-editor redis
  ];

  # Global `dev` command
  environment.interactiveShellInit = ''
    dev() { zellij --layout dev; }
  '';

  # Zellij dev layout with micro + lf
  environment.etc."zellij/layouts/dev.kdl".text = ''
    layout {
      tab {
        pane split_direction="vertical" size="70%" {
          pane command="micro" { args "."; }
        }
        pane command="lf"
        pane command="lazygit"
      }
    }
  '';

  system.activationScripts.zellijLayout.text = ''
    mkdir -p /home/redleadr/.config/zellij/layouts
    ln -sf /etc/zellij/layouts/dev.kdl /home/redleadr/.config/zellij/layouts/dev.kdl
    chown -R redleadr:users /home/redleadr/.config/zellij
  '';

  # Zellij config (Ctrl+arrows)
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

  # micro global config
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

  system.activationScripts.microConfig.text = ''
    mkdir -p /home/redleadr/.config/micro
    ln -sf /etc/micro/settings.json /home/redleadr/.config/micro/settings.json
    chown -R redleadr:users /home/redleadr/.config/micro
  '';

  # Auto-install micro LSP plugin on first boot
  system.activationScripts.microLspPlugin.text = ''
    if [ ! -d /home/redleadr/.config/micro/plugins/lsp ]; then
      sudo -u redleadr micro --plugin install lsp || true
    fi
  '';

  # LF config for opening files in micro
  environment.etc."lf/lfrc".text = ''
    map enter !micro $f
  '';
system.activationScripts.lfConfig.text = ''
    mkdir -p /home/redleadr/.config/lf
    ln -sf /etc/lf/lfrc /home/redleadr/.config/lf/lfrc
    chown -R redleadr:users /home/redleadr/.config/lf

  '';

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
