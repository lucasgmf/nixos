{
  lib,
  config,
  ...
}:
{
  imports = [
    # shell configuration
    ./shell/zsh.nix
    ./shell/ohMyPosh
    ./shell/nushell

    ./shell/direnv.nix
    ./shell/zoxide.nix
    ./shell/eza.nix
    ./shell/fzf.nix

    # terminals
    ./alacritty.nix
    ./kitty.nix

    # editors
    ./neovim
    ./helix.nix

    # terminal multiplexers
    ./tmux
    ./zellij

    ./git.nix

    # custom scripts
    ./scripts/rebuild.nix
    ./scripts/update.nix
    ./scripts/build-iso.nix
    ./scripts/encr.nix
    ./scripts/rename_media.nix
    ./scripts/clean_photo.nix
  ];

  options = {
    cliPrograms.enable = lib.mkEnableOption "enable various cli programs and tools";
  };

  config = lib.mkIf config.cliPrograms.enable {
    zsh.enable = lib.mkDefault true;
    ohMyPosh.enable = lib.mkDefault true;

    nushell.enable = lib.mkDefault false;
    direnv.enable = lib.mkDefault true;
    zoxide.enable = lib.mkDefault true;
    eza.enable = lib.mkDefault true;
    fzf.enable = lib.mkDefault false;

    alacritty.enable = lib.mkDefault true;
    kitty.enable = lib.mkDefault false;

    nvim.enable = lib.mkDefault true;

    tmux.enable = lib.mkDefault false;
    zellij.enable = lib.mkDefault true;

    git.enable = lib.mkDefault true;
  };
}
