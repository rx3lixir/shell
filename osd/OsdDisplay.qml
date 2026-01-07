import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import "../theme"
import "../components"
import "osd_components" as Components

LazyLoader {
  id: loader
  
  required property var manager
  
  active: manager.currentType !== manager.typeNone
  
  PanelWindow {
    anchors {
      right: true
      top: true
    }
    
    margins {
      right: Theme.spacing.xl
      top: 300
    }
    
    exclusiveZone: 0
    implicitWidth: 60
    implicitHeight: 220
    
    color: "transparent"
    mask: null
    
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    
    Rectangle {
      anchors.fill: parent
      color: Theme.surface_container
      radius: Theme.radius.xl
      border.width: 2
      border.color: Theme.surface_container_high
      
      property bool userInteracting: osdSlider.isDragging
      
      onUserInteractingChanged: {
        loader.manager.userInteracting = userInteracting
      }
      
      // Wrapper with padding
      Item {
        anchors {
          fill: parent
          margins: Theme.padding.sm
        }
        
        ColumnLayout {
          anchors.centerIn: parent
          spacing: Theme.spacing.md
          
          IconCircle {
            Layout.alignment: Qt.AlignHCenter

            icon: loader.manager.currentIcon
            iconSize: Theme.typography.lg
            iconColor: Theme.primary

            bgColor: Theme.primary_container
          }
          
          Components.VerticalOsdSlider {
  id: osdSlider
  Layout.alignment: Qt.AlignHCenter
  value: loader.manager.currentValue
  isMuted: loader.manager.currentMuted
  
  // Track if user is interacting with OSD slider
  property bool isDragging: false
  
  onIsDraggingChanged: {
    // Notify system state when user drags OSD slider
    loader.manager.systemState.userInteracting = isDragging
  }
  
  onSliderMoved: newValue => {
    // Mark as dragging
    if (!osdSlider.isDragging) {
      osdSlider.isDragging = true
    }
    
    // Write directly to system state volume module
    if (loader.manager.currentType === loader.manager.typeVolume) {
      loader.manager.systemState.volume.setVolume(newValue)
    } else if (loader.manager.currentType === loader.manager.typeBrightness) {
      // OLD: Still using old brightness manager for now
      loader.manager.brightnessManager.setBrightness(newValue)
    }
    
    // Reset dragging after a delay
    osdDragTimer.restart()
  }
}

// Timer to reset OSD dragging state
Timer {
  id: osdDragTimer
  interval: 150
  onTriggered: {
    osdSlider.isDragging = false
  }
}
          
          Text {
            Layout.alignment: Qt.AlignHCenter
            text: Math.round(loader.manager.currentValue * 100)
            color: Theme.on_surface
            font.pixelSize: Theme.typography.md
            font.family: Theme.typography.fontFamily
            font.weight: Theme.typography.weightMedium
          }
        }
      }
    }
  }
}
