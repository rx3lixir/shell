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
  
  // Load when visible
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
      console.log("=== CONTROL CENTER WINDOW LOADED ===")
      exclusiveZone = 0
      implicitWidth = 340
      implicitHeight = 810
    }
    
    // Handle Escape key to close
    contentItem {
      focus: true
      
      Keys.onPressed: event => {
        console.log("Key pressed in control center:", event.key)
        
        if (event.key === Qt.Key_Escape) {
          console.log("Escape pressed - closing control center")
          loader.manager.visible = false
          event.accepted = true
        }
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
        
        // Header
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
              
              onClicked: {
                console.log("Close button clicked")
                loader.manager.visible = false
              }
            }
          }
        }
        
        // Toggles Grid (WiFi, Bluetooth)
        GridLayout {
          Layout.fillWidth: true
          columns: 2
          rowSpacing: Theme.spacingS
          columnSpacing: Theme.spacingS
          
          Modules.WiFiToggle {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            manager: loader.manager
          }
          
          Modules.BluetoothToggle {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            manager: loader.manager
          }
        }
        
        // Recording Button (full width)
        Modules.RecordingButton {
          Layout.fillWidth: true
          Layout.preferredHeight: 60
          manager: loader.manager
        }
        
        // Volume Slider
        Modules.VolumeSlider {
          Layout.fillWidth: true
          Layout.preferredHeight: 70
          manager: loader.manager
        }
        
        // Brightness Slider
        Modules.BrightnessSlider {
          Layout.fillWidth: true
          Layout.preferredHeight: 70
          manager: loader.manager
        }
        
        // Media Player Control
        Modules.PlayerControl {
          Layout.fillWidth: true
          Layout.preferredHeight: loader.manager.playerActive ? 180 : 60
          manager: loader.manager
          
          Behavior on Layout.preferredHeight {
            NumberAnimation {
              duration: 250
              easing.type: Easing.OutCubic
            }
          }
        }
        
        // Utilities Grid
        Modules.UtilitiesGrid {
          Layout.fillWidth: true
          Layout.preferredHeight: 210
          manager: loader.manager
        }
        
        // Spacer to push everything up
        Item {
          Layout.fillHeight: true
        }
      }
    }
  }
}
