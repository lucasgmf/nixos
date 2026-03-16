pragma Singleton
pragma ComponentBehavior: Bound

import qs.modules.common
import qs.services
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

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
    property bool loading: false
    property int loadProgress: 0
    property string statusMessage: ""
    property bool applied: false
    property bool applying: false
    property string wallpaperPath: ""
    property var schemeColors: ({})
    property int _loadIdx: 0

    // ── Detect current scheme from config ────────────────────────────────
    function detectCurrentScheme() {
        // Scheme type
        const currentType = Config.options.appearance.palette.type ?? "auto"
        const idx = schemes.indexOf(currentType)
        if (idx !== -1) selectedScheme = idx

        // Mode from darkmode flag
        selectedMode = Appearance.m3colors.darkmode ? 0 : 1
    }

    // ── Wallpaper path ────────────────────────────────────────────────────
    Process {
        id: wallpaperProc
        command: ["bash", "-c", "jq -r '.background.wallpaperPath' ~/.config/illogical-impulse/config.json"]
        stdout: StdioCollector { id: wallpaperOut }
        onExited: {
            root.wallpaperPath = wallpaperOut.text.trim()
            if (root.wallpaperPath && root.loading) {
                root._loadNext()
            } else if (root.wallpaperPath) {
                root.loadAllSchemes()
            }
        }
    }

    Component.onCompleted: {
        detectCurrentScheme()
        wallpaperProc.exec(wallpaperProc.command)
    }

    // ── Load all schemes ──────────────────────────────────────────────────
    function loadAllSchemes() {
        loading = true
        applied = false
        loadProgress = 0
        _loadIdx = 0
        schemeColors = {}
        statusMessage = "Refreshing wallpaper path…"
        // Re-read wallpaper path first, then load schemes
        wallpaperProc.exec(wallpaperProc.command)
    }

    function _loadNext() {
        if (_loadIdx >= schemes.length) {
            loading = false
            statusMessage = "Ready"
            return
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

    // ── Apply ─────────────────────────────────────────────────────────────
    function applyScheme() {
        if (applying || loading) return
        applying = true
        statusMessage = "Applying…"
        applyProc.exec([
            "bash", "-c",
            `matugen image "${wallpaperPath}" --mode ${modes[selectedMode]} --type ${schemes[selectedScheme]} --contrast ${contrast.toFixed(1)} && apply-colors`
        ])
    }

    Process {
        id: applyProc
        onExited: {
            root.applying = false
            root.applied = true
            root.statusMessage = `✔ Applied ${root.schemes[root.selectedScheme]}`
            // Update config so it persists
            Config.options.appearance.palette.type = root.schemes[root.selectedScheme]
        }
    }
}
