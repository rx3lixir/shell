import QtQuick
import "../theme"

Rectangle {
  id: root
  
  // Public API
  required property string icon
  signal clicked()
  
  // Optional customization - set to true for the main play/pause button
  property bool isPrimary: false
  
  width: isPrimary ? 48 : 40
  height: isPrimary ? 48 : 40
  radius: isPrimary ? 24 : 20
  
  color: {
    if (isPrimary) {
      return mouseArea.containsMouse ? Theme.primary : Theme.primary_transparent
    } else {
      return mouseArea.containsMouse ? Theme.surface : "transparent"
    }
  }
  
  border.width: isPrimary ? 2 : 1
  border.color: {
    if (isPrimary) {
      return Theme.primary
    } else {
      return mouseArea.containsMouse ? Theme.outline_variant : "transparent"
    }
  }
  
  scale: mouseArea.pressed ? (isPrimary ? 0.92 : 0.9) : 1.0
  
  Behavior on color {
    ColorAnimation { duration: 150 }
  }
  
  Behavior on border.color {
    ColorAnimation { duration: 150 }
  }
  
  Behavior on scale {
    NumberAnimation { 
      duration: 100
      easing.type: Easing.OutCubic
    }
  }
  
  // Subtle shadow for primary button
  Rectangle {
    visible: root.isPrimary
    anchors.centerIn: parent
    width: parent.width + 4
    height: parent.height + 4
    radius: (parent.width + 4) / 2
    color: "transparent"
    border.width: 2
    border.color: Theme.scrim_transparent
    z: -1
    opacity: mouseArea.containsMouse ? 1 : 0.6
    
    Behavior on opacity {
      NumberAnimation { duration: 150 }
    }
  }
  
  Text {
    anchors.centerIn: parent
    text: root.icon
    color: Theme.on_surface
    font.pixelSize: root.isPrimary ? Theme.typography.xxl + 2 : Theme.typography.xl
    font.family: Theme.typography.fontFamily
  }
  
  MouseArea {
    id: mouseArea
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onClicked: root.clicked()
  }
}
