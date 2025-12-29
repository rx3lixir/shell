import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import "../theme"
import "cc_modules" as Modules

LazyLoader {
  id: loader
  
  required property var manager
  
  active: manager.visible
  
  PanelWindow {
    id: controlCenterWindow
    
    anchors {
      top: true
      left: true
    }
    
    margins {
      top: Theme.barHeight + Theme.spacingS
      left: Theme.spacingM
    }
    
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    
    color: "transparent"
    mask: null
    
    Component.onCompleted: {
      exclusiveZone = 0
      implicitWidth = 340
      implicitHeight = 800
      //implicitHeight = loader.manager.mediaManager.playerActive ? 800 : 600
    }

    
    contentItem {
      focus: true
      
      Keys.onPressed: event => {
        if (event.key === Qt.Key_Escape) {
          loader.manager.visible = false
          event.accepted = true
        }
      }
    }

    MouseArea {
      anchors.fill: parent
      onClicked: {
        loader.manager.visible = false
      }
    }
    
    Rectangle {
      id: background
      anchors.fill: parent
      radius: Theme.radiusXLarge
      color: Theme.bg1transparent
      
      ColumnLayout {
        anchors {
          fill: parent
          margins: Theme.spacingM
        }
        spacing: Theme.spacingM
        
        // ========== HEADER ==========
        RowLayout {
          Layout.fillWidth: true
          spacing: Theme.spacingS
          
          Text {
            Layout.fillWidth: true
            text: "Control Center"
            color: Theme.fg
            font.pixelSize: Theme.fontSizeM
            font.family: Theme.fontFamily
            font.bold: true
          }
          
          // Close button
          Rectangle {
            Layout.preferredWidth: 24
            Layout.preferredHeight: 24
            radius: Theme.radiusMedium
            color: closeMouseArea.containsMouse ? Theme.bg2 : "transparent"
            
            Text {
              anchors.centerIn: parent
              text: "✕"
              color: Theme.fg
              font.pixelSize: Theme.fontSizeS
              font.family: Theme.fontFamily
            }
            
            MouseArea {
              id: closeMouseArea
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: loader.manager.visible = false
            }
          }
        }
        
        // ========== NETWORK TOGGLES ==========
        GridLayout {
          Layout.fillWidth: true
          columns: 2
          rowSpacing: Theme.spacingS
          columnSpacing: Theme.spacingS
          
          Modules.WiFiToggle {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            networkManager: loader.manager.network
          }
          
          Modules.BluetoothToggle {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            networkManager: loader.manager.network
          }
        }
        
        // ========== RECORDING ==========
        Modules.RecordingButton {
          Layout.fillWidth: true
          Layout.preferredHeight: 60
          recordingManager: loader.manager.recording
        }
        
        // ========== SLIDERS ==========
        Modules.VolumeSlider {
          Layout.fillWidth: true
          Layout.preferredHeight: 70
          audioManager: loader.manager.audio
        }
        
        Modules.BrightnessSlider {
          Layout.fillWidth: true
          Layout.preferredHeight: 70
          brightnessManager: loader.manager.brightness
        }
        
        // ========== MEDIA PLAYER ==========
        Modules.PlayerControl {
          Layout.fillWidth: true
          Layout.preferredHeight: loader.manager.media.playerActive ? 180 : 60
          mediaManager: loader.manager.media
          
          Behavior on Layout.preferredHeight {
            NumberAnimation {
              duration: 250
              easing.type: Easing.OutCubic
            }
          }
        }
        
        // ========== UTILITIES ==========
        Modules.UtilitiesGrid {
          Layout.fillWidth: true
          Layout.preferredHeight: 200
          utilitiesManager: loader.manager.utilities
        }
        
        // Spacer
        Item { Layout.fillHeight: true }
      }
    }
  }
}
