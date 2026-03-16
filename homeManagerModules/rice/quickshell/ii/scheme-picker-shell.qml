//@ pragma UseQApplication
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic

import qs.modules.common
import qs.modules.common.widgets
import qs.services
import "schemePicker"
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

ShellRoot {
    id: root

    property bool open: true
    onOpenChanged: if (open) SchemePickerState.detectCurrentScheme()

    SchemePicker {
        visible: root.open
        onRequestClose: Qt.quit()
    }

    IpcHandler {
        target: "schemePicker"
        function toggle(): void { root.open = !root.open }
        function open(): void   { root.open = true }
        function close(): void  { root.open = false }
    }

    GlobalShortcut {
        name: "schemePickerToggle"
        description: "Toggle color scheme picker"
        onPressed: root.open = !root.open
    }
}
