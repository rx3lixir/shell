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
      top: Theme.barHeight + Theme.spacingM
      left: Theme.spacingM
    }
    
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    
    color: "transparent"
    mask: null
    
    Component.onCompleted: {
      exclusiveZone = 0
      implicitWidth = 360
    }
    
    // Dynamic height based on media player state
    implicitHeight: {
      let baseHeight = 800 // Base height without expanded media
      let mediaExpansion = manager.media.playerActive ? 140 : 0  // Extra height when media is active
      return baseHeight + mediaExpansion
    }
    
    Behavior on implicitHeight {
      NumberAnimation {
        duration: 300
        easing.type: Easing.OutCubic
      }
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
    
    // Shadow layer for Material 3 elevation (simple approach)
    Rectangle {
      anchors.fill: background
      anchors.margins: -4
      radius: 32
      color: "#20000000"
      z: -1
    }
    
    // Main container with Material 3 style
    Rectangle {
      id: background
      anchors.fill: parent
      radius: 28  // Material 3 uses larger corner radius
      color: Theme.bg1transparent
      
      ColumnLayout {
        anchors {
          fill: parent
          margins: 20  // Material 3 comfortable padding
          topMargin: 24
          bottomMargin: 24
        }
        spacing: 16  // Consistent spacing throughout
        
        // ========== HEADER ==========
        RowLayout {
          Layout.fillWidth: true
          Layout.bottomMargin: 4
          spacing: 12
          
          Text {
            Layout.fillWidth: true
            text: "Control Center"
            color: Theme.fg
            font.pixelSize: 18
            font.family: Theme.fontFamily
            font.weight: Font.Medium
          }
          
          // Close button with Material 3 styling
          Rectangle {
            Layout.preferredWidth: 40
            Layout.preferredHeight: 40
            radius: 20
            color: closeMouseArea.containsMouse ? Theme.bg2 : "transparent"
            
            Behavior on color {
              ColorAnimation { duration: 100 }
            }
            
            Text {
              anchors.centerIn: parent
              text: "✕"
              color: Theme.fg
              font.pixelSize: 18
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
        
        // ========== TOGGLES GRID ==========
        GridLayout {
          Layout.fillWidth: true
          columns: 2
          rowSpacing: 12
          columnSpacing: 12
          
          Modules.WiFiToggle {
            Layout.fillWidth: true 
            Layout.preferredHeight: 64
            networkManager: loader.manager.network
          }
          
          Modules.BluetoothToggle {
            Layout.fillWidth: true
            Layout.preferredHeight: 64
            networkManager: loader.manager.network
          }

          Modules.RecordingButton {
            Layout.fillWidth: true
            Layout.preferredHeight: 64 
            recordingManager: loader.manager.recording
          }

          Modules.PowerButton {
            Layout.fillWidth: true
            Layout.preferredHeight: 64 
            powerMenuManager: loader.manager.powerMenuManager
          }
        }
        
        // ========== SLIDERS SECTION ==========
        ColumnLayout {
          Layout.fillWidth: true
          spacing: 12
          
          Modules.VolumeSlider {
            Layout.fillWidth: true
            Layout.preferredHeight: 98
            audioManager: loader.manager.audio
          }
          
          Modules.BrightnessSlider {
            Layout.fillWidth: true
            Layout.preferredHeight: 98 
            brightnessManager: loader.manager.brightness
          }
        }
        
        // ========== MEDIA PLAYER ==========
        Modules.PlayerControl {
          Layout.fillWidth: true
          Layout.preferredHeight: loader.manager.media.playerActive ? 200 : 64
          mediaManager: loader.manager.media
          
          Behavior on Layout.preferredHeight {
            NumberAnimation {
              duration: 300
              easing.type: Easing.OutCubic
            }
          }
        }
        
        // ========== UTILITIES ==========
        Modules.UtilitiesGrid {
          Layout.fillWidth: true
          Layout.preferredHeight: 120
          utilitiesManager: loader.manager.utilities
        }
      }
    }
  }
}
