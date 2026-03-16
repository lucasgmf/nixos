//@ pragma UseQApplication
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic

import "scheme-picker"
import qs.modules.common
import qs.modules.common.widgets
import qs.services
import QtQuick
import Quickshell

ShellRoot {
    SchemePicker {}
}
