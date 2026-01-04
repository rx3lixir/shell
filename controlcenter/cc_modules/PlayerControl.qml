import QtQuick
import QtQuick.Layouts
import "../../theme"

Rectangle {
  id: root
  
  required property var mediaManager
  
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
  
  ColumnLayout {
    anchors {
      fill: parent
      margins: 16
    }
    spacing: 12
    
    // Header with player status
    RowLayout {
      Layout.fillWidth: true
      spacing: 10
      
      // Icon container - matching your toggle style
      Rectangle {
        Layout.preferredWidth: 32
        Layout.preferredHeight: 32
        radius: 16
        color: mediaManager.playerActive ? Qt.darker(Theme.accent, 1.6) : Qt.lighter(Theme.bg2, 1.3)
        
        Behavior on color {
          ColorAnimation { duration: 200 }
        }
        
        Text {
          anchors.centerIn: parent
          text: mediaManager.playerActive ? "󰝚" : "󰝛"
          color: mediaManager.playerActive ? Theme.accent : Theme.fgMuted
          font.pixelSize: 18
          font.family: Theme.fontFamily
          
          Behavior on color {
            ColorAnimation { duration: 200 }
          }
        }
      }
      
      ColumnLayout {
        Layout.fillWidth: true
        spacing: 2
        
        Text {
          Layout.fillWidth: true
          text: mediaManager.playerActive ? (mediaManager.playerName || "Media Player") : "No Media Playing"
          color: Theme.fg
          font.pixelSize: 14
          font.family: Theme.fontFamily
          font.weight: Font.Medium
          elide: Text.ElideRight
        }
        
        Text {
          Layout.fillWidth: true
          text: mediaManager.playerActive ? "Active" : "Idle"
          color: mediaManager.playerActive ? Theme.accent : Theme.fgMuted
          font.pixelSize: 12
          font.family: Theme.fontFamily
          opacity: 0.8
          visible: text !== ""
        }
      }
    }
    
    // Track info (only show if active)
    ColumnLayout {
      Layout.fillWidth: true
      spacing: 4
      visible: mediaManager.playerActive && (mediaManager.playerTitle || mediaManager.playerArtist)
      
      Text {
        Layout.fillWidth: true
        text: mediaManager.playerTitle || "Unknown Track"
        color: Theme.fg
        font.pixelSize: 14
        font.family: Theme.fontFamily
        elide: Text.ElideRight
        maximumLineCount: 1
      }
      
      Text {
        Layout.fillWidth: true
        text: mediaManager.playerArtist || ""
        color: Theme.fgMuted
        font.pixelSize: 12
        font.family: Theme.fontFamily
        elide: Text.ElideRight
        maximumLineCount: 1
        visible: text !== ""
      }
    }
    
    // Timeline with time labels - matching your slider style
    ColumnLayout {
      Layout.fillWidth: true
      spacing: 4
      visible: mediaManager.playerActive && mediaManager.playerLength > 0
      
      Item {
        Layout.fillWidth: true
        Layout.preferredHeight: 14
        
        // Track background
        Rectangle {
          id: timelineTrack
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
        
        // Draggable handle - matching slider style
        Rectangle {
          id: timelineHandle
          x: {
            if (mediaManager.playerLength <= 0) return 0
            var progress = mediaManager.playerPosition / mediaManager.playerLength
            return Math.max(0, Math.min(parent.width - width, (parent.width - width) * progress))
          }
          anchors.verticalCenter: parent.verticalCenter
          width: 18
          height: 18
          radius: 9
          color: Theme.accent
          border.color: Theme.bg1
          border.width: 3
          
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
            drag.maximumX: timelineTrack.width - timelineHandle.width
            
            onPositionChanged: {
              if (drag.active && mediaManager.playerLength > 0) {
                var newPosition = ((timelineHandle.x + timelineHandle.width / 2) / timelineTrack.width) * mediaManager.playerLength
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
          font.pixelSize: 11
          font.family: Theme.fontFamily
        }
        
        Item { Layout.fillWidth: true }
        
        Text {
          text: mediaManager.formatTime(mediaManager.playerLength)
          color: Theme.fgMuted
          font.pixelSize: 11
          font.family: Theme.fontFamily
        }
      }
    }
    
    // Control buttons - Material 3 style with proper depth
    RowLayout {
      Layout.fillWidth: true
      Layout.preferredHeight: 48
      spacing: 12
      visible: mediaManager.playerActive
      
      Item { Layout.fillWidth: true }
      
      // Previous button
      Rectangle {
        Layout.preferredWidth: 40
        Layout.preferredHeight: 40
        Layout.alignment: Qt.AlignVCenter
        radius: 20
        color: prevMouseArea.containsMouse ? Theme.bg1 : "transparent"
        border.width: 1
        border.color: prevMouseArea.containsMouse ? Theme.borderDim : "transparent"
        
        scale: prevMouseArea.pressed ? 0.9 : 1.0
        
        Behavior on color {
          ColorAnimation { duration: 150 }
        }
        
        Behavior on border.color {
          ColorAnimation { duration: 150 }
        }
        
        Behavior on scale {
          NumberAnimation { 
            duration: 100
            easing.type: Easing.OutCubic
          }
        }
        
        Text {
          anchors.centerIn: parent
          text: "󰒮"
          color: Theme.fg
          font.pixelSize: 20
          font.family: Theme.fontFamily
        }
        
        MouseArea {
          id: prevMouseArea
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          
          onClicked: {
            mediaManager.playerPrevious()
          }
        }
      }
      
      // Play/Pause button - hero button with more presence
      Rectangle {
        Layout.preferredWidth: 48
        Layout.preferredHeight: 48
        Layout.alignment: Qt.AlignVCenter
        radius: 24
        color: playMouseArea.containsMouse ? Theme.accent : Theme.accentTransparent
        border.width: 2
        border.color: Theme.accent
        
        scale: playMouseArea.pressed ? 0.92 : 1.0
        
        Behavior on color {
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
        
        // Subtle shadow for the main button
        Rectangle {
          anchors.centerIn: parent
          width: parent.width + 4
          height: parent.height + 4
          radius: (parent.width + 4) / 2
          color: "transparent"
          border.width: 2
          border.color: "#20000000"
          z: -1
          opacity: playMouseArea.containsMouse ? 1 : 0.6
          
          Behavior on opacity {
            NumberAnimation { duration: 150 }
          }
        }
        
        Text {
          anchors.centerIn: parent
          text: mediaManager.playerPlaying ? "󰏤" : "󰼛"
          color: Theme.fg
          font.pixelSize: 26
          font.family: Theme.fontFamily
        }
        
        MouseArea {
          id: playMouseArea
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          
          onClicked: {
            mediaManager.playerPlayPause()
          }
        }
      }
      
      // Next button
      Rectangle {
        Layout.preferredWidth: 40
        Layout.preferredHeight: 40
        Layout.alignment: Qt.AlignVCenter
        radius: 20
        color: nextMouseArea.containsMouse ? Theme.bg1 : "transparent"
        border.width: 1
        border.color: nextMouseArea.containsMouse ? Theme.borderDim : "transparent"
        
        scale: nextMouseArea.pressed ? 0.9 : 1.0
        
        Behavior on color {
          ColorAnimation { duration: 150 }
        }
        
        Behavior on border.color {
          ColorAnimation { duration: 150 }
        }
        
        Behavior on scale {
          NumberAnimation { 
            duration: 100
            easing.type: Easing.OutCubic
          }
        }
        
        Text {
          anchors.centerIn: parent
          text: "󰒭"
          color: Theme.fg
          font.pixelSize: 20
          font.family: Theme.fontFamily
        }
        
        MouseArea {
          id: nextMouseArea
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          
          onClicked: {
            mediaManager.playerNext()
          }
        }
      }

      Item { Layout.fillWidth: true }
    }
  }
}
