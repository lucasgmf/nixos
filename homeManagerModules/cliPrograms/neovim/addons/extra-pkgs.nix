{ pkgs, ... }:
{
  programs.neovim.extraPackages = with pkgs; [

    # vim-startify dependencies
    (pkgs.buildEnv {
      name = "neovim-startify-extras";
      paths = [
        pkgs.cowsay
        pkgs.fortune
      ];
    })

    # global servers
    nil
    clang-tools
    gopls
    lua-language-server
    python312Packages.python-lsp-server
    marksman

    # other tools
    gcc
  ];
}
