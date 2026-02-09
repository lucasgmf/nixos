{ pkgs, ... }:
{
  programs.neovim.plugins = with pkgs.vimPlugins; [

#   # File tree
#   nvim-web-devicons
#   nvim-tree-lua

#   lsp-zero-nvim
#   nvim-lspconfig
#   luasnip

#   cmp-nvim-lsp
#   cmp-buffer
#   cmp-path
#   cmp-cmdline
#   nvim-cmp
#   copilot-vim

#   rustaceanvim # rust specific features
#   crates-nvim

#   vim-nix # better nix language support

#   ccc-nvim # Hex visualizer
    mini-nvim
    # persistence-nvim
    # zellij-nav-nvim

    # props to ThePrimeagen
    harpoon2
    undotree

    # nvim-tree-lua

    # user interface
    gitsigns-nvim
    # lualine-nvim
    # vim-startify
    # todo-comments-nvim
    # rainbow-delimiters-nvim
    # indent-blankline-nvim

    # colorschemes !
 	catppuccin-nvim
    # gruvbox-nvim
    # rose-pine
    # onedark-nvim
    # molokai

    # Telescope
	plenary-nvim # telescope dependency
	telescope-nvim

    dressing-nvim # better telescope ui
    telescope-fzf-native-nvim

    # Treesitter and language grammar packs
	 nvim-treesitter
     (nvim-treesitter.withPlugins (
                                   p: [
                                   p.c
                                   p.cpp
                                   p.rust
                                   p.go
                                   p.lua
                                   p.nix
                                   p.markdown
                                   p.python
                                   p.javascript
                                   p.zig
                                   p.kdl
                                   ]
                                  ))
  ];
}

