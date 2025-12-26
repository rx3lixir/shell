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
      
      // Use Layout properties so the layout system handles spacing properly
      Layout.preferredWidth: {
        const focused = Hyprland.focusedWorkspace?.id === (index + 1)
        return focused ? theme.workspaceIndicatorSize * 2 : theme.workspaceIndicatorSize
      }
      Layout.preferredHeight: theme.workspaceIndicatorSize
      
      radius: height / 2
      
      color: {
        const ws = Hyprland.workspaces.values.find(w => w.id === index + 1)
        const focused = Hyprland.focusedWorkspace?.id === (index + 1)

        // Focused
        if (focused) return theme.accent

        // Occupied
        if (ws) return theme.border

        // Empty
        return ws ? theme.border : Qt.darker(theme.border, 1.55)
      }

      // Smooth width transition
      Behavior on Layout.preferredWidth {
        NumberAnimation {
          duration: 250
          easing.type: Easing.OutCubic
        }
      }
      
      // Smooth color transition
      Behavior on color {
        ColorAnimation {
          duration: 250
          easing.type: Easing.OutCubic
        }
      }

      MouseArea {
        anchors.fill: parent
        onClicked: Hyprland.dispatch("workspace", index + 1)
      }
    }
  }
}
