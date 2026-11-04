pragma Singleton
pragma ComponentBehavior: Bound

import qs.modules.common
import qs.services
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // ── Shared ────────────────────────────────────────────────────────────
    property int generatorMode: 0   // 0 = Matugen, 1 = Wallust
    property bool loading: false
    property int loadProgress: 0
    property string statusMessage: ""
    property bool applied: false
    property bool applying: false
    property string wallpaperPath: ""

    // ── Matugen ───────────────────────────────────────────────────────────
    readonly property var schemes: [
        "scheme-content", "scheme-expressive", "scheme-fidelity",
        "scheme-fruit-salad", "scheme-monochrome", "scheme-neutral",
        "scheme-rainbow", "scheme-tonal-spot", "scheme-vibrant"
    ]
    readonly property var modes: ["dark", "light"]
    readonly property var colorKeys: [
        "primary", "on_primary", "primary_container", "on_primary_container",
        "secondary", "on_secondary", "secondary_container", "on_secondary_container",
        "tertiary", "on_tertiary", "tertiary_container", "on_tertiary_container",
        "background", "on_background",
        "surface", "on_surface", "surface_variant", "on_surface_variant",
        "error", "on_error", "error_container", "on_error_container",
        "outline", "outline_variant", "shadow", "inverse_surface", "inverse_on_surface"
    ]
    property int selectedScheme: 0
    property int selectedMode: 0
    property real contrast: 0.0
    property var schemeColors: ({})
    property int _loadIdx: 0

    // ── Wallust ───────────────────────────────────────────────────────────
    readonly property var wallustBackends: ["kmeans", "wal", "full", "resized", "thumb", "fastresize"]
    readonly property var wallustPalettes: ["dark", "light", "dark16", "light16", "random"]
    property int wallustBackend: 0
    property int wallustPalette: 0
    property real wallustSaturation: 20
    property real wallustThreshold: 5
    property var wallustColors: []

    // Terminal contrast enforcement (0.0 = disabled, > 0 = min WCAG contrast ratio passed to enforce_contrast.py)
    // Practical range: 0.0 (off) → 1.5 → 3.0 (AA large text) → 4.5 (AA) → 7.0 (AAA)
    property real wallustEnforceContrast: 0.0
    // Extra lightness push past the minimum contrast point (0.0–0.5). Makes colors punchier.
    property real wallustContrastSpread: 0.0
    // Re-inflate saturation lost when lightness is moved (0.0–1.0). Keeps colors vivid.
    property real wallustSatCompensation: 0.0

    // wallustRows is set explicitly via onWallustColorsChanged so QML's
    // property change signal fires reliably — binding expressions on var
    // arrays are not always tracked correctly by the QML engine.
    property var wallustRows: []

    onWallustColorsChanged: {
        const c = wallustColors
        if (!c || c.length === 0) {
            wallustRows = []
            return
        }
        wallustRows = [
            { label: "special", colors: [
                { name: "bg", hex: c[0] ?? "#000" },
                { name: "fg", hex: c[1] ?? "#fff" }
            ]},
            { label: "normal", colors: [
                { name: "0", hex: c[2]  ?? "#000" }, { name: "1", hex: c[3]  ?? "#000" },
                { name: "2", hex: c[4]  ?? "#000" }, { name: "3", hex: c[5]  ?? "#000" },
                { name: "4", hex: c[6]  ?? "#000" }, { name: "5", hex: c[7]  ?? "#000" },
                { name: "6", hex: c[8]  ?? "#000" }, { name: "7", hex: c[9]  ?? "#000" }
            ]},
            { label: "bright", colors: [
                { name: "8",  hex: c[10] ?? "#000" }, { name: "9",  hex: c[11] ?? "#000" },
                { name: "10", hex: c[12] ?? "#000" }, { name: "11", hex: c[13] ?? "#000" },
                { name: "12", hex: c[14] ?? "#000" }, { name: "13", hex: c[15] ?? "#000" },
                { name: "14", hex: c[16] ?? "#000" }, { name: "15", hex: c[17] ?? "#000" }
            ]}
        ]
    }

    // ── Startup ───────────────────────────────────────────────────────────
    Component.onCompleted: {
        detectCurrentScheme()
        wallpaperPathProc.exec(wallpaperPathProc.command)
    }

    function detectCurrentScheme() {
        const currentType = Config.options.appearance.palette.type ?? "auto"
        const idx = schemes.indexOf(currentType)
        if (idx !== -1) selectedScheme = idx
        selectedMode = Appearance.m3colors.darkmode ? 0 : 1
    }

    // One-shot process for initial path + auto-load matugen
    Process {
        id: wallpaperPathProc
        command: ["bash", "-c", "jq -r '.background.wallpaperPath' ~/.config/illogical-impulse/config.json"]
        stdout: StdioCollector { id: wallpaperPathOut }
        onExited: {
            root.wallpaperPath = wallpaperPathOut.text.trim()
            if (root.wallpaperPath) {
                root.loading = true
                root.loadProgress = 0
                root._loadIdx = 0
                root.schemeColors = {}
                root._loadNext()
            }
        }
    }

    // Reusable path refresh — then routes to matugen or wallust based on mode
    Process {
        id: wallpaperProc
        command: ["bash", "-c", "jq -r '.background.wallpaperPath' ~/.config/illogical-impulse/config.json"]
        stdout: StdioCollector { id: wallpaperOut }
        onExited: {
            root.wallpaperPath = wallpaperOut.text.trim()
            if (!root.wallpaperPath) {
                root.loading = false
                root.statusMessage = "Could not detect wallpaper path"
                return
            }
            if (root.generatorMode === 0) {
                root._loadNext()
            } else {
                root._runWallust()
            }
        }
    }

    // ── loadAllSchemes (Reload button) ────────────────────────────────────
    function loadAllSchemes() {
        if (loading) return
        loading = true
        applied = false
        loadProgress = 0
        statusMessage = generatorMode === 1 ? "Running ✦ Wallust…" : "Refreshing…"
        if (generatorMode === 0) {
            _loadIdx = 0
            schemeColors = {}
        }
        // Always refresh wallpaper path first
        wallpaperProc.exec(wallpaperProc.command)
    }

    // ── Matugen loading ───────────────────────────────────────────────────
    function _loadNext() {
        if (_loadIdx >= schemes.length) {
            loading = false; statusMessage = "Ready"; return
        }
        const scheme = schemes[_loadIdx]
        statusMessage = `Loading ${scheme.replace("scheme-", "")} (${_loadIdx + 1}/${schemes.length})…`
        matugenProc.exec(["bash", "-c",
            `matugen image "${wallpaperPath}" --mode ${modes[selectedMode]} --type ${scheme} --contrast ${contrast.toFixed(1)} --json hex 2>/dev/null`
        ])
    }

    Process {
        id: matugenProc
        stdout: StdioCollector { id: matugenOut }
        onExited: {
            const scheme = root.schemes[root._loadIdx]
            const mode = root.modes[root.selectedMode]
            try {
                const parsed = JSON.parse(matugenOut.text)
                const colors = parsed?.colors ?? {}
                const swatches = {}
                for (const key of root.colorKeys) {
                    const hex = colors[key]?.[mode]
                    if (hex) swatches[key] = hex
                }
                const updated = Object.assign({}, root.schemeColors)
                updated[scheme] = swatches
                root.schemeColors = updated
            } catch (e) {}
            root.loadProgress = root._loadIdx + 1
            root._loadIdx++
            root._loadNext()
        }
    }
    // Raw wallust colors before contrast processing — stored so sliders can
    // update the preview instantly without re-running wallust.
    property var wallustRawColors: []

    // ── JS contrast enforcement (preview only) ────────────────────────────
    function _linearize(c) {
        c = c / 255.0
        return c <= 0.04045 ? c / 12.92 : Math.pow((c + 0.055) / 1.055, 2.4)
    }
    function _luminance(r, g, b) {
        return 0.2126 * _linearize(r) + 0.7152 * _linearize(g) + 0.0722 * _linearize(b)
    }
    function _contrastRatio(hex1, hex2) {
        const c1 = _hexToRgb(hex1), c2 = _hexToRgb(hex2)
        const l1 = _luminance(c1[0], c1[1], c1[2])
        const l2 = _luminance(c2[0], c2[1], c2[2])
        const lighter = Math.max(l1, l2), darker = Math.min(l1, l2)
        return (lighter + 0.05) / (darker + 0.05)
    }
    function _hexToRgb(hex) {
        hex = hex.replace("#", "")
        return [parseInt(hex.slice(0,2),16), parseInt(hex.slice(2,4),16), parseInt(hex.slice(4,6),16)]
    }
    function _rgbToHex(r, g, b) {
        return "#" + ("0"+Math.round(r).toString(16)).slice(-2) +
                     ("0"+Math.round(g).toString(16)).slice(-2) +
                     ("0"+Math.round(b).toString(16)).slice(-2)
    }
    function _rgbToHsl(r, g, b) {
        r /= 255; g /= 255; b /= 255
        const max = Math.max(r,g,b), min = Math.min(r,g,b)
        const delta = max - min
        let h = 0, s = 0, l = (max + min) / 2
        if (delta > 0) {
            s = delta / (1 - Math.abs(2*l - 1))
            if      (max === r) h = 60 * (((g-b)/delta) % 6)
            else if (max === g) h = 60 * (((b-r)/delta) + 2)
            else                h = 60 * (((r-g)/delta) + 4)
            if (h < 0) h += 360
        }
        return [h, s, l]
    }
    function _hslToRgb(h, s, l) {
        const c = (1 - Math.abs(2*l - 1)) * s
        const x = c * (1 - Math.abs((h/60) % 2 - 1))
        const m = l - c/2
        let r=0, g=0, b=0
        if      (h < 60)  { r=c; g=x; b=0 }
        else if (h < 120) { r=x; g=c; b=0 }
        else if (h < 180) { r=0; g=c; b=x }
        else if (h < 240) { r=0; g=x; b=c }
        else if (h < 300) { r=x; g=0; b=c }
        else              { r=c; g=0; b=x }
        return [(r+m)*255, (g+m)*255, (b+m)*255]
    }
    function _enforceOne(fgHex, bgHex, minRatio, spread, satComp) {
        if (minRatio <= 0 && spread === 0) return fgHex
        const fg = _hexToRgb(fgHex), bg = _hexToRgb(bgHex)
        const alreadyOk = _contrastRatio(fgHex, bgHex) >= minRatio
        const hsl = _rgbToHsl(fg[0], fg[1], fg[2])
        const bgHsl = _rgbToHsl(bg[0], bg[1], bg[2])
        const origS = hsl[1], fgL = hsl[2], bgL = bgHsl[2]

        const _adjust = (targetL) => {
            targetL = Math.max(0, Math.min(1, targetL))
            const blendedS = hsl[1] + (origS - hsl[1]) * satComp
            const finalS = Math.max(0, Math.min(1, blendedS))
            return _rgbToHex(..._hslToRgb(hsl[0], finalS, targetL))
        }

        if (alreadyOk) {
            if (spread === 0) return fgHex
            const chosenL = fgL >= bgL ? Math.min(1, fgL + spread) : Math.max(0, fgL - spread)
            return _adjust(chosenL)
        }

        let bestLightL = null, bestDarkL = null
        for (let s = 1; s <= 100; s++) {
            const cL = fgL + s * 0.01
            if (cL > 1) break
            if (_contrastRatio(_adjust(cL), bgHex) >= minRatio) { bestLightL = cL; break }
        }
        for (let s = 1; s <= 100; s++) {
            const cL = fgL - s * 0.01
            if (cL < 0) break
            if (_contrastRatio(_adjust(cL), bgHex) >= minRatio) { bestDarkL = cL; break }
        }
        if (bestLightL === null && bestDarkL === null) return fgHex
        let chosenL = bestLightL === null ? bestDarkL
                    : bestDarkL === null  ? bestLightL
                    : Math.abs(bestLightL-fgL) <= Math.abs(bestDarkL-fgL) ? bestLightL : bestDarkL
        if (spread > 0)
            chosenL = chosenL >= bgL ? Math.min(1, chosenL+spread) : Math.max(0, chosenL-spread)
        return _adjust(chosenL)
    }

    function _applyContrastToPreview() {
        const raw = wallustRawColors
        if (!raw || raw.length === 0) return
        if (wallustEnforceContrast <= 0 && wallustContrastSpread === 0 && wallustSatCompensation === 0) {
            wallustColors = raw.slice()
            return
        }
        const mc = wallustEnforceContrast, sp = wallustContrastSpread, sc = wallustSatCompensation
        const result = raw.slice()
        const bg = result[0]  // term0 = background
        // Enforce colors 1–15 against background
        for (let i = 1; i < result.length; i++)
            result[i] = _enforceOne(result[i], bg, mc, sp, sc)
        wallustColors = []
        wallustColors = result
    }

    onWallustEnforceContrastChanged: _applyContrastToPreview()
    onWallustContrastSpreadChanged:  _applyContrastToPreview()
    onWallustSatCompensationChanged: _applyContrastToPreview()

    // ── Wallust process ───────────────────────────────────────────────────
    // Run wallust and read output in one process — avoids two-step chain issues.
    // wallust writes to ~/.cache/wal/colors.json via its template config.
    // We run it then cat the file. The preview swatches show raw wallust output.
    // Contrast enforcement happens at apply-time via enforce_contrast_scss.py
    // which patches material_colors.scss — the actual source for terminal colors.
    function _runWallust() {
        if (!wallpaperPath) {
            statusMessage = "No wallpaper path found"
            loading = false
            return
        }
        const backend = wallustBackends[wallustBackend]
        const palette = wallustPalettes[wallustPalette]
        statusMessage = `Running ✦ Wallust (${backend}, ${palette})…`
        wallustProc.exec(["bash", "-lc",
            `wallust run "${wallpaperPath}"` +
            ` --backend ${backend}` +
            ` --palette ${palette}` +
            ` --saturation ${wallustSaturation.toFixed(0)}` +
            ` --threshold ${wallustThreshold.toFixed(0)}` +
            ` >/dev/null 2>&1` +
            ` && python3 -c "import sys; sys.stdout.write(open(__import__('os').path.expanduser('~/.cache/wal/colors.json')).read())"`
        ])
    }

    Process {
        id: wallustProc
        stdout: StdioCollector { id: wallustOut }
        stderr: StdioCollector { id: wallustErr }
        onExited: function(exitCode, exitStatus) {
            root.loading = false
            if (exitCode !== 0) {
                root.statusMessage = "✦ Wallust error: " + wallustErr.text.trim().slice(0, 120)
                return
            }
            const raw = wallustOut.text.trim()
            if (!raw) {
                root.statusMessage = "✦ Wallust: empty output"
                return
            }
            try {
                const parsed = JSON.parse(raw)
                const cols = []
                const special = parsed?.special ?? {}
                cols.push(special.background ?? "#000000")
                cols.push(special.foreground ?? "#ffffff")
                const c = parsed?.colors ?? {}
                for (let i = 0; i <= 15; i++)
                    cols.push(c[`color${i}`] ?? "#333333")
                // Store raw colors then apply contrast for preview
                root.wallustRawColors = cols.slice()
                root._applyContrastToPreview()
                root.statusMessage = "Preview ready — hit Apply to use"
            } catch(e) {
                root.statusMessage = "✦ Wallust: JSON parse error — " + e.message
            }
        }
    }

    // ── Apply ─────────────────────────────────────────────────────────────
    // Before calling apply-colors we write enforce_contrast.cfg so that
    // apply-colors' step 6b (enforce_contrast_scss.py) picks up the current
    // slider values and patches material_colors.scss in-place.
    function _writeEnforceContrastConfig() {
        const mc = wallustEnforceContrast.toFixed(2)
        const sp = wallustContrastSpread.toFixed(2)
        const sc = wallustSatCompensation.toFixed(2)
        const wm = (generatorMode === 1) ? "1" : "0"
        const cfgContent = "min_contrast=" + mc + "\\nspread=" + sp + "\\nsat_compensation=" + sc + "\\nwallust_mode=" + wm + "\\n"
        const cfgPath = "$HOME/.local/state/quickshell/user/generated/enforce_contrast.cfg"
        return "mkdir -p \"$HOME/.local/state/quickshell/user/generated\" && " +
               "printf '" + cfgContent + "' > \"" + cfgPath + "\" && "
    }

    function applyScheme() {
        if (applying || loading) return
        applying = true; statusMessage = "Applying…"
        // Write enforce_contrast.json first so apply-colors picks it up via
        // enforce_contrast_scss.py after material_colors.scss is regenerated.
        // Then call switchwall.sh --noswitch which: reads wallpaper from config,
        // runs wallust + generate_colors_material.py → material_colors.scss,
        // then calls apply-colors. This is the same path as a normal wallpaper
        // switch, just without changing the wallpaper.
        const modeArg = modes[selectedMode]
        const schemeArg = schemes[selectedScheme]
        applyProc.exec(["bash", "-lc",
            _writeEnforceContrastConfig() +
            `~/.config/quickshell/ii/scripts/colors/switchwall.sh --noswitch` +
            (generatorMode === 0 ? ` --mode ${modeArg} --type ${schemeArg}` : "")
        ])
    }

    Process {
        id: applyProc
        onExited: {
            root.applying = false; root.applied = true
            root.statusMessage = root.generatorMode === 1
                ? "✔ Applied ✦ Wallust"
                : `✔ Applied ${root.schemes[root.selectedScheme]}`
            if (root.generatorMode === 0)
                Config.options.appearance.palette.type = root.schemes[root.selectedScheme]
        }
    }

    // Auto-trigger wallust preview when switching to wallust tab
    onGeneratorModeChanged: {
        if (generatorMode === 1) {
            if (applying) return
            // Only auto-run if we don't already have a fresh preview
            if (wallustColors.length === 0) {
                loading = true
                statusMessage = "Running ✦ Wallust…"
                wallpaperProc.exec(wallpaperProc.command)
            }
        } else {
            loading = false
            statusMessage = schemeColors && Object.keys(schemeColors).length > 0 ? "Ready" : ""
        }
    }
}
