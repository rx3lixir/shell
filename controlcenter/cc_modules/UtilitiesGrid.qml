// controlcenter/cc_modules/UtilitiesGrid.qml
import QtQuick
import QtQuick.Layouts
import "../../components"

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
    spacing: 20
    
    Repeater {
      model: root.buttons
      
      RoundIconButton {
        icon: modelData.icon
        size: 56  // Slightly bigger for utility buttons
        onClicked: modelData.action()
      }
    }
  }
}
