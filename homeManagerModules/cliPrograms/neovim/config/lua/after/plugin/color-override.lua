local colors_path = vim.fn.expand("~/.local/state/quickshell/user/generated/colors.json")
local transparent = true
local using_wallpaper_colors = false

local function boost_saturation(hex, amount)
    -- amount: 0.0 to 1.0 added to saturation
    hex = hex:gsub("#", "")
    local r = tonumber(hex:sub(1, 2), 16) / 255
    local g = tonumber(hex:sub(3, 4), 16) / 255
    local b = tonumber(hex:sub(5, 6), 16) / 255

    local max = math.max(r, g, b)
    local min = math.min(r, g, b)
    local h, s, l

    l = (max + min) / 2

    if max == min then
        h, s = 0, 0
    else
        local d = max - min
        s = l > 0.5 and d / (2 - max - min) or d / (max + min)
        if max == r then
            h = (g - b) / d + (g < b and 6 or 0)
        elseif max == g then
            h = (b - r) / d + 2
        else
            h = (r - g) / d + 4
        end
        h = h / 6
    end

    s = math.min(1, s + amount)

    -- HSL to RGB
    local function hue2rgb(p, q, t)
        if t < 0 then t = t + 1 end
        if t > 1 then t = t - 1 end
        if t < 1 / 6 then return p + (q - p) * 6 * t end
        if t < 1 / 2 then return q end
        if t < 2 / 3 then return p + (q - p) * (2 / 3 - t) * 6 end
        return p
    end

    local nr, ng, nb
    if s == 0 then
        nr, ng, nb = l, l, l
    else
        local q = l < 0.5 and l * (1 + s) or l + s - l * s
        local p = 2 * l - q
        nr = hue2rgb(p, q, h + 1 / 3)
        ng = hue2rgb(p, q, h)
        nb = hue2rgb(p, q, h - 1 / 3)
    end

    return string.format("#%02x%02x%02x",
        math.floor(nr * 255 + 0.5),
        math.floor(ng * 255 + 0.5),
        math.floor(nb * 255 + 0.5))
end

local sat = 0.75 -- 0.0 to 1.0

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

local function apply_theme()
    local overrides = {}
    if using_wallpaper_colors then
        local c = read_colors(colors_path)
        if c then
            overrides = {
                mocha = {
                    -- Backgrounds (keep dark)
                    base      = c.background,
                    mantle    = c.surface_container_low,
                    crust     = c.surface_container_lowest,
                    surface0  = c.surface_container,
                    surface1  = c.surface_container_high,
                    surface2  = c.surface_container_highest,

                    -- Text (keep bright)
                    text      = boost_saturation(c.on_background, sat),
                    subtext1  = boost_saturation(c.on_surface, sat),
                    subtext0  = boost_saturation(c.on_surface_variant, sat),

                    -- Overlays
                    overlay0  = boost_saturation(c.outline_variant, sat),
                    overlay1  = boost_saturation(c.outline, sat),
                    overlay2  = boost_saturation(c.on_surface_variant, sat),

                    -- Accents
                    blue      = boost_saturation(c.primary_fixed_dim, sat),
                    lavender  = boost_saturation(c.primary_fixed, sat),
                    sapphire  = boost_saturation(c.secondary_fixed_dim, sat),
                    sky       = boost_saturation(c.tertiary_fixed_dim, sat),
                    teal      = boost_saturation(c.secondary_fixed, sat),
                    green     = boost_saturation(c.tertiary_fixed, sat),

                    -- Reds
                    red       = boost_saturation(c.error, sat),
                    maroon    = boost_saturation(c.on_error_container, sat),
                    peach     = boost_saturation(c.on_secondary_container, sat),

                    -- Misc accents
                    yellow    = boost_saturation(c.on_tertiary_container, sat),
                    pink      = boost_saturation(c.on_primary_container, sat),
                    mauve     = boost_saturation(c.secondary_fixed, sat),
                    flamingo  = boost_saturation(c.tertiary_fixed, sat),
                    rosewater = boost_saturation(c.primary_fixed, sat),
                },
            }
        end
    end
    require("catppuccin").setup({
        transparent_background = transparent,
        color_overrides = overrides,
    })
    vim.cmd.colorscheme("catppuccin")
    if transparent then
        vim.api.nvim_set_hl(0, "TelescopeNormal", { bg = "NONE" })

        -- Make telescope transparent
        vim.api.nvim_set_hl(0, "TelescopeNormal", { bg = "NONE" })
        vim.api.nvim_set_hl(0, "TelescopeBorder", { bg = "NONE" })
        vim.api.nvim_set_hl(0, "TelescopePromptNormal", { bg = "NONE" })
        vim.api.nvim_set_hl(0, "TelescopePromptBorder", { bg = "NONE" })
        vim.api.nvim_set_hl(0, "TelescopeResultsNormal", { bg = "NONE" })
        vim.api.nvim_set_hl(0, "TelescopeResultsBorder", { bg = "NONE" })
        vim.api.nvim_set_hl(0, "TelescopePreviewNormal", { bg = "NONE" })
        vim.api.nvim_set_hl(0, "TelescopePreviewBorder", { bg = "NONE" })
    end
end

local function reset_colors()
    using_wallpaper_colors = false
    apply_theme()
    vim.notify("Catppuccin default colors restored!", vim.log.levels.INFO)
end

local function toggle_background()
    transparent = not transparent
    apply_theme()
    vim.notify("Background: " .. (transparent and "transparent" or "solid"), vim.log.levels.INFO)
end

local function apply_wallpaper_colors()
    if not file_exists(colors_path) then
        vim.notify("Material You colors not found at " .. colors_path, vim.log.levels.WARN)
        return
    end
    using_wallpaper_colors = true
    apply_theme()
    vim.notify("Material You colors applied!", vim.log.levels.INFO)
end

vim.api.nvim_create_user_command("Colorapply", apply_wallpaper_colors, {})
vim.api.nvim_create_user_command("Colorreset", reset_colors, {})
vim.api.nvim_create_user_command("Colortogglebg", toggle_background, {})
