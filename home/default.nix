{ pkgs, ... }:
let 
  user = "dvalinn";
in {
  imports = [
    ./nvim
    ./helix
    ./shell
  ];

  home.username = user;
  home.homeDirectory = "/home/${user}";

  home.packages = with pkgs; [
    # Language ToolChains
    python3
    rustup
    go

    # dev tools
    sccache
    sqlx-cli
    cargo-watch
    podman
    podman-tui

    # Cli tools
    bunyan-rs
    fastfetch
    ripgrep
    repgrep
    xclip
    unzip
    less
    dust
    bat
    eza
    jq
    fd
    gh

    # TUI apps
    gotop
    lazygit

    # GUI apps
    firefox
    discord
    spotify

    # File management
    xfce.thunar
  ];

  home.file = { 
    ".config/awesome" = {
      source = ./../modules/awesome/config;
      recursive = true;
    };
  };

  home.sessionVariables = { 
    "RUSTC_WRAPPER" = "${pkgs.sccache}";
  };

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.

  programs = {
    # Let Home Manager install and manage itself.
    home-manager.enable = true;

    git = {
      enable = true;
      userName = user;
      userEmail = "tiago.andre.amorim@gmail.com";
    };

    ranger = {
      enable = true;
    };

    zellij = {
      enable = true;
      # enableZshIntegration = true;
    };
  };
}
