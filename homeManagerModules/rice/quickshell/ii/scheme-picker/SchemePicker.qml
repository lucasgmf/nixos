pragma ComponentBehavior: Bound

import "../modules/common"
import "../modules/common/widgets"

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: win

    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    WlrLayershell.namespace: "quickshell:schemePicker"
    color: "transparent"

    implicitWidth: panel.implicitWidth
    implicitHeight: panel.implicitHeight

    mask: Region { item: panel }

    StyledRectangularShadow { target: panel }

    Rectangle {
        id: panel
        anchors.centerIn: parent
        implicitWidth: 820
        implicitHeight: 660
        radius: Appearance.rounding.screenRounding
        color: Appearance.colors.colLayer0
        border.color: Appearance.colors.colLayer0Border
        border.width: 1
        clip: true

        focus: true
        Keys.onPressed: function(event) {
            if (event.key === Qt.Key_Escape) {
                Qt.quit(); event.accepted = true
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
                    text: "palette"
                    iconSize: 24
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

                // Close
                Rectangle {
                    width: 32; height: 32
                    radius: Appearance.rounding.full
                    color: closeHov.containsMouse ? Appearance.colors.colLayer2Hover : "transparent"
                    MaterialSymbol {
                        anchors.centerIn: parent
                        text: "close"; iconSize: 18
                        color: Appearance.m3colors.m3outline
                    }
                    HoverHandler { id: closeHov }
                    TapHandler { onTapped: Qt.quit() }
                    Behavior on color { ColorAnimation { duration: Appearance.animationCurves.expressiveEffectsDuration } }
                }
            }

            // ── Divider ──────────────────────────────────────────────────
            Rectangle {
                Layout.fillWidth: true; height: 1
                color: Appearance.colors.colOutlineVariant
                Layout.topMargin: 14; Layout.bottomMargin: 14
            }

            // ── Controls ─────────────────────────────────────────────────
            RowLayout {
                Layout.fillWidth: true
                spacing: 20

                // Mode buttons
                Column {
                    spacing: 6
                    Text {
                        text: "MODE"
                        color: Appearance.m3colors.m3outline
                        font.pixelSize: Appearance.font.pixelSize.smallest
                        font.letterSpacing: 1.5
                        font.family: Appearance.font.family.main
                        font.weight: Font.Medium
                    }
                    Row {
                        spacing: 4
                        Repeater {
                            model: SchemePickerState.modes
                            delegate: Rectangle {
                                required property string modelData
                                required property int index
                                width: 64; height: 30
                                radius: Appearance.rounding.full
                                color: SchemePickerState.selectedMode === index
                                    ? Appearance.m3colors.m3primaryContainer
                                    : (mh.containsMouse ? Appearance.colors.colLayer2Hover : Appearance.colors.colLayer1)
                                border.color: SchemePickerState.selectedMode === index
                                    ? Appearance.m3colors.m3primary
                                    : Appearance.colors.colOutlineVariant
                                border.width: 1
                                Text {
                                    anchors.centerIn: parent
                                    text: parent.modelData
                                    color: SchemePickerState.selectedMode === parent.index
                                        ? Appearance.m3colors.m3onPrimaryContainer
                                        : Appearance.m3colors.m3onSurfaceVariant
                                    font.pixelSize: Appearance.font.pixelSize.smaller
                                    font.family: Appearance.font.family.main
                                    font.weight: SchemePickerState.selectedMode === parent.index
                                        ? Font.Medium : Font.Normal
                                }
                                HoverHandler { id: mh }
                                TapHandler { onTapped: SchemePickerState.selectedMode = index }
                                Behavior on color { ColorAnimation { duration: Appearance.animationCurves.expressiveEffectsDuration } }
                            }
                        }
                    }
                }

                // Contrast slider
                Column {
                    spacing: 6
                    Layout.fillWidth: true
                    RowLayout {
                        width: parent.width
                        Text {
                            text: "CONTRAST"
                            color: Appearance.m3colors.m3outline
                            font.pixelSize: Appearance.font.pixelSize.smallest
                            font.letterSpacing: 1.5
                            font.family: Appearance.font.family.main
                            font.weight: Font.Medium
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: SchemePickerState.contrast.toFixed(1)
                            color: SchemePickerState.contrast === 0
                                ? Appearance.m3colors.m3outline
                                : Appearance.m3colors.m3primary
                            font.pixelSize: Appearance.font.pixelSize.smaller
                            font.family: Appearance.font.family.numbers
                            font.weight: Font.Medium
                        }
                    }
                    StyledSlider {
                        width: parent.width
                        from: -1.0; to: 1.0; stepSize: 0.1
                        value: SchemePickerState.contrast
                        onMoved: SchemePickerState.contrast = value
                    }
                }

                // Reload button
                Rectangle {
                    width: 88; height: 56
                    radius: Appearance.rounding.normal
                    color: rh.containsMouse ? Appearance.colors.colLayer2Hover : Appearance.colors.colLayer1
                    border.color: Appearance.colors.colOutlineVariant
                    border.width: 1
                    opacity: SchemePickerState.loading ? 0.5 : 1.0
                    Column {
                        anchors.centerIn: parent; spacing: 3
                        MaterialSymbol {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "refresh"; iconSize: 20
                            color: Appearance.m3colors.m3primary
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "Reload"
                            color: Appearance.m3colors.m3onSurfaceVariant
                            font.pixelSize: Appearance.font.pixelSize.smallest
                            font.family: Appearance.font.family.main
                        }
                    }
                    HoverHandler { id: rh }
                    TapHandler { onTapped: if (!SchemePickerState.loading) SchemePickerState.loadAllSchemes() }
                    Behavior on color { ColorAnimation { duration: Appearance.animationCurves.expressiveEffectsDuration } }
                    Behavior on opacity { NumberAnimation { duration: Appearance.animationCurves.expressiveEffectsDuration } }
                }
            }

            // ── Divider ──────────────────────────────────────────────────
            Rectangle {
                Layout.fillWidth: true; height: 1
                color: Appearance.colors.colOutlineVariant
                Layout.topMargin: 14; Layout.bottomMargin: 8
            }

            // ── Progress bar ─────────────────────────────────────────────
            RowLayout {
                Layout.fillWidth: true
                visible: SchemePickerState.loading
                spacing: 10
                StyledProgressBar {
                    Layout.fillWidth: true
                    value: SchemePickerState.schemes.length > 0
                        ? SchemePickerState.loadProgress / SchemePickerState.schemes.length : 0
                }
                Text {
                    text: SchemePickerState.statusMessage
                    color: Appearance.m3colors.m3outline
                    font.pixelSize: Appearance.font.pixelSize.smallest
                    font.family: Appearance.font.family.main
                }
            }

            // ── Scheme list ───────────────────────────────────────────────
            ListView {
                id: schemeList
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.topMargin: 4
                clip: true; spacing: 2
                model: SchemePickerState.schemes

                ScrollBar.vertical: StyledScrollBar {}

                delegate: Rectangle {
                    required property string modelData
                    required property int index
                    width: schemeList.width; height: 64
                    radius: Appearance.rounding.normal
                    color: SchemePickerState.selectedScheme === index
                        ? Appearance.colors.colLayer2
                        : (dh.containsMouse ? Appearance.colors.colLayer1Hover : "transparent")
                    border.color: SchemePickerState.selectedScheme === index
                        ? Appearance.m3colors.m3primary : "transparent"
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 14; anchors.rightMargin: 14
                        spacing: 12

                        Rectangle {
                            width: 3; height: 24
                            radius: Appearance.rounding.full
                            color: SchemePickerState.selectedScheme === index
                                ? Appearance.m3colors.m3primary : "transparent"
                            Behavior on color { ColorAnimation { duration: Appearance.animationCurves.expressiveEffectsDuration } }
                        }

                        Text {
                            Layout.preferredWidth: 110
                            text: modelData.replace("scheme-", "")
                            color: SchemePickerState.selectedScheme === index
                                ? Appearance.m3colors.m3onSurface
                                : Appearance.m3colors.m3onSurfaceVariant
                            font.pixelSize: Appearance.font.pixelSize.smaller
                            font.family: Appearance.font.family.main
                            font.weight: SchemePickerState.selectedScheme === index
                                ? Font.Medium : Font.Normal
                            Behavior on color { ColorAnimation { duration: Appearance.animationCurves.expressiveEffectsDuration } }
                        }

                        SwatchRow {
                            Layout.fillWidth: true
                            height: 32
                            schemeName: modelData
                            swatches: SchemePickerState.schemeColors[modelData] ?? {}
                        }
                    }

                    HoverHandler { id: dh }
                    TapHandler { onTapped: SchemePickerState.selectedScheme = index }
                    Behavior on color { ColorAnimation { duration: Appearance.animationCurves.expressiveEffectsDuration } }
                    Behavior on border.color { ColorAnimation { duration: Appearance.animationCurves.expressiveEffectsDuration } }
                }
            }

            // ── Divider ──────────────────────────────────────────────────
            Rectangle {
                Layout.fillWidth: true; height: 1
                color: Appearance.colors.colOutlineVariant
                Layout.topMargin: 10; Layout.bottomMargin: 10
            }

            // ── Footer ───────────────────────────────────────────────────
            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: SchemePickerState.statusMessage
                    color: SchemePickerState.applied
                        ? Appearance.m3colors.m3success
                        : Appearance.m3colors.m3outline
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    font.family: Appearance.font.family.main
                    visible: !SchemePickerState.loading
                    Behavior on color { ColorAnimation { duration: Appearance.animationCurves.expressiveEffectsDuration } }
                }

                Item { Layout.fillWidth: true }

                // Apply button
                Rectangle {
                    height: 36; radius: Appearance.rounding.full
                    implicitWidth: applyRow.implicitWidth + 32
                    color: SchemePickerState.applying
                        ? Appearance.colors.colPrimaryContainerHover
                        : (ah.containsMouse ? Appearance.colors.colPrimaryHover : Appearance.m3colors.m3primary)
                    opacity: (SchemePickerState.loading || SchemePickerState.applying) ? 0.6 : 1.0

                    RowLayout {
                        id: applyRow
                        anchors.centerIn: parent; spacing: 6
                        MaterialSymbol {
                            text: SchemePickerState.applying ? "hourglass_empty" : "check"
                            iconSize: 16
                            color: Appearance.m3colors.m3onPrimary
                        }
                        Text {
                            text: SchemePickerState.applying ? "Applying…" : "Apply Scheme"
                            color: Appearance.m3colors.m3onPrimary
                            font.pixelSize: Appearance.font.pixelSize.smaller
                            font.weight: Font.Medium
                            font.family: Appearance.font.family.main
                        }
                    }

                    HoverHandler { id: ah }
                    TapHandler {
                        onTapped: if (!SchemePickerState.loading && !SchemePickerState.applying)
                            SchemePickerState.applyScheme()
                    }
                    Behavior on color { ColorAnimation { duration: Appearance.animationCurves.expressiveEffectsDuration } }
                    Behavior on opacity { NumberAnimation { duration: Appearance.animationCurves.expressiveEffectsDuration } }
                }
            }
        }
    }
}
