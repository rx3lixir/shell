import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland

RowLayout {
  required property QtObject theme
  
  spacing: theme.spacingS

  Repeater {
    model: 5

    Rectangle {
      required property int index
      width: theme.workspaceIndicatorSize
      height: theme.workspaceIndicatorSize
      radius: theme.radiusSmall
      
      color: {
        const ws = Hyprland.workspaces.values.find(w => w.id === index + 1)
        const focused = Hyprland.focusedWorkspace?.id === (index + 1)
        if (focused) return theme.accent
        if (ws && ws.windows > 0) return theme.secondary
        if (ws) return theme.bg2
        return theme.bgDim
      }
      
      border.color: {
        const focused = Hyprland.focusedWorkspace?.id === (index + 1)
        return focused ? theme.borderStrong : theme.borderDim
      }
      border.width: 1

      Text {
        anchors.centerIn: parent
        text: ""
        color: theme.fg
        font {
          pixelSize: theme.fontSizeS
          bold: true
          family: theme.fontFamily
        }
      }

      MouseArea {
        anchors.fill: parent
        onClicked: Hyprland.dispatch("workspace", index + 1)
      }
    }
  }
}
