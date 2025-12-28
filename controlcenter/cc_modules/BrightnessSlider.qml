import QtQuick
import QtQuick.Layouts
import "../../theme"

Rectangle {
  id: root
  
  required property var manager
  
  radius: Theme.radiusXLarge
  color: Theme.bg2transparent
  
  Component.onCompleted: {
    console.log("BrightnessSlider module loaded")
    console.log("Initial brightness:", manager.brightness)
  }
  
  ColumnLayout {
    anchors {
      fill: parent
      margins: Theme.spacingM
    }
    spacing: Theme.spacingS
    
    // Header row with icon, label, and percentage
    RowLayout {
      Layout.fillWidth: true
      spacing: Theme.spacingS
      
      Text {
        text: "󰃠"
        color: Theme.fg
        font.pixelSize: Theme.fontSizeL
        font.family: Theme.fontFamily
      }
      
      Text {
        Layout.fillWidth: true
        text: "Brightness"
        color: Theme.fg
        font.pixelSize: Theme.fontSizeM
        font.family: Theme.fontFamily
      }
      
      Text {
        text: Math.round(manager.brightness * 100) + "%"
        color: Theme.fgMuted
        font.pixelSize: Theme.fontSizeS
        font.family: Theme.fontFamily
      }
    }
    
    // Slider with draggable handle
    Item {
      Layout.fillWidth: true
      Layout.preferredHeight: 20
      
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
          width: Math.max(0, Math.min(parent.width, parent.width * manager.brightness))
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
        x: Math.max(0, Math.min(parent.width - width, (parent.width - width) * manager.brightness))
        anchors.verticalCenter: parent.verticalCenter
        width: 16
        height: 16
        radius: 8
        color: handleMouseArea.drag.active || handleMouseArea.containsMouse ? Theme.accent : Theme.fg
        border.color: Theme.bg1
        border.width: 2
        
        Behavior on x {
          enabled: !handleMouseArea.drag.active
          NumberAnimation {
            duration: 100
            easing.type: Easing.OutCubic
          }
        }
        
        Behavior on color {
          ColorAnimation {
            duration: 150
            easing.type: Easing.OutCubic
          }
        }
        
        MouseArea {
          id: handleMouseArea
          anchors.fill: parent
          anchors.margins: -4  // Larger hit area
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
              console.log("Brightness dragged to:", newBrightness)
              manager.setBrightness(newBrightness)
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
          console.log("Brightness track clicked at:", newBrightness)
          manager.setBrightness(newBrightness)
        }
      }
    }
  }
}
