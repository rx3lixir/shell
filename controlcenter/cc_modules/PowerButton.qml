import QtQuick
import "../../components"

ToggleCard {
  required property var powerMenuManager
  
  icon: "󰐥"
  title: "Power"
  subtitle: "Controls"
  isActive: false  // Power button is never "active"
  
  onClicked: powerMenuManager.visible = true
}
