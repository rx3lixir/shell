import QtQuick
import Quickshell

// OsdManager - Manages on-screen display popups
// Reads from SystemStateManager's Volume module
Scope {
  id: manager
  
  // Reference to system state (single source of truth)
  required property var systemState

  // OSD type constants
  readonly property string typeNone: "none"
  readonly property string typeVolume: "volume"
  readonly property string typeMic: "mic"
  readonly property string typeBrightness: "brightness"

  // Current OSD display state
  property string currentType: typeNone
  property real currentValue: 0.0
  property bool currentMuted: false
  property string currentIcon: ""

  // Hide timer
  Timer {
    id: hideTimer
    interval: 2000
    running: false
    repeat: false
    
    onTriggered: {
      manager.currentType = manager.typeNone
    }
  }

  // Helper to show OSD
  function showOsd(type, value, muted, icon) {
    manager.currentType = type
    manager.currentValue = value
    manager.currentMuted = muted
    manager.currentIcon = icon
    
    hideTimer.restart()
  }

  // ============================================================================
  // VOLUME MODULE - Listen for external changes
  // ============================================================================
  
  Connections {
    target: manager.systemState.volume
    
    // Volume changed externally (e.g., media keys)
    function onVolumeChangedExternally(volume, muted) {
      manager.showOsd(
        manager.typeVolume,
        volume,
        muted,
        manager.systemState.volume.getVolumeIcon(volume, muted)
      )
    }
    
    // Mic changed externally
    function onMicChangedExternally(volume, muted) {
      manager.showOsd(
        manager.typeMic,
        volume,
        muted,
        manager.systemState.volume.getMicIcon(muted)
      )
    }
  }
  
  // ============================================================================
  // BRIGHTNESS MODULE - Listen for external changes
  // ============================================================================
  
  Connections {
    target: manager.systemState.brightness
    
    function onBrightnessChangedExternally(brightness) {
      manager.showOsd(
        manager.typeBrightness,
        brightness,
        false,
        getBrightnessIcon(brightness)
      )
    }
  }
  
  function getBrightnessIcon(brightness) {
    if (brightness < 0.33) return "󰃞"
    if (brightness < 0.66) return "󰃟"
    return "󰃠"
  }
}
