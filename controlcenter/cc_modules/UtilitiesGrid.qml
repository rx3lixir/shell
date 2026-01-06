import QtQuick
import QtQuick.Layouts
import "../../components"
import "../../theme"

Item {
  id: root
  
  required property var utilitiesManager
  
  readonly property var buttons: [
    {
      icon: "󰈊",
      action: () => utilitiesManager.launchColorPicker()
    },
    {
      icon: "󱣴",
      action: () => utilitiesManager.takeScreenshot()
    },
    {
      icon: utilitiesManager.nightLightActive ? "󱩌" : "󰹏",
      action: () => utilitiesManager.toggleNightLight()
    },
    {
      icon: "󰅍",
      action: () => utilitiesManager.openClipboard()
    }
  ]
  
  Row {
    anchors.centerIn: parent
    spacing: Theme.spacing.xl
    
    Repeater {
      model: root.buttons
      
      RoundIconButton {
        icon: modelData.icon
        size: 56
        onClicked: modelData.action()
      }
    }
  }
}
