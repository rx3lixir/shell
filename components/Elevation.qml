// components/Elevation.qml
import QtQuick

Item {
  id: root

  // Make the Elevation item automatically fill whatever parent it's in
  anchors.fill: parent

  property Item target: parent  // Still points to the visual item (card)
  property bool enabled: true

  // Shadow layers for depth
  Rectangle {
    visible: root.enabled
    anchors.fill: root.target 
    anchors.margins: -2
    radius: parent.radius + 2
    color: "transparent"
    border.width: 2
    border.color: Theme.scrim_transparent
    z: -1
    opacity: mouseArea.containsMouse ? 1 : 0.6
    
    Behavior on opacity {
      NumberAnimation { duration: 200 }
    }
  }

  Rectangle {
    visible: root.enabled
    anchors.fill: root.target 
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
}
