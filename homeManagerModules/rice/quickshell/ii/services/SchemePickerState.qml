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
    property real wallustSaturation: 2
    property real wallustThreshold: 5
    property var wallustColors: []

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

    // One-shot process just for initial path + auto-load
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

    // Reload wallpaper path then continue based on mode
    Process {
        id: wallpaperProc
        command: ["bash", "-c", "jq -r '.background.wallpaperPath' ~/.config/illogical-impulse/config.json"]
        stdout: StdioCollector { id: wallpaperOut }
        onExited: {
            root.wallpaperPath = wallpaperOut.text.trim()
            if (root.wallpaperPath && root.loading) {
                if (root.generatorMode === 0) root._loadNext()
                else root._runWallust()
            }
        }
    }

    // ── loadAllSchemes ────────────────────────────────────────────────────
    function loadAllSchemes() {
        loading = true; applied = false
        loadProgress = 0; _loadIdx = 0; schemeColors = {}
        statusMessage = generatorMode === 1 ? "Running ✦ Wallust…" : "Refreshing…"
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
    function _runWallust() {
        statusMessage = "Running ✦ Wallust…"
        const backend = wallustBackends[wallustBackend]
        const palette = wallustPalettes[wallustPalette]
        const cmd =
            `wallust run "${wallpaperPath}" --backend ${backend} --palette ${palette}` +
            ` --saturation ${wallustSaturation.toFixed(0)} --threshold ${wallustThreshold.toFixed(0)}` +
            ` > /dev/null 2>&1 && cat "$HOME/.cache/wal/colors.json"`
        wallustProc.exec(["bash", "-c", cmd])
    }

    Process {
        id: wallustProc
        stdout: StdioCollector { id: wallustOut }
        onExited: {
            root.loading = false
            const raw = wallustOut.text
            const jsonStart = raw.indexOf("{")
            const jsonEnd = raw.lastIndexOf("}") + 1
            const out = jsonStart >= 0 && jsonEnd > jsonStart ? raw.slice(jsonStart, jsonEnd) : ""
            if (!out) { root.statusMessage = "Wallust failed — check terminal"; return }
            try {
                const parsed = JSON.parse(out)
                const cols = []
                const special = parsed?.special ?? {}
                if (special.background) cols.push(special.background)
                if (special.foreground) cols.push(special.foreground)
                const c = parsed?.colors ?? {}
                for (let i = 0; i <= 15; i++) {
                    const entry = c?.[`color${i}`]
                    cols.push(typeof entry === "string" ? entry : (entry?.hex ?? "#333333"))
                }
                root.wallustColors = []
                root.wallustColors = cols.slice()
                root.statusMessage = "Preview ready — hit Apply to use"
            } catch(e) {
                root.statusMessage = "Wallust error — check terminal"
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

    // Auto-run wallust preview when switching to wallust mode
    onGeneratorModeChanged: {
        if (generatorMode === 1) {
            if (applying) return
            loading = true
            _runWallust()
        } else {
            // Cancel any in-progress wallust load when switching back
            loading = false
            statusMessage = schemeColors && Object.keys(schemeColors).length > 0 ? "Ready" : ""
        }
    }
}
