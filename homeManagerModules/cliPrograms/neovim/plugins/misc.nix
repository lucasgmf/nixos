{ pkgs, ... }:
{
  programs.neovim.plugins = with pkgs.vimPlugins; [

    mini-nvim
    # persistence-nvim
    # zellij-nav-nvim

    # user interface
    # lualine-nvim
    # vim-startify # starter page
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
    #   dressing-nvim # better telescope ui
    #   telescope-fzf-native-nvim

    #   # Treesitter and language grammar packs
	 nvim-treesitter
     nvim-treesitter.withAllGrammars
     nvim-treesitter-textobjects
     nvim-ts-autotag

        # Treesitter and language grammar packs
        # (nvim-treesitter.withPlugins (
        #   p: [
        #     p.c
        #     p.cpp
        #     p.rust
        #     p.go
        #     p.lua
        #     p.nix
        #     p.markdown
        #     p.python
        #     p.javascript
        #     p.zig
        #     p.kdl
        #   ]
        # ))
  ];
}

