import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import "../theme"
import "osd_components" as Components

LazyLoader {
  id: loader
  
  required property var manager
  
  active: manager.currentType !== manager.typeNone
  
  PanelWindow {
    anchors {
      top: true
      right: true
    }
    
    margins {
      top: Theme.barHeight + Theme.spacingS
      right: Theme.spacingM
    }
    
    exclusiveZone: 0
    implicitWidth: 300
    implicitHeight: 100
    
    color: "transparent"
    mask: null
    
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    
    // Container for card and shadow
    Item {
      anchors.fill: parent
      
      Rectangle {
        id: card
        anchors.fill: parent
        radius: Theme.radiusXLarge
        color: Theme.bg0transparent
        
        // Track if user is interacting - BOTH hover AND dragging
        property bool userInteracting: cardMouseArea.containsMouse || osdSlider.isDragging
        
        // Notify manager about interaction state
        onUserInteractingChanged: {
          loader.manager.userInteracting = userInteracting
        }
        
        opacity: loader.active ? 1.0 : 0.0
        
        Behavior on opacity {
          NumberAnimation {
            duration: 200
            easing.type: Easing.OutCubic
          }
        }
        
        ColumnLayout {
          anchors {
            fill: parent
            margins: Theme.spacingM
          }
          spacing: Theme.spacingM
          
          // Header row
          RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacingS
            
            Text {
              text: loader.manager.currentIcon
              font.family: Theme.fontFamily
              font.pixelSize: 20
              color: Theme.fg
            }
            
            Text {
              Layout.fillWidth: true
              text: {
                if (loader.manager.currentType === loader.manager.typeVolume) {
                  return loader.manager.currentMuted ? "Volume (Muted)" : "Volume"
                } else if (loader.manager.currentType === loader.manager.typeMic) {
                  return loader.manager.currentMuted ? "Microphone (Muted)" : "Microphone"
                } else if (loader.manager.currentType === loader.manager.typeBrightness) {
                  return "Brightness"
                }
                return ""
              }
              color: Theme.fg
              font.pixelSize: Theme.fontSizeM
              font.family: Theme.fontFamily
              font.bold: true
            }
            
            Text {
              text: Math.round(loader.manager.currentValue * 100) + "%"
              color: Theme.fgMuted
              font.pixelSize: Theme.fontSizeS
              font.family: Theme.fontFamily
            }
          }
          
          // Slider component
          Components.OsdSlider {
            id: osdSlider
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            
            value: loader.manager.currentValue
            
            onSliderMoved: newValue => {
              if (loader.manager.currentType === loader.manager.typeVolume && loader.manager.audioSink) {
                loader.manager.audioSink.volume = newValue
              } else if (loader.manager.currentType === loader.manager.typeBrightness) {
                loader.manager.brightnessManager.setBrightness(newValue)
              }
            }
          }
        }
        
        // Main mouse area to detect hover
        MouseArea {
          id: cardMouseArea
          anchors.fill: parent
          z: -1
          hoverEnabled: true
        }
      }
    }
  }
}
