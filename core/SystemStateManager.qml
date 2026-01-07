import QtQuick
import Quickshell 
import "system_state" as State

Scope {
  id: manager

  // Sets this to true when user is actively interacting with ANY control
  // (e.g., dragging sliders in control center)
  // This is shared across all modules to prevent OSD popups during interaction
  property bool userInteracting: false

  // ============================================================================
  // STATE MODULES
  // ============================================================================

  State.Brightness {
    id: brightnessModule
    userInteracting: manager.userInteracting
  }
  
  State.Volume {
    id: volumeModule
    userInteracting: manager.userInteracting
  }
  
  State.Bluetooth {
    id: bluetoothModule
  }
  
  State.Battery {
    id: batteryModule
  }

  // ============================================================================
  // EXPOSED MODULES (Public API)
  // ============================================================================
  
  readonly property var brightness: brightnessModule
  readonly property var volume: volumeModule
  readonly property var bluetooth: bluetoothModule
  readonly property var wifi: wifiModule
  readonly property var battery: batteryModule
  readonly property var time: timeModule
}
