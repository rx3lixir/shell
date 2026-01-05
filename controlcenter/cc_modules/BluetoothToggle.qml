import QtQuick
import "../../components"

IconButton {
  required property var networkManager
  
  icon: networkManager.bluetoothEnabled ? "󰂯" : "󰂲"
  title: "Bluetooth"
  subtitle: networkManager.bluetoothEnabled ? "On" : "Off"
  
  isStateful: true  // This is a toggle button
  isActive: networkManager.bluetoothEnabled
  
  onClicked: networkManager.toggleBluetooth()
}
