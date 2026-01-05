import QtQuick
import "../../components"

ToggleCard {
  required property var networkManager
  
  icon: networkManager.bluetoothEnabled ? "󰂯" : "󰂲"
  title: "Bluetooth"
  subtitle: networkManager.bluetoothEnabled ? "On" : "Off"
  isActive: networkManager.bluetoothEnabled
  
  onClicked: networkManager.toggleBluetooth()
}
