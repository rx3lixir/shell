import QtQuick
import "../../components"

IconButton {
  required property var systemState
  
  icon: systemState.network.getNetworkIcon()
  title: "WI-FI"
  subtitle: systemState.network.getStatusText()
  
  isStateful: true
  isActive: systemState.network.wifiEnabled && systemState.network.wifiConnected
  
  onClicked: systemState.network.toggleWifi()
}
