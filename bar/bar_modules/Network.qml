import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../theme"

Item {
  id: root

  // Reference to system state
  required property var systemState

  property string ifname: "—"
  property string icon: "󰖪"
  property bool hovered: false

  // Width expands when hovered to show the text
  implicitWidth: hovered ? rowLayout.implicitWidth : label.implicitWidth
  implicitHeight: Theme.barHeight
  
  // Smooth width transition
  Behavior on implicitWidth {
    NumberAnimation {
      duration: 250
      easing.type: Easing.OutCubic
    }
  }

  RowLayout {
    id: rowLayout
    anchors.centerIn: parent
    spacing: Theme.spacingS
    
    // Icon (always visible)
    Text {
      id: label
      text: icon
      color: Theme.fg
      font.pixelSize: Theme.fontSizeS
      font.family: Theme.fontFamily
      verticalAlignment: Text.AlignVCenter
    }
    
    // Interface name (only visible on hover)
    Text {
      id: ifnameText
      text: ifname
      color: Theme.fgMuted
      font.pixelSize: Theme.fontSizeS
      font.family: Theme.fontFamily
      verticalAlignment: Text.AlignVCenter
      visible: hovered && ifname !== "—"
      opacity: hovered ? 1.0 : 0.0
      
      Behavior on opacity {
        NumberAnimation {
          duration: 250 
          easing.type: Easing.OutCubic
        }
      }
    }
  }

  // MouseArea to detect hover
  MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    
    onEntered: root.hovered = true
    onExited: root.hovered = false

    cursorShape: Qt.PointingHandCursor

    onClicked: {
      root.systemState.network.openNetworkManager()
    }
  }

  // ============================================================================
  // NETWORK STATE MONITORING (using SystemStateManager)
  // ============================================================================
  
  Component.onCompleted: {
    console.log("[Bar.Network] Initial state - wifiEnabled:", systemState.network.wifiEnabled,
                "wifiConnected:", systemState.network.wifiConnected,
                "connectionType:", systemState.network.connectionType,
                "SSID:", systemState.network.wifiSsid)
    updateNetworkDisplay()
  }
  
  Connections {
    target: root.systemState.network
    enabled: root.systemState && root.systemState.network
    
    function onInterfaceNameChanged() {
      console.log("[Bar.Network] Interface name changed to:", root.systemState.network.interfaceName)
      updateNetworkDisplay()
    }
    
    function onWifiEnabledChanged() {
      console.log("[Bar.Network] WiFi enabled changed to:", root.systemState.network.wifiEnabled)
      updateNetworkDisplay()
    }
    
    function onWifiConnectedChanged() {
      console.log("[Bar.Network] WiFi connected changed to:", root.systemState.network.wifiConnected)
      updateNetworkDisplay()
    }
    
    function onConnectionTypeChanged() {
      console.log("[Bar.Network] Connection type changed to:", root.systemState.network.connectionType)
      updateNetworkDisplay()
    }
    
    function onWifiSsidChanged() {
      console.log("[Bar.Network] WiFi SSID changed to:", root.systemState.network.wifiSsid)
      updateNetworkDisplay()
    }
    
    function onReadyChanged() {
      console.log("[Bar.Network] Ready state changed to:", root.systemState.network.ready)
      updateNetworkDisplay()
    }
  }
  
  // Update network display
  function updateNetworkDisplay() {
    var network = root.systemState.network
    
    if (!network || !network.ready) {
      console.log("[Bar.Network] Network not ready yet")
      root.icon = "󰖪"
      root.ifname = "—"
      return
    }
    
    console.log("[Bar.Network] Updating display - type:", network.connectionType,
                "wifiConnected:", network.wifiConnected,
                "wifiEnabled:", network.wifiEnabled,
                "SSID:", network.wifiSsid)
    
    // Get icon from network module
    root.icon = network.getNetworkIcon()
    console.log("[Bar.Network] Icon set to:", root.icon)
    
    // Get interface name or status
    if (network.connectionType === "wifi" && network.wifiConnected) {
      root.ifname = network.wifiSsid || network.interfaceName
      console.log("[Bar.Network] WiFi name set to:", root.ifname)
    } else if (network.connectionType === "ethernet") {
      root.ifname = "Ethernet"
      console.log("[Bar.Network] Ethernet connection")
    } else if (!network.wifiEnabled) {
      root.ifname = "Disabled"
      console.log("[Bar.Network] WiFi disabled")
    } else {
      root.ifname = "Disconnected"
      console.log("[Bar.Network] Disconnected")
    }
  }
}
