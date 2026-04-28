pragma ComponentBehavior: Bound

import qs.modules.common
import qs.modules.common.widgets
import qs.services
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

FloatingWindow {
    id: win

    signal requestClose()

    implicitWidth: 900
    implicitHeight: 700
    color: "transparent"

    StyledRectangularShadow { target: panel }

    Rectangle {
        id: panel
        anchors.fill: parent
        radius: Appearance.rounding.screenRounding
        color: Appearance.colors.colLayer0
        border.color: Appearance.colors.colLayer0Border
        border.width: 1
        clip: true

        focus: true
        Keys.onPressed: function(event) {
            if (event.key === Qt.Key_Escape) {
                win.requestClose(); event.accepted = true
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                SchemePickerState.applyScheme(); event.accepted = true
            } else if (event.key === Qt.Key_Up && SchemePickerState.selectedScheme > 0) {
                SchemePickerState.selectedScheme--; event.accepted = true
            } else if (event.key === Qt.Key_Down &&
                       SchemePickerState.selectedScheme < SchemePickerState.schemes.length - 1) {
                SchemePickerState.selectedScheme++; event.accepted = true
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 0

            // ── Header ───────────────────────────────────────────────────
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                MaterialSymbol {
                    text: "palette"; iconSize: 24
                    color: Appearance.m3colors.m3primary
                }
                Column {
                    spacing: 2
                    Text {
                        text: "Color Scheme Picker"
                        color: Appearance.m3colors.m3onBackground
                        font.pixelSize: Appearance.font.pixelSize.normal
                        font.weight: Font.DemiBold
                        font.family: Appearance.font.family.main
                    }
                    Text {
                        text: {
                            const p = SchemePickerState.wallpaperPath
                            return p.length > 72 ? "…" + p.slice(-69) : (p || "detecting wallpaper…")
                        }
                        color: Appearance.m3colors.m3outline
                        font.pixelSize: Appearance.font.pixelSize.smallest
                        font.family: Appearance.font.family.monospace
                    }
                }

                Item { Layout.fillWidth: true }

                // ── Mode toggle: Matugen / Wallust ────────────────────────
                Rectangle {
                    height: 32
                    implicitWidth: modeRow.implicitWidth + 6
                    radius: Appearance.rounding.full
                    color: Appearance.colors.colLayer2
                    border.color: Appearance.colors.colOutlineVariant
                    border.width: 1

                    Row {
                        id: modeRow
                        anchors.centerIn: parent
                        spacing: 2
                        padding: 3

                        Repeater {
                            model: ["Matugen", "✦ Wallust"]
                            delegate: Rectangle {
                                required property string modelData
                                required property int index
                                height: 26
                                implicitWidth: modeLabel.implicitWidth + 20
                                radius: Appearance.rounding.full
                                color: SchemePickerState.generatorMode === index
                                    ? Appearance.m3colors.m3primaryContainer
                                    : (mth.containsMouse ? Appearance.colors.colLayer3 : "transparent")
                                Text {
                                    id: modeLabel
                                    anchors.centerIn: parent
                                    text: parent.modelData
                                    color: SchemePickerState.generatorMode === parent.index
                                        ? Appearance.m3colors.m3onPrimaryContainer
                                        : Appearance.m3colors.m3onSurfaceVariant
                                    font.pixelSize: Appearance.font.pixelSize.smaller
                                    font.family: Appearance.font.family.main
                                    font.weight: SchemePickerState.generatorMode === parent.index
                                        ? Font.Medium : Font.Normal
                                }
                                HoverHandler { id: mth }
                                TapHandler { onTapped: SchemePickerState.generatorMode = index }
                                Behavior on color { ColorAnimation { duration: Appearance.animationCurves.expressiveEffectsDuration } }
                            }
                        }
                    }
                }

                // Close button
                Rectangle {
                    width: 32; height: 32; radius: Appearance.rounding.full
                    color: closeHov.containsMouse ? Appearance.colors.colLayer2Hover : "transparent"
                    MaterialSymbol { anchors.centerIn: parent; text: "close"; iconSize: 18; color: Appearance.m3colors.m3outline }
                    HoverHandler { id: closeHov }
                    TapHandler { onTapped: win.requestClose() }
                    Behavior on color { ColorAnimation { duration: Appearance.animationCurves.expressiveEffectsDuration } }
                }
            }

            Rectangle {
                Layout.fillWidth: true; height: 1; color: Appearance.colors.colOutlineVariant
                Layout.topMargin: 14; Layout.bottomMargin: 14
            }

            // ── Matugen controls ──────────────────────────────────────────
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 12
                visible: SchemePickerState.generatorMode === 0

                RowLayout {
                    Layout.fillWidth: true; spacing: 20

                    Column {
                        spacing: 6
                        Text { text: "MODE"; color: Appearance.m3colors.m3outline; font.pixelSize: Appearance.font.pixelSize.smallest; font.letterSpacing: 1.5; font.family: Appearance.font.family.main; font.weight: Font.Medium }
                        Row {
                            spacing: 4
                            Repeater {
                                model: SchemePickerState.modes
                                delegate: Rectangle {
                                    required property string modelData
                                    required property int index
                                    width: 64; height: 30; radius: Appearance.rounding.full
                                    color: SchemePickerState.selectedMode === index ? Appearance.m3colors.m3primaryContainer : (mh.containsMouse ? Appearance.colors.colLayer2Hover : Appearance.colors.colLayer1)
                                    border.color: SchemePickerState.selectedMode === index ? Appearance.m3colors.m3primary : Appearance.colors.colOutlineVariant; border.width: 1
                                    Text { anchors.centerIn: parent; text: parent.modelData; color: SchemePickerState.selectedMode === parent.index ? Appearance.m3colors.m3onPrimaryContainer : Appearance.m3colors.m3onSurfaceVariant; font.pixelSize: Appearance.font.pixelSize.smaller; font.family: Appearance.font.family.main; font.weight: SchemePickerState.selectedMode === parent.index ? Font.Medium : Font.Normal }
                                    HoverHandler { id: mh }
                                    TapHandler { onTapped: SchemePickerState.selectedMode = index }
                                    Behavior on color { ColorAnimation { duration: Appearance.animationCurves.expressiveEffectsDuration } }
                                }
                            }
                        }
                    }

                    Column {
                        spacing: 6; Layout.fillWidth: true
                        RowLayout {
                            width: parent.width
                            Text { text: "CONTRAST"; color: Appearance.m3colors.m3outline; font.pixelSize: Appearance.font.pixelSize.smallest; font.letterSpacing: 1.5; font.family: Appearance.font.family.main; font.weight: Font.Medium }
                            Item { Layout.fillWidth: true }
                            Text { text: SchemePickerState.contrast.toFixed(1); color: SchemePickerState.contrast === 0 ? Appearance.m3colors.m3outline : Appearance.m3colors.m3primary; font.pixelSize: Appearance.font.pixelSize.smaller; font.family: Appearance.font.family.numbers; font.weight: Font.Medium }
                        }
                        StyledSlider {
                            width: parent.width; from: -1.0; to: 1.0; stepSize: 0.1
                            value: SchemePickerState.contrast
                            onMoved: SchemePickerState.contrast = value
                        }
                    }

                    Item {
                        id: wallpaperContainer
                        property real previewHeight: 160
                        Layout.preferredWidth: previewHeight * (16 / 9)
                        Layout.preferredHeight: previewHeight
                        Image {
                            anchors.fill: parent
                            source: SchemePickerState.wallpaperPath ? Qt.resolvedUrl("file://" + SchemePickerState.wallpaperPath) : ""
                            fillMode: Image.PreserveAspectFit
                            asynchronous: true; smooth: true
                        }
                        Item {
                            anchors.right: parent.right; anchors.bottom: parent.bottom
                            width: 18; height: 18
                            Rectangle { width: 10; height: 2; radius: 1; anchors.right: parent.right; anchors.bottom: parent.bottom; anchors.rightMargin: 2; anchors.bottomMargin: 6; rotation: -45; color: dragM.active ? Appearance.m3colors.m3primary : Appearance.m3colors.m3outline; opacity: 0.7 }
                            Rectangle { width: 6; height: 2; radius: 1; anchors.right: parent.right; anchors.bottom: parent.bottom; anchors.rightMargin: 2; anchors.bottomMargin: 2; rotation: -45; color: dragM.active ? Appearance.m3colors.m3primary : Appearance.m3colors.m3outline; opacity: 0.7 }
                            DragHandler { id: dragM; target: null; onTranslationChanged: wallpaperContainer.previewHeight = Math.max(60, Math.min(400, wallpaperContainer.previewHeight + translation.y)) }
                        }
                    }

                    Rectangle {
                        width: 88; height: 56; radius: Appearance.rounding.normal
                        color: rh.containsMouse ? Appearance.colors.colLayer2Hover : Appearance.colors.colLayer1
                        border.color: Appearance.colors.colOutlineVariant; border.width: 1
                        opacity: SchemePickerState.loading ? 0.5 : 1.0
                        Column {
                            anchors.centerIn: parent
                            spacing: 3
                            MaterialSymbol { anchors.horizontalCenter: parent.horizontalCenter; text: "refresh"; iconSize: 20; color: Appearance.m3colors.m3primary }
                            Text { anchors.horizontalCenter: parent.horizontalCenter; text: "Reload"; color: Appearance.m3colors.m3onSurfaceVariant; font.pixelSize: Appearance.font.pixelSize.smallest; font.family: Appearance.font.family.main }
                        }
                        HoverHandler { id: rh }
                        TapHandler { onTapped: if (!SchemePickerState.loading) SchemePickerState.loadAllSchemes() }
                        Behavior on color { ColorAnimation { duration: Appearance.animationCurves.expressiveEffectsDuration } }
                        Behavior on opacity { NumberAnimation { duration: Appearance.animationCurves.expressiveEffectsDuration } }
                    }
                }
            }

            // ── Wallust controls ──────────────────────────────────────────
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 10
                visible: SchemePickerState.generatorMode === 1

                RowLayout {
                    Layout.fillWidth: true; spacing: 20

                    Column {
                        spacing: 6
                        Text { text: "BACKEND"; color: Appearance.m3colors.m3outline; font.pixelSize: Appearance.font.pixelSize.smallest; font.letterSpacing: 1.5; font.family: Appearance.font.family.main; font.weight: Font.Medium }
                        Row {
                            spacing: 4
                            Repeater {
                                model: SchemePickerState.wallustBackends
                                delegate: Rectangle {
                                    required property string modelData
                                    required property int index
                                    implicitWidth: btLabel.implicitWidth + 20; height: 30; radius: Appearance.rounding.full
                                    color: SchemePickerState.wallustBackend === index ? Appearance.m3colors.m3primaryContainer : (bth.containsMouse ? Appearance.colors.colLayer2Hover : Appearance.colors.colLayer1)
                                    border.color: SchemePickerState.wallustBackend === index ? Appearance.m3colors.m3primary : Appearance.colors.colOutlineVariant; border.width: 1
                                    Text { id: btLabel; anchors.centerIn: parent; text: parent.modelData; color: SchemePickerState.wallustBackend === parent.index ? Appearance.m3colors.m3onPrimaryContainer : Appearance.m3colors.m3onSurfaceVariant; font.pixelSize: Appearance.font.pixelSize.smaller; font.family: Appearance.font.family.main }
                                    HoverHandler { id: bth }
                                    TapHandler { onTapped: SchemePickerState.wallustBackend = index }
                                    Behavior on color { ColorAnimation { duration: Appearance.animationCurves.expressiveEffectsDuration } }
                                }
                            }
                        }
                    }

                    Column {
                        spacing: 6
                        Text { text: "PALETTE"; color: Appearance.m3colors.m3outline; font.pixelSize: Appearance.font.pixelSize.smallest; font.letterSpacing: 1.5; font.family: Appearance.font.family.main; font.weight: Font.Medium }
                        Row {
                            spacing: 4
                            Repeater {
                                model: SchemePickerState.wallustPalettes
                                delegate: Rectangle {
                                    required property string modelData
                                    required property int index
                                    implicitWidth: plLabel.implicitWidth + 20; height: 30; radius: Appearance.rounding.full
                                    color: SchemePickerState.wallustPalette === index ? Appearance.m3colors.m3primaryContainer : (plh.containsMouse ? Appearance.colors.colLayer2Hover : Appearance.colors.colLayer1)
                                    border.color: SchemePickerState.wallustPalette === index ? Appearance.m3colors.m3primary : Appearance.colors.colOutlineVariant; border.width: 1
                                    Text { id: plLabel; anchors.centerIn: parent; text: parent.modelData; color: SchemePickerState.wallustPalette === parent.index ? Appearance.m3colors.m3onPrimaryContainer : Appearance.m3colors.m3onSurfaceVariant; font.pixelSize: Appearance.font.pixelSize.smaller; font.family: Appearance.font.family.main }
                                    HoverHandler { id: plh }
                                    TapHandler { onTapped: SchemePickerState.wallustPalette = index }
                                    Behavior on color { ColorAnimation { duration: Appearance.animationCurves.expressiveEffectsDuration } }
                                }
                            }
                        }
                    }

                    Item { Layout.fillWidth: true }

                    Item {
                        id: wallpaperContainerW
                        property real previewHeight: 140
                        Layout.preferredWidth: previewHeight * (16 / 9)
                        Layout.preferredHeight: previewHeight
                        Image {
                            anchors.fill: parent
                            source: SchemePickerState.wallpaperPath ? Qt.resolvedUrl("file://" + SchemePickerState.wallpaperPath) : ""
                            fillMode: Image.PreserveAspectFit
                            asynchronous: true; smooth: true
                        }
                        Item {
                            anchors.right: parent.right; anchors.bottom: parent.bottom
                            width: 18; height: 18
                            Rectangle { width: 10; height: 2; radius: 1; anchors.right: parent.right; anchors.bottom: parent.bottom; anchors.rightMargin: 2; anchors.bottomMargin: 6; rotation: -45; color: dragW.active ? Appearance.m3colors.m3primary : Appearance.m3colors.m3outline; opacity: 0.7 }
                            Rectangle { width: 6; height: 2; radius: 1; anchors.right: parent.right; anchors.bottom: parent.bottom; anchors.rightMargin: 2; anchors.bottomMargin: 2; rotation: -45; color: dragW.active ? Appearance.m3colors.m3primary : Appearance.m3colors.m3outline; opacity: 0.7 }
                            DragHandler { id: dragW; target: null; onTranslationChanged: wallpaperContainerW.previewHeight = Math.max(60, Math.min(400, wallpaperContainerW.previewHeight + translation.y)) }
                        }
                    }

                    Rectangle {
                        width: 88; height: 56; radius: Appearance.rounding.normal
                        color: rwh.containsMouse ? Appearance.colors.colLayer2Hover : Appearance.colors.colLayer1
                        border.color: Appearance.colors.colOutlineVariant; border.width: 1
                        opacity: SchemePickerState.loading ? 0.5 : 1.0
                        Column {
                            anchors.centerIn: parent
                            spacing: 3
                            MaterialSymbol { anchors.horizontalCenter: parent.horizontalCenter; text: "refresh"; iconSize: 20; color: Appearance.m3colors.m3primary }
                            Text { anchors.horizontalCenter: parent.horizontalCenter; text: "Reload"; color: Appearance.m3colors.m3onSurfaceVariant; font.pixelSize: Appearance.font.pixelSize.smallest; font.family: Appearance.font.family.main }
                        }
                        HoverHandler { id: rwh }
                        TapHandler { onTapped: if (!SchemePickerState.loading) SchemePickerState.loadAllSchemes() }
                        Behavior on color { ColorAnimation { duration: Appearance.animationCurves.expressiveEffectsDuration } }
                        Behavior on opacity { NumberAnimation { duration: Appearance.animationCurves.expressiveEffectsDuration } }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true; spacing: 24

                    Column { spacing: 4; Layout.fillWidth: true
                        RowLayout { width: parent.width
                            Text { text: "SATURATION"; color: Appearance.m3colors.m3outline; font.pixelSize: Appearance.font.pixelSize.smallest; font.letterSpacing: 1.5; font.family: Appearance.font.family.main; font.weight: Font.Medium }
                            Item { Layout.fillWidth: true }
                            Text { text: SchemePickerState.wallustSaturation.toFixed(0); color: Appearance.m3colors.m3primary; font.pixelSize: Appearance.font.pixelSize.smaller; font.family: Appearance.font.family.numbers }
                        }
                        StyledSlider { width: parent.width; from: 0; to: 100; stepSize: 5; value: SchemePickerState.wallustSaturation; onMoved: SchemePickerState.wallustSaturation = value }
                    }

                    Column { spacing: 4; Layout.fillWidth: true
                        RowLayout { width: parent.width
                            Text { text: "THRESHOLD"; color: Appearance.m3colors.m3outline; font.pixelSize: Appearance.font.pixelSize.smallest; font.letterSpacing: 1.5; font.family: Appearance.font.family.main; font.weight: Font.Medium }
                            Text { text: "lower = more colors"; color: Appearance.m3colors.m3outline; font.pixelSize: Appearance.font.pixelSize.smallest; font.family: Appearance.font.family.main; opacity: 0.5 }
                            Item { Layout.fillWidth: true }
                            Text { text: SchemePickerState.wallustThreshold.toFixed(0); color: Appearance.m3colors.m3primary; font.pixelSize: Appearance.font.pixelSize.smaller; font.family: Appearance.font.family.numbers }
                        }
                        StyledSlider { width: parent.width; from: 1; to: 30; stepSize: 1; value: SchemePickerState.wallustThreshold; onMoved: SchemePickerState.wallustThreshold = value }
                    }

                    Column { spacing: 4; Layout.fillWidth: true
                        RowLayout { width: parent.width
                            Text { text: "TERMINAL CONTRAST"; color: Appearance.m3colors.m3outline; font.pixelSize: Appearance.font.pixelSize.smallest; font.letterSpacing: 1.5; font.family: Appearance.font.family.main; font.weight: Font.Medium }
                            Text { text: "WCAG ratio"; color: Appearance.m3colors.m3outline; font.pixelSize: Appearance.font.pixelSize.smallest; font.family: Appearance.font.family.main; opacity: 0.5 }
                            Item { Layout.fillWidth: true }
                            Text {
                                text: SchemePickerState.wallustEnforceContrast <= 0
                                    ? "off"
                                    : SchemePickerState.wallustEnforceContrast.toFixed(1)
                                color: SchemePickerState.wallustEnforceContrast <= 0
                                    ? Appearance.m3colors.m3outline
                                    : Appearance.m3colors.m3primary
                                font.pixelSize: Appearance.font.pixelSize.smaller
                                font.family: Appearance.font.family.numbers
                            }
                        }
                        StyledSlider {
                            width: parent.width; from: 0.0; to: 7.0; stepSize: 0.5
                            value: SchemePickerState.wallustEnforceContrast
                            onMoved: SchemePickerState.wallustEnforceContrast = value
                        }
                    }

                    Column { spacing: 4; Layout.fillWidth: true
                        RowLayout { width: parent.width
                            Text { text: "SPREAD"; color: Appearance.m3colors.m3outline; font.pixelSize: Appearance.font.pixelSize.smallest; font.letterSpacing: 1.5; font.family: Appearance.font.family.main; font.weight: Font.Medium }
                            Text { text: "extra punch"; color: Appearance.m3colors.m3outline; font.pixelSize: Appearance.font.pixelSize.smallest; font.family: Appearance.font.family.main; opacity: 0.5 }
                            Item { Layout.fillWidth: true }
                            Text {
                                text: SchemePickerState.wallustContrastSpread <= 0
                                    ? "off"
                                    : SchemePickerState.wallustContrastSpread.toFixed(2)
                                color: SchemePickerState.wallustContrastSpread <= 0
                                    ? Appearance.m3colors.m3outline
                                    : Appearance.m3colors.m3primary
                                font.pixelSize: Appearance.font.pixelSize.smaller
                                font.family: Appearance.font.family.numbers
                            }
                        }
                        StyledSlider {
                            width: parent.width; from: 0.0; to: 0.5; stepSize: 0.05
                            value: SchemePickerState.wallustContrastSpread
                            onMoved: SchemePickerState.wallustContrastSpread = value
                        }
                    }

                    Column { spacing: 4; Layout.fillWidth: true
                        RowLayout { width: parent.width
                            Text { text: "SAT COMP"; color: Appearance.m3colors.m3outline; font.pixelSize: Appearance.font.pixelSize.smallest; font.letterSpacing: 1.5; font.family: Appearance.font.family.main; font.weight: Font.Medium }
                            Text { text: "keep vivid"; color: Appearance.m3colors.m3outline; font.pixelSize: Appearance.font.pixelSize.smallest; font.family: Appearance.font.family.main; opacity: 0.5 }
                            Item { Layout.fillWidth: true }
                            Text {
                                text: SchemePickerState.wallustSatCompensation <= 0
                                    ? "off"
                                    : SchemePickerState.wallustSatCompensation.toFixed(2)
                                color: SchemePickerState.wallustSatCompensation <= 0
                                    ? Appearance.m3colors.m3outline
                                    : Appearance.m3colors.m3primary
                                font.pixelSize: Appearance.font.pixelSize.smaller
                                font.family: Appearance.font.family.numbers
                            }
                        }
                        StyledSlider {
                            width: parent.width; from: 0.0; to: 1.0; stepSize: 0.05
                            value: SchemePickerState.wallustSatCompensation
                            onMoved: SchemePickerState.wallustSatCompensation = value
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true; height: 1; color: Appearance.colors.colOutlineVariant
                Layout.topMargin: 10; Layout.bottomMargin: 8
            }

            // ── Progress bar ─────────────────────────────────────────────
            RowLayout {
                Layout.fillWidth: true; visible: SchemePickerState.loading; spacing: 10
                StyledProgressBar {
                    Layout.fillWidth: true
                    value: SchemePickerState.generatorMode === 0 && SchemePickerState.schemes.length > 0
                        ? SchemePickerState.loadProgress / SchemePickerState.schemes.length
                        : 1.0
                }
                Text { text: SchemePickerState.statusMessage; color: Appearance.m3colors.m3outline; font.pixelSize: Appearance.font.pixelSize.smallest; font.family: Appearance.font.family.main }
            }

            // ── Scheme list (matugen) ─────────────────────────────────────
            ListView {
                id: schemeList
                Layout.fillWidth: true
                Layout.fillHeight: SchemePickerState.generatorMode === 0
                Layout.preferredHeight: SchemePickerState.generatorMode === 0 ? -1 : 0
                Layout.topMargin: 4
                clip: true; spacing: 2
                visible: SchemePickerState.generatorMode === 0
                model: SchemePickerState.schemes
                ScrollBar.vertical: StyledScrollBar {}

                delegate: Rectangle {
                    required property string modelData
                    required property int index
                    width: schemeList.width; height: 64; radius: Appearance.rounding.normal
                    color: SchemePickerState.selectedScheme === index ? Appearance.colors.colLayer2 : (dh.containsMouse ? Appearance.colors.colLayer1Hover : "transparent")
                    border.color: SchemePickerState.selectedScheme === index ? Appearance.m3colors.m3primary : "transparent"
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 14; spacing: 12
                        Rectangle { width: 3; height: 24; radius: Appearance.rounding.full; color: SchemePickerState.selectedScheme === index ? Appearance.m3colors.m3primary : "transparent"; Behavior on color { ColorAnimation { duration: Appearance.animationCurves.expressiveEffectsDuration } } }
                        Text {
                            Layout.preferredWidth: 110
                            text: modelData.replace("scheme-", "")
                            color: SchemePickerState.selectedScheme === index ? Appearance.m3colors.m3onSurface : Appearance.m3colors.m3onSurfaceVariant
                            font.pixelSize: Appearance.font.pixelSize.smaller; font.family: Appearance.font.family.main
                            font.weight: SchemePickerState.selectedScheme === index ? Font.Medium : Font.Normal
                            Behavior on color { ColorAnimation { duration: Appearance.animationCurves.expressiveEffectsDuration } }
                        }
                        Row {
                            id: swatchRow; Layout.fillWidth: true; height: 32; spacing: 2
                            property string schemeName: modelData
                            property var swatches: { const _ = SchemePickerState.schemeColors; return SchemePickerState.schemeColors[schemeName] ?? {} }
                            Repeater {
                                model: SchemePickerState.colorKeys
                                delegate: Rectangle {
                                    required property string modelData
                                    required property int index
                                    property var swatches: SchemePickerState.schemeColors[modelData] ?? {}
                                    width: 14; height: 28; radius: Appearance.rounding.verysmall
                                    color: swatchRow.swatches[modelData] ?? "transparent"
                                    opacity: swatchRow.swatches[modelData] ? 1.0 : 0.1
                                    Behavior on color { ColorAnimation { duration: Appearance.animationCurves.expressiveEffectsDuration } }
                                }
                            }
                        }
                    }
                    HoverHandler { id: dh }
                    TapHandler { onTapped: SchemePickerState.selectedScheme = index }
                    Behavior on color { ColorAnimation { duration: Appearance.animationCurves.expressiveEffectsDuration } }
                    Behavior on border.color { ColorAnimation { duration: Appearance.animationCurves.expressiveEffectsDuration } }
                }
            }

            // ── Wallust preview ───────────────────────────────────────────
            ListView {
                id: wallustList
                Layout.fillWidth: true
                Layout.fillHeight: SchemePickerState.generatorMode === 1
                Layout.preferredHeight: SchemePickerState.generatorMode === 1 ? -1 : 0
                Layout.topMargin: 4
                clip: true; spacing: 2
                visible: SchemePickerState.generatorMode === 1
                model: SchemePickerState.wallustRows
                ScrollBar.vertical: StyledScrollBar {}

                delegate: Rectangle {
                    required property var modelData
                    required property int index
                    width: wallustList.width; height: 64; radius: Appearance.rounding.normal
                    color: Appearance.colors.colLayer1
                    border.color: Appearance.colors.colOutlineVariant
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 14; spacing: 12
                        Text {
                            Layout.preferredWidth: 64
                            text: modelData.label
                            color: Appearance.m3colors.m3onSurfaceVariant
                            font.pixelSize: Appearance.font.pixelSize.smaller
                            font.family: Appearance.font.family.main
                            font.weight: Font.Medium
                        }
                        Row {
                            Layout.fillWidth: true; height: 32; spacing: 3
                            Repeater {
                                model: modelData.colors
                                delegate: Rectangle {
                                    required property var modelData
                                    width: 32; height: 28; radius: Appearance.rounding.verysmall
                                    color: modelData.hex
                                    border.color: Qt.rgba(1,1,1,0.08); border.width: 1
                                    Text {
                                        anchors.bottom: parent.bottom
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        anchors.bottomMargin: 3
                                        text: modelData.name
                                        color: Qt.rgba(1,1,1,0.75); font.pixelSize: 8
                                        font.family: Appearance.font.family.monospace
                                        style: Text.Outline; styleColor: Qt.rgba(0,0,0,0.85)
                                    }
                                    Behavior on color { ColorAnimation { duration: Appearance.animationCurves.expressiveEffectsDuration } }
                                }
                            }
                        }
                    }
                }

                // Empty state
                Text {
                    anchors.centerIn: parent
                    visible: wallustList.count === 0 && !SchemePickerState.loading
                    text: "Adjust parameters and hit Reload"
                    color: Appearance.m3colors.m3outline
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    font.family: Appearance.font.family.main
                }
            }

            // ── Footer ───────────────────────────────────────────────────
            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: SchemePickerState.statusMessage
                    color: SchemePickerState.applied ? Appearance.m3colors.m3success : Appearance.m3colors.m3outline
                    font.pixelSize: Appearance.font.pixelSize.smaller; font.family: Appearance.font.family.main
                    Behavior on color { ColorAnimation { duration: Appearance.animationCurves.expressiveEffectsDuration } }
                }
                Item { Layout.fillWidth: true }
                Rectangle {
                    height: 36; radius: Appearance.rounding.full
                    implicitWidth: applyRow.implicitWidth + 32
                    color: SchemePickerState.applying ? Appearance.colors.colPrimaryContainerHover : (ah.containsMouse ? Appearance.colors.colPrimaryHover : Appearance.m3colors.m3primary)
                    opacity: (SchemePickerState.loading || SchemePickerState.applying) ? 0.6 : 1.0
                    RowLayout { id: applyRow; anchors.centerIn: parent; spacing: 6
                        MaterialSymbol { text: SchemePickerState.applying ? "hourglass_empty" : "check"; iconSize: 16; color: Appearance.m3colors.m3onPrimary }
                        Text { text: SchemePickerState.applying ? "Applying…" : "Apply Scheme"; color: Appearance.m3colors.m3onPrimary; font.pixelSize: Appearance.font.pixelSize.smaller; font.weight: Font.Medium; font.family: Appearance.font.family.main }
                    }
                    HoverHandler { id: ah }
                    TapHandler { onTapped: if (!SchemePickerState.loading && !SchemePickerState.applying) SchemePickerState.applyScheme() }
                    Behavior on color { ColorAnimation { duration: Appearance.animationCurves.expressiveEffectsDuration } }
                    Behavior on opacity { NumberAnimation { duration: Appearance.animationCurves.expressiveEffectsDuration } }
                }
            }
        }
    }
}
