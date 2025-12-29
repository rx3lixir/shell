import QtQuick
import QtQuick.Layouts
import "../../theme"

Rectangle {
  id: root
  
  // Changed: now receives specific sub-manager
  required property var mediaManager
  
  radius: Theme.radiusXLarge
  color: Theme.bg2transparent
  
  Component.onCompleted: {
    console.log("PlayerControl module loaded")
  }
  
  ColumnLayout {
    anchors {
      fill: parent
      margins: Theme.spacingM
    }
    spacing: Theme.spacingS
    
    // Header with player status
    RowLayout {
      Layout.fillWidth: true
      spacing: Theme.spacingS
      
      Text {
        text: mediaManager.playerActive ? "󰝚" : "󰝛"
        color: mediaManager.playerActive ? Theme.accent : Theme.fgMuted
        font.pixelSize: Theme.fontSizeL
        font.family: Theme.fontFamily
      }
      
      Text {
        Layout.fillWidth: true
        text: mediaManager.playerActive ? (mediaManager.playerName || "Media Player") : "No Media Playing"
        color: Theme.fg
        font.pixelSize: Theme.fontSizeM
        font.family: Theme.fontFamily
        elide: Text.ElideRight
      }
    }
    
    // Track info (only show if active)
    ColumnLayout {
      Layout.fillWidth: true
      spacing: 2
      visible: mediaManager.playerActive && (mediaManager.playerTitle || mediaManager.playerArtist)
      
      Text {
        Layout.fillWidth: true
        text: mediaManager.playerTitle || "Unknown Track"
        color: Theme.fg
        font.pixelSize: Theme.fontSizeS
        font.family: Theme.fontFamily
        font.bold: true
        elide: Text.ElideRight
        maximumLineCount: 1
      }
      
      Text {
        Layout.fillWidth: true
        text: mediaManager.playerArtist || ""
        color: Theme.fgMuted
        font.pixelSize: Theme.fontSizeS
        font.family: Theme.fontFamily
        elide: Text.ElideRight
        maximumLineCount: 1
        visible: text !== ""
      }
    }
    
    // Timeline with time labels
    ColumnLayout {
      Layout.fillWidth: true
      spacing: 4
      visible: mediaManager.playerActive && mediaManager.playerLength > 0
      
      // Timeline slider
      Item {
        Layout.fillWidth: true
        Layout.preferredHeight: 20
        
        // Track background
        Rectangle {
          id: timelineTrack
          anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
          }
          height: 4
          radius: 2
          color: Theme.border
          
          // Filled portion (progress)
          Rectangle {
            anchors {
              left: parent.left
              top: parent.top
              bottom: parent.bottom
            }
            width: {
              if (mediaManager.playerLength <= 0) return 0
              var progress = mediaManager.playerPosition / mediaManager.playerLength
              return Math.max(0, Math.min(parent.width, parent.width * progress))
            }
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
          id: timelineHandle
          x: {
            if (mediaManager.playerLength <= 0) return 0
            var progress = mediaManager.playerPosition / mediaManager.playerLength
            return Math.max(0, Math.min(parent.width - width, (parent.width - width) * progress))
          }
          anchors.verticalCenter: parent.verticalCenter
          width: 12
          height: 12
          radius: 6
          color: handleMouseArea.drag.active || handleMouseArea.containsMouse ? Theme.accent : Theme.fg
          border.color: Theme.bg1
          border.width: 1
          
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
            anchors.margins: -4
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            
            drag.target: parent
            drag.axis: Drag.XAxis
            drag.minimumX: 0
            drag.maximumX: timelineTrack.width - timelineHandle.width
            
            onPositionChanged: {
              if (drag.active && mediaManager.playerLength > 0) {
                var newPosition = ((timelineHandle.x + timelineHandle.width / 2) / timelineTrack.width) * mediaManager.playerLength
                console.log("Timeline dragged to:", newPosition)
                mediaManager.playerSeek(newPosition)
              }
            }
          }
        }
        
        // Click on track to jump
        MouseArea {
          anchors.fill: timelineTrack
          z: -1
          
          onClicked: mouse => {
            if (mediaManager.playerLength > 0) {
              var newPosition = (mouse.x / timelineTrack.width) * mediaManager.playerLength
              console.log("Timeline clicked at:", newPosition)
              mediaManager.playerSeek(newPosition)
            }
          }
        }
      }
      
      // Time labels
      RowLayout {
        Layout.fillWidth: true
        
        Text {
          text: mediaManager.formatTime(mediaManager.playerPosition)
          color: Theme.fgMuted
          font.pixelSize: Theme.fontSizeXS
          font.family: Theme.fontFamily
        }
        
        Item { Layout.fillWidth: true }
        
        Text {
          text: mediaManager.formatTime(mediaManager.playerLength)
          color: Theme.fgMuted
          font.pixelSize: Theme.fontSizeXS
          font.family: Theme.fontFamily
        }
      }
    }
    
    // Control buttons
    RowLayout {
      Layout.fillWidth: true
      Layout.preferredHeight: 40
      spacing: Theme.spacingM
      visible: mediaManager.playerActive
      
      Item { Layout.fillWidth: true }
      
      // Previous button
      Rectangle {
        Layout.preferredWidth: 32
        Layout.preferredHeight: 32
        Layout.alignment: Qt.AlignVCenter
        radius: Theme.radiusLarge
        color: prevMouseArea.containsMouse ? Theme.bg1 : "transparent"
        
        Text {
          anchors.centerIn: parent
          text: "󰒮"
          color: Theme.fg
          font.pixelSize: Theme.fontSizeL
          font.family: Theme.fontFamily
        }
        
        MouseArea {
          id: prevMouseArea
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          
          onClicked: {
            console.log("Previous track clicked")
            mediaManager.playerPrevious()
          }
        }
      }
      
      // Play/Pause button
      Rectangle {
        Layout.preferredWidth: 40
        Layout.preferredHeight: 40
        Layout.alignment: Qt.AlignVCenter
        radius: 20
        color: playMouseArea.containsMouse ? Theme.accent : Theme.accentTransparent
        
        Behavior on color {
          ColorAnimation {
            duration: 150
            easing.type: Easing.OutCubic
          }
        }
        
        Text {
          anchors.centerIn: parent
          text: mediaManager.playerPlaying ? "󰏤" : "󰐊"
          color: Theme.fg
          font.pixelSize: Theme.fontSizeL
          font.family: Theme.fontFamily
        }
        
        MouseArea {
          id: playMouseArea
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          
          onClicked: {
            console.log("Play/Pause clicked")
            mediaManager.playerPlayPause()
          }
        }
      }
      
      // Next button
      Rectangle {
        Layout.preferredWidth: 32
        Layout.preferredHeight: 32
        Layout.alignment: Qt.AlignVCenter
        radius: Theme.radiusLarge
        color: nextMouseArea.containsMouse ? Theme.bg1 : "transparent"
        
        Text {
          anchors.centerIn: parent
          text: "󰒭"
          color: Theme.fg
          font.pixelSize: Theme.fontSizeL
          font.family: Theme.fontFamily
        }
        
        MouseArea {
          id: nextMouseArea
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          
          onClicked: {
            console.log("Next track clicked")
            mediaManager.playerNext()
          }
        }
      }
      
      Item { Layout.fillWidth: true }
    }
  }
}
