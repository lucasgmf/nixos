{ pkgs, ... }:
{
  programs.neovim.extraPackages = with pkgs; [

    (pkgs.buildEnv {
      name = "neovim-startify-extras";
      paths = [
        pkgs.cowsay
        pkgs.fortune
      ];
    })

    nil
    clang-tools
    gopls
    # go / initialize as a nix shell if needed...
    lua-language-server
    (pkgs.python3.withPackages (
      ps: with ps; [
        python-lsp-server
        python-lsp-black
        pylsp-mypy
        black
      ]
    ))
    marksman

    # Shell scripting
    bash-language-server
    shfmt
    shellcheck

    gcc
  ];
}
