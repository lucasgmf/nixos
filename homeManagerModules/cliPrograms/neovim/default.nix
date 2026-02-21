{
  pkgs,
  config,
  lib,
  ...
}:
{
  imports = [
    ./addons # additional pkgs
  ];
  
  options = {
    nvim.enable = lib.mkEnableOption "enable neovim";
  };

  config = lib.mkIf config.nvim.enable {
    home.file = {
      ".config/nvim" = {
        source = ./config;
        recursive = true;
      };
    };

    home.sessionVariables = {
      EDITOR = "nvim";
      NIXOS_OZONE_WL = "1";
    };

    programs.neovim = {
      enable = true;
      vimAlias = true;
      defaultEditor = true;
    };
  };
}
