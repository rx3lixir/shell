import QtQuick
import QtQuick.Layouts
import "../../theme"

Item {
  id: root
  
  required property var utilitiesManager
  
  // Button definitions
  readonly property var buttons: [
    {
      icon: "󰈊",
      action: () => utilitiesManager.launchColorPicker(),
      isActive: false
    },
    {
      icon: "󱣴",
      action: () => utilitiesManager.takeScreenshot(),
      isActive: false
    },
    {
      icon: utilitiesManager.nightLightActive ? "󱩌" : "󰹏",
      action: () => utilitiesManager.toggleNightLight(),
      isActive: utilitiesManager.nightLightActive
    },
    {
      icon: "󰅍",
      action: () => utilitiesManager.openClipboard(),
      isActive: false
    }
  ]
  
  Row {
    anchors.centerIn: parent
    spacing: 24
    
    Repeater {
      model: root.buttons
      
      Rectangle {
        width: 56
        height: 56
        radius: 28
        
        color: mouseArea.containsMouse ? Qt.darker(Theme.bg2, 1.1) : Theme.bg2
        Behavior on color {
          ColorAnimation { duration: 200 }
        }
        
        border.width: 1
        border.color: Theme.borderDim
        
        scale: mouseArea.pressed ? 0.8 : 1.0
        
        
        Behavior on scale {
          NumberAnimation { 
            duration: 100
            easing.type: Easing.OutCubic
          }
        }
        
        // Shadow layer
        Rectangle {
          anchors.fill: parent
          anchors.margins: -2
          radius: parent.radius + 2
          color: "transparent"
          border.width: 2
          border.color: "#10000000"
          z: -1
        }
        
        Text {
          anchors.centerIn: parent
          text: modelData.icon
          color: mouseArea.containsMouse ? Qt.darker(Theme.fg, 1.4): Theme.fg
          font.pixelSize: 24
          font.family: Theme.fontFamily
          
          Behavior on color {
            ColorAnimation { duration: 200 }
          }
        }
        
        MouseArea {
          id: mouseArea
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          
          onClicked: {
            modelData.action()
          }
        }
      }
    }
  }
}
