import QtQuick
import QtQuick.Layouts
import "../../theme"

Rectangle {
  id: root
  
  required property var manager
  
  radius: Theme.radiusXLarge
  color: mouseArea.containsMouse ? Theme.bg2 : Theme.bg2transparent
  border.color: manager.wifiEnabled ? Theme.accent : "transparent"
  border.width: 0
  
  Component.onCompleted: {
    console.log("WiFiToggle module loaded")
  }
  
  RowLayout {
    anchors {
      fill: parent
      margins: Theme.spacingM
    }
    spacing: Theme.spacingS  // Changed from spacingM to spacingS for consistency
    
    Text {
      text: manager.wifiEnabled ? "󰤨" : "󰤭"
      color: manager.wifiEnabled ? Theme.accent : Theme.fg
      font.pixelSize: Theme.fontSizeXL
      font.family: Theme.fontFamily
    }
    
    ColumnLayout {
      Layout.fillWidth: true
      spacing: 2
      
      Text {
        text: "WiFi"  // Changed from "WIFI" to "WiFi" for consistency
        color: Theme.fg
        font.pixelSize: Theme.fontSizeM
        font.family: Theme.fontFamily
      }
      
      Text {
        text: manager.wifiEnabled ? "On" : "Off"
        color: manager.wifiEnabled ? Theme.accent : Theme.fgMuted
        font.pixelSize: Theme.fontSizeS
        font.family: Theme.fontFamily
      }
    }
  }
  
  MouseArea {
    id: mouseArea
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    
    onClicked: {
      console.log("WiFi tile clicked")
      manager.toggleWifi()
    }
  }
}
