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
      let baseHeight = 668
      let mediaExpansion = manager.media.playerActive ? 120 : 0
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
    
    // Main container with Material 3 style
    Rectangle {
      id: background
      anchors.fill: parent
      radius: 28
      color: Theme.bg1transparent

      // Shadow layer 1 (closest)
      Rectangle {
        anchors.fill: parent
        anchors.margins: -2
        radius: parent.radius + 2
        color: "transparent"
        border.width: 2
        border.color: "#20000000"
        z: -1
      }
      
      // Shadow layer 2 (outer)
      Rectangle {
        anchors.fill: parent
        anchors.margins: -4
        radius: parent.radius + 4
        color: "transparent"
        border.width: 2
        border.color: "#30000000"
        z: -2
      }
      
      Column {
        anchors {
          fill: parent
          margins: Theme.spacingL
        }
        spacing: Theme.spacingM  // Single source of truth - change this value!
        
        // ========== HEADER ==========
        RowLayout {
          width: parent.width
          height: 40
          spacing: 8
          
          Text {
            Layout.fillWidth: true
            text: "Control Center"
            color: Theme.fg
            font.pixelSize: 18
            font.family: Theme.fontFamily
            font.weight: Font.Medium
          }
          
          Rectangle {
            Layout.preferredWidth: 40
            Layout.preferredHeight: 40
            radius: 20
            color: closeMouseArea.containsMouse ? Theme.bg2 : Theme.bg1
            
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
          width: parent.width
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
        Column {
          width: parent.width
          spacing: 12
          
          Modules.VolumeSlider {
            width: parent.width
            height: 98
            audioManager: loader.manager.audio
          }
          
          Modules.BrightnessSlider {
            width: parent.width
            height: 98
            brightnessManager: loader.manager.brightness
          }
        }
        
        // ========== MEDIA PLAYER ==========
        Modules.PlayerControl {
          width: parent.width
          height: loader.manager.media.playerActive ? 228 : 64
          mediaManager: loader.manager.media
          
          Behavior on height {
            NumberAnimation {
              duration: 300
              easing.type: Easing.OutCubic
            }
          }
        }
        
        // ========== UTILITIES ==========
        Modules.UtilitiesGrid {
          width: parent.width
          height: 60
          utilitiesManager: loader.manager.utilities
        }
      }
    }
  }
}
