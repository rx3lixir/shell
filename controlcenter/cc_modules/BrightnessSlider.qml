import QtQuick
import QtQuick.Layouts
import "../../theme"

Rectangle {
  id: root
  
  required property var brightnessManager
  
  radius: 26
  color: Theme.bg2transparent
  border.width: 2
  border.color: Theme.borderDim
  
  // Compact padding - matching volume slider
  ColumnLayout {
    anchors {
      fill: parent
      margins: 16
    }

    spacing: 10
    
    // Header row with icon, label, and percentage
    RowLayout {
      Layout.fillWidth: true
      spacing: 10
      
      // Icon container
      Rectangle {
        Layout.preferredWidth: 32
        Layout.preferredHeight: 32
        radius: 16
        color: Qt.darker(Theme.accent, 1.6)
        
        Text {
          anchors.centerIn: parent 
          text: "󰃠"
          color: Theme.accent
          font.pixelSize: 18
          font.family: Theme.fontFamily
        }
      }
      
      Text {
        Layout.fillWidth: true
        text: "Brightness"
        color: Theme.fg
        font.pixelSize: 14
        font.family: Theme.fontFamily
        font.weight: Font.Medium
      }
      
      Text {
        text: Math.round(brightnessManager.brightness * 100) + "%"
        color: Theme.accent
        font.pixelSize: 14
        font.family: Theme.fontFamily
        font.weight: Font.Medium
      }
    }
    
    // Slider container - compact with tick marks
    ColumnLayout {
      Layout.fillWidth: true
      spacing: 4  // Gap between slider and ticks
      
      Item {
        Layout.fillWidth: true
        Layout.preferredHeight: 14  // slider area
        
        // Track background
        Rectangle {
          id: track
          anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
          }
          height: 6
          radius: 3
          color: Theme.border
          
          // Filled portion
          Rectangle {
            anchors {
              left: parent.left
              top: parent.top
              bottom: parent.bottom
            }
            width: Math.max(0, Math.min(parent.width, parent.width * brightnessManager.brightness))
            radius: parent.radius
            color: Theme.accent
            
            Behavior on width {
              NumberAnimation {
                duration: 100
                easing.type: Easing.OutCubic
              }
            }
          }
        }
        
        // Draggable handle
        Rectangle {
          id: handle
          x: Math.max(0, Math.min(parent.width - width, (parent.width - width) * brightnessManager.brightness))
          anchors.verticalCenter: parent.verticalCenter
          width: 18
          height: 18
          radius: 9
          color: Theme.accent
          border.color: Theme.bg1
          border.width: 3
          
          // Scale up on interaction
          scale: handleMouseArea.drag.active || handleMouseArea.containsMouse ? 1.2 : 1.0
          
          Behavior on x {
            enabled: !handleMouseArea.drag.active
            NumberAnimation {
              duration: 100
              easing.type: Easing.OutCubic
            }
          }
          
          Behavior on scale {
            NumberAnimation {
              duration: 150
              easing.type: Easing.OutCubic
            }
          }
          
          MouseArea {
            id: handleMouseArea
            anchors.fill: parent
            anchors.margins: -8
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            
            drag.target: parent
            drag.axis: Drag.XAxis
            drag.minimumX: 0
            drag.maximumX: track.width - handle.width
            
            onPositionChanged: {
              if (drag.active) {
                var newBrightness = (handle.x + handle.width / 2) / track.width
                newBrightness = Math.max(0.01, Math.min(1, newBrightness))  // Min 1% to prevent black screen
                brightnessManager.setBrightness(newBrightness)
              }
            }
          }
        }
        
        // Click on track to jump to position
        MouseArea {
          anchors.fill: track
          z: -1
          
          onClicked: mouse => {
            var newBrightness = mouse.x / track.width
            newBrightness = Math.max(0.01, Math.min(1, newBrightness))  // Min 1% to prevent black screen
            brightnessManager.setBrightness(newBrightness)
          }
        }
      }
      
      // Graduation tick marks - Material 3 style
      Row {
        Layout.fillWidth: true
        Layout.preferredHeight: 8
        spacing: 0
        
        Repeater {
          model: 11  // 0%, 10%, 20%... 100%
          
          Item {
            width: parent.width / 11
            height: 8
            
            Rectangle {
              anchors.horizontalCenter: parent.horizontalCenter
              anchors.top: parent.top
              width: 2
              height: index % 5 === 0 ? 6 : 4  // Longer ticks at 0%, 50%, 100%
              color: Theme.border
              opacity: index % 5 === 0 ? 0.8 : 0.6 // More visible at major marks
            }
          }
        }
      }
    }
  }
}
