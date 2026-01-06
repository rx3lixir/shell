import QtQuick
import QtQuick.Layouts
import "../theme"
import "../components"

Rectangle {
  id: root
  
  required property var item
  property bool isSelected: false
  property bool pressedByEnter: false  // New property for Enter key animation
  signal clicked()
  signal activated()
  
  radius: Theme.radius.xl
  color: {
    // Only show hover, selection is handled by the sliding highlight in the parent
    if (mouseArea.containsMouse && !isSelected) return Theme.surface_container_high
    return "transparent"
  }
  
  scale: (mouseArea.pressed || pressedByEnter) ? 0.97 : 1.0
  
  Behavior on color {
    ColorAnimation {
      duration: 200
      easing.type: Easing.OutCubic
    }
  }
  
  Behavior on scale {
    NumberAnimation {
      duration: 100
      easing.type: Easing.OutCubic
    }
  }
  
  // Function to trigger Enter press animation
  function triggerPressAnimation() {
    pressedByEnter = true
    pressResetTimer.start()
  }
  
  Timer {
    id: pressResetTimer
    interval: 100
    onTriggered: {
      root.pressedByEnter = false
    }
  }
  
  RowLayout {
    anchors {
      fill: parent
      margins: Theme.padding.md
    }
    spacing: Theme.spacing.md
    
    // Icon using IconCircle component
    IconCircle {
      Layout.preferredWidth: 48
      Layout.preferredHeight: 48
      Layout.alignment: Qt.AlignVCenter
      
      icon: root.item.icon
      iconSize: Theme.typography.xxl
      
      bgColor: isSelected ? Theme.primary : Theme.primary_container
      iconColor: isSelected ? Theme.on_primary : Theme.primary
      
      Behavior on bgColor {
        ColorAnimation {
          duration: 200
          easing.type: Easing.OutCubic
        }
      }
      
      Behavior on iconColor {
        ColorAnimation {
          duration: 200
          easing.type: Easing.OutCubic
        }
      }
    }
    
    // Text info
    ColumnLayout {
      Layout.fillWidth: true
      Layout.alignment: Qt.AlignVCenter
      spacing: 2
      
      Text {
        Layout.fillWidth: true
        text: root.item.name
        color: isSelected ? Theme.on_primary_container : Theme.on_surface
        font.pixelSize: Theme.typography.md
        font.family: Theme.typography.fontFamily
        font.weight: Theme.typography.weightMedium
        elide: Text.ElideRight
        
        Behavior on color {
          ColorAnimation {
            duration: 200
            easing.type: Easing.OutCubic
          }
        }
      }
      
      Text {
        Layout.fillWidth: true
        text: root.item.description
        color: isSelected ? Theme.on_primary_container : Theme.on_surface_variant
        font.pixelSize: Theme.typography.sm
        font.family: Theme.typography.fontFamily
        opacity: isSelected ? 0.9 : 0.7
        elide: Text.ElideRight
        
        Behavior on color {
          ColorAnimation {
            duration: 200
            easing.type: Easing.OutCubic
          }
        }
        
        Behavior on opacity {
          NumberAnimation {
            duration: 200
            easing.type: Easing.OutCubic
          }
        }
      }
    }
  }
  
  MouseArea {
    id: mouseArea
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    
    onClicked: {
      root.clicked()
      root.activated()
    }
  }
}
