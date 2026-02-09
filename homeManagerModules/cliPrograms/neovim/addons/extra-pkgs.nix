{ pkgs, ... }:
{
  programs.neovim.extraPackages = with pkgs; [
   # global servers
   # nil # nix
   # gcc
   # nixfmt-rfc-style
   #
   # lua-language-server
   #
   # # python
   # python312Packages.python-lsp-server
   # python312Packages.python-lsp-ruff
   #
   # # html, css, json, eslint
   # vscode-langservers-extracted
  ];

}

