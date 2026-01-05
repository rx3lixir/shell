import QtQuick
import "../../theme"

Rectangle {
  id: root
  
  required property var calendarManager
  
  radius: Theme.radius.full
  color: mouseArea.containsMouse ? Theme.primary : Theme.primary_container
  border.width: 1
  border.color: mouseArea.containsMouse ? Theme.primary : Theme.outline_variant
  
  scale: mouseArea.pressed ? 0.95 : 1.0
  
  Behavior on color {
    ColorAnimation {
      duration: 150
      easing.type: Easing.OutCubic
    }
  }
  
  Behavior on border.color {
    ColorAnimation {
      duration: 150
      easing.type: Easing.OutCubic
    }
  }
  
  Behavior on scale {
    NumberAnimation {
      duration: 100
      easing.type: Easing.OutCubic
    }
  }
  
  Text {
    anchors.centerIn: parent
    text: "Go to Today"
    color: mouseArea.containsMouse ? Theme.on_primary : Theme.on_primary_container
    font.pixelSize: Theme.typography.md
    font.family: Theme.typography.fontFamily
    font.weight: Theme.typography.weightMedium
    
    Behavior on color {
      ColorAnimation {
        duration: 150
        easing.type: Easing.OutCubic
      }
    }
  }
  
  MouseArea {
    id: mouseArea
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    
    onClicked: {
      root.calendarManager.goToToday()
    }
  }
}
