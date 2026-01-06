// controlcenter/cc_modules/PlayerControl.qml
import QtQuick
import QtQuick.Layouts
import "../../components"
import "../../theme"

Card {
  id: root
  
  required property var mediaManager
  
  ColumnLayout {
    anchors.fill: parent
    spacing: Theme.spacing.md
    
    // Header row - always visible
    RowLayout {
      Layout.fillWidth: true
      spacing: Theme.spacing.sm
      
      // Status icon
      IconCircle {
        icon: mediaManager.playerActive ? "󰝚" : "󰝛"
        //iconSize: mediaManager.playerActive ? 32 : 28

        bgColor: mediaManager.playerActive 
                 ? Theme.primary_container 
                 : Theme.surface_container_high
        iconColor: mediaManager.playerActive 
                   ? Theme.primary 
                   : Theme.on_surface_variant
        
        Behavior on bgColor { ColorAnimation { duration: 200 } }
        Behavior on iconColor { ColorAnimation { duration: 200 } }
      }
      
      // Player name and status
      ColumnLayout {
        Layout.fillWidth: true
        spacing: 4
        
        Text {
          Layout.fillWidth: true
          text: mediaManager.playerActive 
                ? (mediaManager.playerName || "Media Player") 
                : "No Media Playing"
          color: Theme.on_surface
          font.pixelSize: Theme.typography.md
          font.family: Theme.typography.fontFamily
          font.weight: Theme.typography.weightMedium
          elide: Text.ElideRight
        }
        
        Text {
          Layout.fillWidth: true
          text: mediaManager.playerActive ? "Active" : "Idle"
          color: mediaManager.playerActive ? Theme.primary : Theme.on_surface_variant
          font.pixelSize: Theme.typography.sm
          font.family: Theme.typography.fontFamily
          opacity: 0.8
        }
      }
    }
    
    // Expanded content - only when player is active
    ColumnLayout {
      Layout.fillWidth: true
      spacing: Theme.spacing.sm
      visible: mediaManager.playerActive
      opacity: mediaManager.playerActive ? 1 : 0
      
      Behavior on opacity { 
        NumberAnimation { duration: 250 } 
      }
      
      // Title & Artist
      ColumnLayout {
        Layout.fillWidth: true
        spacing: 4
        
        Text {
          Layout.fillWidth: true
          text: mediaManager.playerTitle || "Unknown Title"
          color: Theme.on_surface
          font.pixelSize: Theme.typography.lg
          font.family: Theme.typography.fontFamily
          font.weight: Theme.typography.weightMedium
          elide: Text.ElideRight
        }
        
        Text {
          Layout.fillWidth: true
          text: mediaManager.playerArtist || "Unknown Artist"
          color: Theme.on_surface_variant
          font.pixelSize: Theme.typography.md
          font.family: Theme.typography.fontFamily
          elide: Text.ElideRight
        }
      }
      
      // Progress bar + time
      RowLayout {
        Layout.fillWidth: true
        spacing: Theme.spacing.sm
        
        Text {
          text: mediaManager.formatTime(mediaManager.playerPosition)
          color: Theme.on_surface_variant
          font.pixelSize: Theme.typography.sm
          font.family: Theme.typography.fontFamily
        }
        
        Rectangle {
          Layout.fillWidth: true
          height: 4
          radius: Theme.radius.sm
          color: Theme.outline_variant
          
          Rectangle {
            width: mediaManager.playerLength > 0
                   ? parent.width * (mediaManager.playerPosition / mediaManager.playerLength)
                   : 0
            height: parent.height
            radius: parent.radius
            color: Theme.primary
            
            Behavior on width { 
              NumberAnimation { duration: 150 } 
            }
          }
        }
        
        Text {
          text: mediaManager.formatTime(mediaManager.playerLength)
          color: Theme.on_surface_variant
          font.pixelSize: Theme.typography.sm
          font.family: Theme.typography.fontFamily
        }
      }
      
      // Control buttons - centered
      RowLayout {
        Layout.alignment: Qt.AlignHCenter
        spacing: Theme.spacing.lg
        
        RoundIconButton {
          icon: "󰒮"
          onClicked: mediaManager.playerPrevious()
        }
        
        RoundIconButton {
          icon: mediaManager.playerPlaying ? "󰏤" : "󰼛"
          isPrimary: true
          onClicked: mediaManager.playerPlayPause()
        }
        
        RoundIconButton {
          icon: "󰒭"
          onClicked: mediaManager.playerNext()
        }
      }
    }
  }
}
