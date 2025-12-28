import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import "../../theme"

RowLayout {
  spacing: Theme.spacingS

  implicitHeight: Theme.barHeight

  Repeater {
    model: 5

    Rectangle {
      required property int index
      
      // Use Layout properties so the layout system handles spacing properly
      Layout.preferredWidth: {
        const focused = Hyprland.focusedWorkspace?.id === (index + 1)
        return focused ? Theme.workspaceIndicatorSize * 2 : Theme.workspaceIndicatorSize
      }
      Layout.preferredHeight: Theme.workspaceIndicatorSize

      anchors{
        verticalCenter: parent.verticalCenter
      }
      
      radius: height / 2
      
      color: {
        const ws = Hyprland.workspaces.values.find(w => w.id === index + 1)
        const focused = Hyprland.focusedWorkspace?.id === (index + 1)

        // Focused
        if (focused) return Theme.accent

        // Occupied
        if (ws) return Theme.border

        // Empty
        return ws ? Theme.border : Qt.darker(Theme.border, 1.55)
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
