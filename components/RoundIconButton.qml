import QtQuick
import "../theme"

Rectangle {
  id: root
  
  // Public API
  required property string icon
  signal clicked()
  
  // Optional customization
  property bool isActive: false
  property color activeColor: Theme.primary
  
  width: 56
  height: 56
  radius: Theme.radius.full
  
  color: mouseArea.containsMouse ? Qt.darker(Theme.surface_container_low, 1.1) : Theme.surface_container_low
  border.width: 1
  border.color: Theme.outline_variant
  
  scale: mouseArea.pressed ? 0.8 : 1.0
  
  Behavior on color {
    ColorAnimation { duration: 200 }
  }
  
  Behavior on scale {
    NumberAnimation { 
      duration: 100
      easing.type: Easing.OutCubic
    }
  }
  
  // Shadow layer
  Rectangle {
    anchors.fill: parent
    anchors.margins: -2
    radius: parent.radius + 2
    color: "transparent"
    border.width: 2
    border.color: "#10000000"
    z: -1
  }
  
  Text {
    anchors.centerIn: parent
    text: root.icon
    color: mouseArea.containsMouse ? Qt.darker(Theme.on_surface, 1.4) : Theme.on_surface
    font.pixelSize: Theme.typography.xxl
    font.family: Theme.typography.fontFamily
    
    Behavior on color {
      ColorAnimation { duration: 200 }
    }
  }
  
  MouseArea {
    id: mouseArea
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onClicked: root.clicked()
  }
}
