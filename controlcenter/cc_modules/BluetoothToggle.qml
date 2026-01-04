import QtQuick
import QtQuick.Layouts
import "../../theme"

Rectangle {
  id: root
  
  required property var networkManager
  
  radius: 32
  color: mouseArea.containsMouse ? Qt.darker(Theme.bg2, 1.1) : Theme.bg2
  Behavior on color {
    ColorAnimation { duration: 200 }
  }

  border.width: 1
  border.color: Theme.borderDim

  // Shadow layer 1 (closest)
  Rectangle {
    anchors.fill: parent
    anchors.margins: -2
    radius: parent.radius + 2
    color: "transparent"
    border.width: 2
    border.color: "#20000000"
    z: -1
    opacity: mouseArea.containsMouse ? 1 : 0.6
    
    Behavior on opacity {
      NumberAnimation { duration: 200 }
    }
  }
  
  // Shadow layer 2 (outer)
  Rectangle {
    anchors.fill: parent
    anchors.margins: -4
    radius: parent.radius + 4
    color: "transparent"
    border.width: 2
    border.color: "#15000000"
    z: -2
    opacity: mouseArea.containsMouse ? 0.8 : 0.4
    
    Behavior on opacity {
      NumberAnimation { duration: 200 }
    }
  }

  
  RowLayout {
    anchors {
      fill: parent
      topMargin: 10
      bottomMargin: 10 
      leftMargin: 16
      rightMargin: 16 
    }

    spacing: 10

    // Icon with container
    Rectangle {
      Layout.preferredWidth: 40
      Layout.preferredHeight: 40

      Layout.alignment: Qt.AlignVCenter
      radius: 20

      scale: mouseArea.pressed ? 0.9 : 1.0

      color: networkManager.bluetoothEnabled ? Qt.darker(Theme.accent, 1.6) : Qt.lighter(Theme.bg2, 1.3)
      Behavior on color {
        ColorAnimation { duration: 200 }
      }
      
      Text {
        anchors.centerIn: parent
        text: networkManager.bluetoothEnabled ? "󰂯" : "󰂲"

        font.pixelSize: 20
        font.family: Theme.fontFamily

        color: networkManager.bluetoothEnabled ? Theme.accent : Theme.fgMuted
        Behavior on color {
          ColorAnimation { duration: 200 }
        }
      }
    }
    
    ColumnLayout {
      Layout.fillWidth: true
      Layout.alignment: Qt.AlignVCenter
      spacing: 2
      
      Text {
        text: "Bluetooth"
        color: Theme.fg
        opacity: networkManager.bluetoothEnabled ? 1 : 0.8
        font.pixelSize: Theme.fontSizeM
        font.family: Theme.fontFamily
        Behavior on color {
          ColorAnimation { duration: 200 }
        }
      }
      
      Text {
        text: networkManager.bluetoothEnabled ? "On" : "Off"
        color: networkManager.bluetoothEnabled ? Theme.accent : Theme.fgMuted
        font.pixelSize: 12
        font.family: Theme.fontFamily
        opacity: 0.8
      }
    }
  }
  
  MouseArea {
    id: mouseArea
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    
    onClicked: {
      networkManager.toggleBluetooth()
    }
  }
}
