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

    // ── Wallust ───────────────────────────────────────────────────────────
    // Run wallust and read output in one process — avoids two-step chain issues.
    // wallust writes to ~/.cache/wal/colors.json via its template config.
    // We run it and then cat the output file, piping both as JSON to stdout.
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
            ` >/dev/null 2>&1 && python3 -c "import sys; sys.stdout.write(open(__import__('os').path.expanduser('~/.cache/wal/colors.json')).read())"`
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
                // special: background and foreground
                const special = parsed?.special ?? {}
                cols.push(special.background ?? "#000000")
                cols.push(special.foreground ?? "#ffffff")
                // colors: color0..color15
                const c = parsed?.colors ?? {}
                for (let i = 0; i <= 15; i++) {
                    cols.push(c[`color${i}`] ?? "#333333")
                }
                // Reassign via temp to guarantee QML property change signal fires
                const next = cols.slice()
                root.wallustColors = []
                root.wallustColors = next
                root.statusMessage = "Preview ready — hit Apply to use"
            } catch(e) {
                root.statusMessage = "✦ Wallust: JSON parse error — " + e.message
            }
        }
    }

    // ── Apply ─────────────────────────────────────────────────────────────
    function applyScheme() {
        if (applying || loading) return
        applying = true; statusMessage = "Applying…"
        if (generatorMode === 1) {
            const backend = wallustBackends[wallustBackend]
            const palette = wallustPalettes[wallustPalette]
            applyProc.exec(["bash", "-c",
                `wallust run "${wallpaperPath}" --backend ${backend} --palette ${palette}` +
                ` --saturation ${wallustSaturation.toFixed(0)} --threshold ${wallustThreshold.toFixed(0)}` +
                ` && apply-colors`
            ])
        } else {
            applyProc.exec(["bash", "-c",
                `matugen image "${wallpaperPath}" --mode ${modes[selectedMode]} --type ${schemes[selectedScheme]} --contrast ${contrast.toFixed(1)} && apply-colors`
            ])
        }
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
