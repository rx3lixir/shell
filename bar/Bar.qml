import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import "bar-modules" as Modules

PanelWindow {
  Theme { id: theme }
  
  anchors.top: true
  anchors.left: true
  anchors.right: true
  implicitHeight: theme.barHeight
  color: theme.bg0

  Rectangle {
    anchors.fill: parent
    color: theme.bg1
    border.color: theme.borderDim
    border.width: 1
    radius: 0
    
    RowLayout {
      anchors.fill: parent
      anchors.margins: theme.marginXS
      spacing: theme.spacingL

      // Left Side
      Modules.Workspaces {
        theme: theme
        Layout.leftMargin: theme.marginS
      }

      Modules.Keyboard {
        Layout.leftMargin: theme.spacingM
      }

      // Center - Spacer
      Item {
        Layout.fillWidth: true
      }

      // Right Side
      Modules.Audio {
        Layout.rightMargin: theme.spacingM
      }

      Modules.Battery {
        Layout.rightMargin: theme.spacingM
      }

      Modules.Network {
        Layout.rightMargin: theme.spacingM
      }

      Modules.Clock {
        Layout.rightMargin: theme.marginS
      }
    }
  }
}
