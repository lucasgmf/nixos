pragma ComponentBehavior: Bound

import "../modules/common"
import QtQuick

Item {
    id: root
    property string schemeName: ""
    property var swatches: ({})

    implicitHeight: 32
    implicitWidth: swatchChips.implicitWidth

    Row {
        id: swatchChips
        anchors.verticalCenter: parent.verticalCenter
        spacing: 2

        Repeater {
            model: SchemePickerState.colorKeys
            delegate: Rectangle {
                required property string modelData
                width: 16; height: 28
                radius: Appearance.rounding.verysmall
                color: root.swatches[modelData] ?? "transparent"
                opacity: root.swatches[modelData] ? 1.0 : 0.1
                Behavior on color { ColorAnimation { duration: Appearance.animationCurves.expressiveEffectsDuration } }
            }
        }
    }
}
