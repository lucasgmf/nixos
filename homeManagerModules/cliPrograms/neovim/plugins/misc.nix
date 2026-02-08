{ pkgs, ... }:
{
  programs.neovim.plugins = with pkgs.vimPlugins; [

    mini-nvim
    # persistence-nvim
    # zellij-nav-nvim

    # props to ThePrimeagen
    harpoon2
    undotree

    # nvim-tree-lua

    # user interface
    # lualine-nvim
    # vim-startify
    # gitsigns-nvim
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

    # dressing-nvim # better telescope ui
    # telescope-fzf-native-nvim

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

