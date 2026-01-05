import QtQuick
import QtQuick.Layouts
import "../../components"  // For MediaButton
import "../../theme"

Rectangle {
  id: root
  
  required property var mediaManager
  
  // Match other cards: rounded, elevated, transparent bg
  radius: Theme.radius.xl
  color: Theme.bg2
  border.width: 2
  border.color: Theme.borderDim
  
  // Subtle shadow layers for depth (consistent with ToggleCard/SliderCard)
  Rectangle {
    anchors.fill: parent
    anchors.margins: -2
    radius: parent.radius + 2
    color: "transparent"
    border.width: 2
    border.color: "#10000000"
    z: -1
  }
  
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
      margins: Theme.spacingL
    }
    spacing: Theme.spacingM
    
    // Header row - always visible
    RowLayout {
      Layout.fillWidth: true
      spacing: 12
      
      // Status icon
      Rectangle {
        Layout.preferredWidth: 40
        Layout.preferredHeight: 40
        radius: 20
        color: mediaManager.playerActive 
               ? Qt.darker(Theme.accent, 1.6) 
               : Qt.lighter(Theme.bg2, 1.3)
        
        Behavior on color { ColorAnimation { duration: 200 } }
        
        Text {
          anchors.centerIn: parent
          text: mediaManager.playerActive ? "󰝚" : "󰝛"
          color: mediaManager.playerActive ? Theme.accent : Theme.fgMuted
          font.pixelSize: 22
          font.family: Theme.fontFamily
          
          Behavior on color { ColorAnimation { duration: 200 } }
        }
      }
      
      // Player name and status text
      ColumnLayout {
        Layout.fillWidth: true
        spacing: 4
        
        Text {
          Layout.fillWidth: true
          text: mediaManager.playerActive 
                ? (mediaManager.playerName || "Media Player") 
                : "No Media Playing"
          color: Theme.fg
          font.pixelSize: 15
          font.family: Theme.fontFamily
          font.weight: Font.Medium
          elide: Text.ElideRight
        }
        
        Text {
          Layout.fillWidth: true
          text: mediaManager.playerActive ? "Active" : "Idle"
          color: mediaManager.playerActive ? Theme.accent : Theme.fgMuted
          font.pixelSize: 13
          font.family: Theme.fontFamily
          opacity: 0.8
        }
      }
    }
    
    // Expanded content - only when player is active
    ColumnLayout {
      Layout.fillWidth: true
      spacing: 12
      visible: mediaManager.playerActive
      opacity: mediaManager.playerActive ? 1 : 0
      
      Behavior on opacity { NumberAnimation { duration: 250 } }
      Behavior on Layout.preferredHeight { 
        enabled: visible
        NumberAnimation { duration: 300; easing.type: Easing.OutCubic } 
      }
      
      // Title & Artist
      ColumnLayout {
        Layout.fillWidth: true
        spacing: 4
        
        Text {
          Layout.fillWidth: true
          text: mediaManager.playerTitle || "Unknown Title"
          color: Theme.fg
          font.pixelSize: 16
          font.family: Theme.fontFamily
          font.weight: Font.Medium
          elide: Text.ElideRight
        }
        
        Text {
          Layout.fillWidth: true
          text: mediaManager.playerArtist || "Unknown Artist"
          color: Theme.fgMuted
          font.pixelSize: 14
          font.family: Theme.fontFamily
          elide: Text.ElideRight
        }
      }
      
      // Progress bar + time
      RowLayout {
        Layout.fillWidth: true
        spacing: 10
        
        Text {
          text: mediaManager.formatTime(mediaManager.playerPosition)
          color: Theme.fgMuted
          font.pixelSize: 13
          font.family: Theme.fontFamily
        }
        
        Rectangle {
          Layout.fillWidth: true
          height: 5
          radius: 2.5
          color: Theme.outline_variant
          
          Rectangle {
            width: mediaManager.playerLength > 0
                   ? parent.width * (mediaManager.playerPosition / mediaManager.playerLength)
                   : 0
            height: parent.height
            radius: parent.radius
            color: Theme.accent
            
            Behavior on width { NumberAnimation { duration: 150 } }
          }
        }
        
        Text {
          text: mediaManager.formatTime(mediaManager.playerLength)
          color: Theme.fgMuted
          font.pixelSize: 13
          font.family: Theme.fontFamily
        }
      }
      
      // Control buttons - centered
      RowLayout {
        Layout.alignment: Qt.AlignHCenter
        spacing: 24
        
        MediaButton {
          icon: "󰒮"
          onClicked: mediaManager.playerPrevious()
        }
        
        MediaButton {
          icon: mediaManager.playerPlaying ? "󰏤" : "󰼛"
          isPrimary: true
          onClicked: mediaManager.playerPlayPause()
        }
        
        MediaButton {
          icon: "󰒭"
          onClicked: mediaManager.playerNext()
        }
      }
    }
  }
}
