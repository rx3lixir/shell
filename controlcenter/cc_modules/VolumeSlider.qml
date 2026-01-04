import QtQuick
import QtQuick.Layouts
import "../../theme"

Rectangle {
  id: root
  
  required property var audioManager
  
  radius: 26
  color: Theme.bg2transparent
  border.width: 2
  border.color: Theme.borderDim

    // Shadow layer 1 (closest)
  Rectangle {
    anchors.fill: parent
    anchors.margins: -2
    radius: parent.radius + 2
    color: "transparent"
    border.width: 2
    border.color: "#10000000"
    z: -1
  }
  
  // Shadow layer 2 (outer)
  Rectangle {
    anchors.fill: parent
    anchors.margins: -4
    radius: parent.radius + 4
    color: "transparent"
    border.width: 2
    border.color: "#05000000"
    z: -2
  }
  
  // Compact padding for 88px total height
  ColumnLayout {
    anchors {
      fill: parent
      margins: 16  // Tighter margins
    }

    spacing: 10
    
    // Header row with icon, label, and percentage
    RowLayout {
      Layout.fillWidth: true
      spacing: 10
      
      // Icon container - slightly smaller
      Rectangle {
        Layout.preferredWidth: 32
        Layout.preferredHeight: 32
        radius: 16
        color: Qt.lighter(Theme.bg2, 1.3)
        
        Text {
          anchors.centerIn: parent
          text: "󰕾"
          color: Theme.fg
          font.pixelSize: 18 
          font.family: Theme.fontFamily
        }
      }
      
      Text {
        Layout.fillWidth: true
        text: "Volume"
        color: Theme.fg
        font.pixelSize: 14
        font.family: Theme.fontFamily
        font.weight: Font.Medium
      }
      
      Text {
        text: Math.round(audioManager.volume * 100) + "%"
        color: Theme.border
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
            width: parent.width * audioManager.volume
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
        
        // Draggable handle - slightly smaller
        Rectangle {
          id: handle
          x: Math.max(0, Math.min(parent.width - width, (parent.width - width) * audioManager.volume))
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
            anchors.margins: -8  // Good hit area
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            
            drag.target: parent
            drag.axis: Drag.XAxis
            drag.minimumX: 0
            drag.maximumX: track.width - handle.width
            
            onPositionChanged: {
              if (drag.active) {
                var newVolume = (handle.x + handle.width / 2) / track.width
                newVolume = Math.max(0, Math.min(1, newVolume))
                audioManager.setVolume(newVolume)
              }
            }
          }
        }
        
        // Click on track to jump to position
        MouseArea {
          anchors.fill: track
          z: -1
          
          onClicked: mouse => {
            var newVolume = mouse.x / track.width
            newVolume = Math.max(0, Math.min(1, newVolume))
            audioManager.setVolume(newVolume)
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
