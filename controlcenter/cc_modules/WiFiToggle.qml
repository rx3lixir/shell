import QtQuick
import "../../components"

IconButton {
  required property var networkManager
  
  icon: networkManager.wifiEnabled ? "󰤥" : "󰤭"
  title: "WI-FI"
  subtitle: networkManager.wifiEnabled ? "Connected" : "Disconnected"
  
  isStateful: true
  isActive: networkManager.wifiEnabled
  
  onClicked: networkManager.toggleWifi()
}
