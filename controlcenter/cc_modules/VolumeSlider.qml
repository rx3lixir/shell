import QtQuick
import QtQuick.Layouts
import "../../theme"

Rectangle {
  id: root
  
  // Changed: now receives specific sub-manager
  required property var audioManager
  
  radius: Theme.radiusXLarge
  color: Theme.bg2transparent
  
  Component.onCompleted: {
    console.log("VolumeSlider module loaded")
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
        text: "󰕾"
        color: Theme.fg
        font.pixelSize: Theme.fontSizeM
        font.family: Theme.fontFamily
      }
      
      Text {
        Layout.fillWidth: true
        text: "Volume"
        color: Theme.fg
        font.pixelSize: Theme.fontSizeM
        font.family: Theme.fontFamily
      }
      
      Text {
        text: Math.round(audioManager.volume * 100) + "%"
        color: Theme.fgMuted
        font.pixelSize: Theme.fontSizeM
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
      
      // Draggable handle
      Rectangle {
        id: handle
        x: (parent.width - width) * audioManager.volume
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
              var newVolume = (handle.x + handle.width / 2) / track.width
              newVolume = Math.max(0, Math.min(1, newVolume))
              console.log("Volume dragged to:", newVolume)
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
          console.log("Volume track clicked at:", newVolume)
          audioManager.setVolume(newVolume)
        }
      }
    }
  }
}
