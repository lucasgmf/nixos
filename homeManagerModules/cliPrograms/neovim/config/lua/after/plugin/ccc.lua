require('ccc').setup{
	-- (Vim) Command used to open files
	edit_cmd = "edit",

	-- See `Q&A` for more info
	on_close = {},
	on_open = {},

	-- UI Options
	ui = {
		-- Default UI (can be "split" or "float")
		default = "float",

		float = {
			-- Floating window border (see ':h nvim_open_win')
			border    = "none",

			-- Highlight group for floating window/border (see ':h winhl')
			float_hl  = "Normal",
			border_hl = "FloatBorder",

			-- Floating Window Transparency (see ':h winblend')
			blend     = 0,

			-- Num from 0 - 1 for measurements
			height    = 0.8,
			width     = 0.8,

			-- X and Y Axis of Window
			x         = 0.5,
			y         = 0.5
		},

		split = {
			-- Direction of split
			direction = "topleft",

			-- Size of split
			size      = 24
		}
	},

	-- Terminal commands used w/ file manager (have to be in your $PATH)
	cmds = {
        ccc_cmd     = "ccc",
        fnf_cmd     = "find . | fnf",
	},

	-- Mappings used with the plugin
	mappings = {
		vert_split = "<C-v>",
		horz_split = "<C-h>",
		tabedit    = "<C-t>",
		edit       = "<C-e>",
		ESC        = "<ESC>"
	},
}
