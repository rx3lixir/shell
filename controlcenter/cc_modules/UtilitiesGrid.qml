import QtQuick
import QtQuick.Layouts
import "../../components"

Item {
  id: root
  
  required property var utilitiesManager
  
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
      
      RoundIconButton {
        icon: modelData.icon
        isActive: modelData.isActive
        onClicked: modelData.action()
      }
    }
  }
}
