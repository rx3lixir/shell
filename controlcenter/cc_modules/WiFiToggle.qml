import QtQuick
import QtQuick.Layouts
import "../../theme"

Rectangle {
  id: root
  required property var networkManager

  radius: 32
  color: Theme.bg2

  Rectangle {
    anchors.fill: parent
    radius: parent.radius
    color: mouseArea.containsMouse ? Qt.darker(Theme.bg2, 1.1) : "transparent"
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

      // Simplified border handling (like Bluetooth)
      border.width: 0
      color: networkManager.wifiEnabled ? Qt.darker(Theme.accent, 1.6) : Qt.lighter(Theme.bg2, 1.3)

      Behavior on color {
        ColorAnimation { duration: 200 }
      }

      Text {
        anchors.centerIn: parent
        text: networkManager.wifiEnabled ? "󰤥" : "󰤭"
        font.pixelSize: 20
        font.family: Theme.fontFamily
        color: networkManager.wifiEnabled ? Theme.accent : Theme.fgMuted
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
        text: "WI-FI"
        color: Theme.fg
        opacity: networkManager.wifiEnabled ? 1 : 0.8
        font.pixelSize: Theme.fontSizeM
        font.family: Theme.fontFamily
        font.weight: Font.Medium

        Behavior on color {
          ColorAnimation { duration: 200 }
        }
      }

      Text {
        text: networkManager.wifiEnabled ? "Connected" : "Disconnected"
        color: networkManager.wifiEnabled ? Theme.accent : Theme.fgMuted
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
      networkManager.toggleWifi()
    }
  }
}
