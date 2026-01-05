import QtQuick
import "../../components"

ToggleCard {
  required property var networkManager
  
  icon: networkManager.wifiEnabled ? "󰤥" : "󰤭"
  title: "WI-FI"
  subtitle: networkManager.wifiEnabled ? "Connected" : "Disconnected"
  isActive: networkManager.wifiEnabled
  
  onClicked: networkManager.toggleWifi()
}
