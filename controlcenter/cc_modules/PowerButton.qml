import QtQuick
import "../../components"

IconButton {
  required property var powerMenuManager
  
  icon: "󰐥"
  title: "Power"
  subtitle: "Controls"

  isStateful: false
  
  onClicked: powerMenuManager.visible = true
}
