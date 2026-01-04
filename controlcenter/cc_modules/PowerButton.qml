import QtQuick
import QtQuick.Layouts
import "../../theme"

Rectangle {
  id: root
  
  required property var powerMenuManager
  
  radius: 32
  color: Theme.bg2
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
      margins: Theme.spacingM
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
      
      scale: mouseArea.pressed ? 0.85 : 1.0
      Behavior on scale {
        NumberAnimation { 
          duration: 150
          easing.type: Easing.OutBack
          easing.overshoot: 2
        }
      }

      color: Qt.darker(Theme.accent, 1.6)
      
      Text {
        anchors.centerIn: parent
        text: "󰐥"
        color: Theme.accent
        font.pixelSize: 20
        font.family: Theme.fontFamily
      }
    }
    
    ColumnLayout {
      Layout.fillWidth: true
      Layout.alignment: Qt.AlignVCenter
      spacing: 2
      
      Text {
        text: "Power"
        color: Theme.fg
        font.pixelSize: 14
        font.family: Theme.fontFamily
        font.weight: Font.Medium

        Behavior on color {
          ColorAnimation { duration: 200 }
        }
      }
      
      Text {
        text: "Controls"
        color: Theme.fgMuted
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
      powerMenuManager.visible = true
    }
  }
}
