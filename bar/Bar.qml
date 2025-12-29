import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import "../theme"
import "bar_modules" as Modules

PanelWindow {
  id: barWindow
  
  // Accept the wlogout window from shell.qml
  required property var controlCenterManager 
  
  // Accept the notification manager from shell.qml
  required property var notificationCenterManager

  
  anchors.top: true
  anchors.left: true
  anchors.right: true
  implicitHeight: Theme.barHeight
  color: "transparent"

  Rectangle {
    anchors.fill: parent
    color: Theme.bg1transparent
    radius: 0
    
    RowLayout {
      anchors.fill: parent
      
      // Margins from right and left of the first modules
      anchors.leftMargin: Theme.spacingM
      anchors.rightMargin: Theme.spacingM

      // Left Section - Workspaces
      RowLayout {
        Layout.alignment: Qt.AlignLeft
        spacing: Theme.spacingL
        
        Modules.ControlCenterButton{
          controlCenterManager: barWindow.controlCenterManager
        }
        
        Modules.Workspaces {}

        Modules.Keyboard {}
      }

      // Center Spacer
      Item {
        Layout.fillWidth: true
      }

      // Right Section - System Info
      RowLayout {
        Layout.alignment: Qt.AlignRight
        spacing: Theme.spacingL

        Modules.Battery {}

        Modules.Bluetooth{}

        Modules.Audio {}

        Modules.Network {}
        
        // Add the control center button here
        Modules.NotificationCenterButton {  // Changed name
          notificationCenterManager: barWindow.notificationCenterManager
        }
        
        Modules.Clock {}
      }
    }
  }
}
