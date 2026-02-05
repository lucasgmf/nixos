{
  pkgs,
  config,
  lib,
  ...
}:
{
  imports = [
    ./plugins
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

      extraPackages = with pkgs; [

      #   # global servers
         nil # nix
         gcc
      #   nixfmt-rfc-style
      #
      #   lua-language-server
      #
      #   # python
      #   python312Packages.python-lsp-server
      #   python312Packages.python-lsp-ruff
      #
      #   # html, css, json, eslint
      #   vscode-langservers-extracted
      ];

       plugins = with pkgs.vimPlugins; [

      #   # props to ThePrimeagen
      #   harpoon2
      #   undotree
      #
      #   # File tree
      #   nvim-web-devicons
      #   nvim-tree-lua

      #   lsp-zero-nvim
      #   nvim-lspconfig
      #   luasnip
      #
      #   cmp-nvim-lsp
      #   cmp-buffer
      #   cmp-path
      #   cmp-cmdline
      #   nvim-cmp
      #   copilot-vim
      #
      #   rustaceanvim # rust specific features
      #   crates-nvim
      #
      #   vim-nix # better nix language support
      #
      #   ccc-nvim # Hex visualizer
       ];
    };
  };
}
