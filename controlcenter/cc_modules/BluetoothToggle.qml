import QtQuick
import QtQuick.Layouts
import "../../theme"

Rectangle {
  id: root
  
  // Changed: now receives specific sub-manager
  required property var networkManager
  
  radius: Theme.radiusXLarge
  color: mouseArea.containsMouse ? Theme.bg2 : Theme.bg2transparent
  
  Component.onCompleted: {
    console.log("BluetoothToggle module loaded")
  }
  
  RowLayout {
    anchors {
      fill: parent
      margins: Theme.spacingM
    }
    spacing: Theme.spacingM
    
    Text {
      text: networkManager.bluetoothEnabled ? "󰂯" : "󰂲"
      color: networkManager.bluetoothEnabled ? Theme.accent : Theme.fg
      font.pixelSize: Theme.fontSizeXL
      font.family: Theme.fontFamily
    }
    
    ColumnLayout {
      Layout.fillWidth: true
      spacing: 2
      
      Text {
        text: "Bluetooth"
        color: Theme.fg
        font.pixelSize: Theme.fontSizeM
        font.family: Theme.fontFamily
      }
      
      Text {
        text: networkManager.bluetoothEnabled ? "On" : "Off"
        color: Theme.fgMuted
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
      console.log("Bluetooth tile clicked")
      networkManager.toggleBluetooth()
    }
  }
}
