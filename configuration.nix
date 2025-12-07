{ config, pkgs, ... }:

let
  user = "redleadr";
  userHome = "/home/${user}";
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

  ################################################################################
  # HELIX-CENTRIC DEVELOPMENT STACK
  ################################################################################
  environment.systemPackages = with pkgs; [
    # Core editor + tools
    helix
    lazygit
    yazi            # Optional file browser (helix has built-in picker)
    
    # Utilities
    fzf ripgrep fd eza bat zoxide delta bottom fastfetch

    # LSP servers - Helix auto-detects these
    pyright                # Python
    ruff                   # Python linting/formatting  
    rust-analyzer          # Rust
    gopls                  # Go
    nodePackages.typescript-language-server  # TypeScript/JavaScript
    vscode-langservers-extracted  # HTML, CSS, JSON, ESLint
    marksman               # Markdown
    taplo                  # TOML
    yaml-language-server   # YAML
    nixd                   # Nix
    
    # Formatters (Helix can use these automatically)
    nodePackages.prettier  # JS/TS/JSON/CSS/HTML/Markdown
    black                  # Python
    rustfmt                # Rust
    nixfmt-classic         # Nix
    
    # Debuggers (optional, for future DAP support)
    lldb                   # Rust/C/C++

    # GUI apps
    kitty google-chrome steam zed-editor redis
  ];

  ################################################################################
  # Simple 'dev' command - just opens helix in your projects directory
  ################################################################################
  environment.interactiveShellInit = ''
    # Open helix in project directory or current directory
    dev() { 
      cd ~/projects 2>/dev/null || cd ~
      hx .
    }
  '';

  ################################################################################
  # HELIX CONFIG: Optimized for programming
  ################################################################################
  environment.etc."helix/config.toml".text = ''
    theme = "catppuccin_mocha"

    [editor]
    line-number = "relative"
    mouse = true
    cursorline = true
    color-modes = true
    auto-save = true
    completion-trigger-len = 1
    auto-format = true
    rulers = [100]
    bufferline = "multiple"
    
    [editor.statusline]
    left = ["mode", "spinner", "file-name", "read-only-indicator", "file-modification-indicator"]
    center = ["diagnostics"]
    right = ["selections", "position", "file-encoding"]
    
    [editor.lsp]
    display-messages = true
    display-inlay-hints = true
    
    [editor.cursor-shape]
    insert = "bar"
    normal = "block"
    select = "underline"
    
    [editor.file-picker]
    hidden = false
    
    [editor.soft-wrap]
    enable = false
    
    [editor.indent-guides]
    render = true
    character = "│"
    
    [keys.normal]
    # Space+e for file explorer (alternative to Space+f for file picker)
    # Helix uses Space+f for fuzzy file finding by default
    C-s = ":w"  # Ctrl-s to save (optional, for habit)
    
    [keys.insert]
    C-s = ":w"  # Ctrl-s to save from insert mode
  '';

  environment.etc."helix/languages.toml".text = ''
    # Language-specific configurations
    
    [[language]]
    name = "python"
    auto-format = true
    formatter = { command = "black", args = ["--quiet", "-"] }
    
    [[language]]
    name = "rust"
    auto-format = true
    
    [[language]]
    name = "go"
    auto-format = true
    
    [[language]]
    name = "javascript"
    auto-format = true
    formatter = { command = "prettier", args = ["--parser", "typescript"] }
    
    [[language]]
    name = "typescript"
    auto-format = true
    formatter = { command = "prettier", args = ["--parser", "typescript"] }
    
    [[language]]
    name = "nix"
    auto-format = true
    formatter = { command = "nixfmt" }
  '';

  # Link helix config to user's home
  system.activationScripts.helixConfig.text = ''
    mkdir -p ${userHome}/.config/helix
    ln -sf /etc/helix/config.toml ${userHome}/.config/helix/config.toml
    ln -sf /etc/helix/languages.toml ${userHome}/.config/helix/languages.toml
    chown -R ${user}:users ${userHome}/.config/helix || true
  '';

  ################################################################################
  # Environment variables
  ################################################################################
  environment.variables = {
    EDITOR = "hx";
    VISUAL = "hx";
  };

  programs.git.enable = true;
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;
  programs.steam.enable = true;

  system.stateVersion = "25.05";
}
