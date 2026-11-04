{
  user,
  lib,
  inputs,
  pkgs,
  ...
}: {
  imports =
    [
      ./cliPrograms
      ./rice
      ./stylix
      ./windowManagers
      ./otherPackages.nix
    ]
    ++ (
      if builtins.pathExists /home/lucasgmf/nixos/secrets/default.nix
      then [/home/lucasgmf/nixos/secrets/default.nix]
      else []
    );

  # NOTE: fixes https://github.com/danth/stylix/issues/865
  nixpkgs.overlays = lib.mkForce null;

  # Enable and configure Hyprland
  hyprlandConf.enable = true;

  autoStyling = {
    enable = false;
    useDynamicColors = false;
  };

  home = {
    username = user.name;
    homeDirectory = "/home/${user.name}";
    sessionVariables = {
      QT_QPA_PLATFORM = "wayland";
    };
  };

  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
    };
  };

  cliPrograms.enable = true;

  nvim.enable = true;
  zsh.enable = true;

  # track app time
  services.activitywatch = {
    enable = true;
    watchers = {
      aw-watcher-window = {
        package = pkgs.aw-watcher-window-wayland;
        executable = "aw-watcher-window-wayland";
      };
    };
  };

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
