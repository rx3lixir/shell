import QtQuick
import QtQuick.Layouts
import "../theme"
import "../components"

Rectangle {
  id: root
  
  required property var item
  property bool isSelected: false
  property bool pressedByEnter: false
  signal clicked()
  signal activated()
  
  radius: Theme.radius.xl
  color: "transparent"  // No hover colors
  
  // Simple press feedback only
  scale: (pressedByEnter || mouseArea.pressed) ? 0.98 : 1.0
  
  Behavior on scale {
    NumberAnimation {
      duration: 80
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
    id: contentLayout
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
      
      // Subtle color shift when selected, but no wild changes
      bgColor: isSelected ? Theme.primary : Theme.primary_container
      iconColor: isSelected ? Theme.on_primary : Theme.primary
      
      // Quick color transition
      Behavior on bgColor {
        ColorAnimation {
          duration: 180
          easing.type: Easing.OutCubic
        }
      }
      
      Behavior on iconColor {
        ColorAnimation {
          duration: 180
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
        // Keep text readable - only subtle changes
        color: isSelected ? Theme.on_surface : Theme.on_surface
        font.pixelSize: Theme.typography.md
        font.family: Theme.typography.fontFamily
        font.weight: isSelected ? Theme.typography.weightMedium : Theme.typography.weightMedium
        elide: Text.ElideRight
        
        // Slightly more visible when selected
        opacity: isSelected ? 1.0 : 0.95
        
        Behavior on opacity {
          NumberAnimation {
            duration: 180
            easing.type: Easing.OutCubic
          }
        }
      }
      
      Text {
        Layout.fillWidth: true
        text: root.item.description
        color: Theme.on_surface_variant
        font.pixelSize: Theme.typography.sm
        font.family: Theme.typography.fontFamily
        opacity: isSelected ? 0.85 : 0.7
        elide: Text.ElideRight
        
        Behavior on opacity {
          NumberAnimation {
            duration: 180
            easing.type: Easing.OutCubic
          }
        }
      }
    }
  }
  
  MouseArea {
    id: mouseArea
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    
    // Mouse only activates items, doesn't change selection
    onClicked: {
      root.activated()
    }
  }
}
