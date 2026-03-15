local colors_path = vim.fn.expand("~/.local/state/quickshell/user/generated/colors.json")

local function file_exists(path)
    local f = io.open(path, "r")
    if f then
        f:close()
        return true
    end
    return false
end

local function read_colors(path)
    local f = io.open(path, "r")
    if not f then return nil end
    local content = f:read("*a")
    f:close()
    return vim.json.decode(content)
end

local function apply_wallpaper_colors()
    if not file_exists(colors_path) then
        vim.notify("Material You colors not found at " .. colors_path, vim.log.levels.WARN)
        return
    end

    local c = read_colors(colors_path)
    if not c then
        vim.notify("Failed to parse Material You colors", vim.log.levels.WARN)
        return
    end

    require("catppuccin").setup({
        color_overrides = {
            mocha = {
                base      = c.background,
                mantle    = c.surface,
                crust     = c.surface_container,
                surface0  = c.surface_container,
                surface1  = c.surface_container_high,
                surface2  = c.surface_variant,
                text      = c.on_background,
                subtext1  = c.on_surface,
                subtext0  = c.on_surface_variant,
                overlay0  = c.outline_variant,
                overlay1  = c.outline,
                overlay2  = c.on_surface_variant,
                blue      = c.primary,
                lavender  = c.primary_container,
                sapphire  = c.secondary,
                sky       = c.tertiary,
                teal      = c.secondary_container,
                green     = c.tertiary_container,
                red       = c.error,
                maroon    = c.error_container,
                peach     = c.on_error_container,
                yellow    = c.inverse_primary,
                pink      = c.on_primary_container,
                mauve     = c.on_secondary,
                flamingo  = c.on_tertiary,
                rosewater = c.on_primary,
            },
        },
    })
    vim.cmd.colorscheme("catppuccin")
    vim.notify("Material You colors applied!", vim.log.levels.INFO)
end

local function reset_colors()
    require("catppuccin").setup({ color_overrides = {} })
    vim.cmd.colorscheme("catppuccin")
    vim.notify("Catppuccin default colors restored!", vim.log.levels.INFO)
end

-- Register as user commands
vim.api.nvim_create_user_command("colorapply", apply_wallpaper_colors, {})
vim.api.nvim_create_user_command("colorreset", reset_colors, {})
