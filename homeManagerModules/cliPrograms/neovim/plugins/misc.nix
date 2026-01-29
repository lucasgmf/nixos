{ pkgs, ... }:
{
  programs.neovim.plugins = with pkgs.vimPlugins; [
    mini-nvim
  ];
}

