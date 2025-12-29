import QtQuick
import Quickshell
import Quickshell.Io

Scope {
  id: manager
  
  // ========== STATE ==========
  property real brightness: 0.5
  property real brightnessMax: 1.0
  
  // Flag to track if brightness change came from user interaction (slider)
  property bool brightnessUserChange: false
  
  // ========== FILE WATCHER ==========
  FileView {
    id: brightnessFileWatcher
    path: "/sys/class/backlight/amdgpu_bl1/actual_brightness"
    watchChanges: true
    
    onFileChanged: {
      if (!manager.brightnessUserChange) {
        getCurrentBrightness()
      }
    }
  }
  
  // ========== GET MAX BRIGHTNESS ==========
  Process {
    id: brightnessMaxGetter
    command: ["brightnessctl", "max"]
    
    stdout: SplitParser {
      onRead: data => {
        var maxVal = parseInt(data.trim())
        
        if (!isNaN(maxVal) && maxVal > 0) {
          manager.brightnessMax = maxVal
          // Trigger getting current value
          brightnessCurrentGetter.running = true
        }
        
        brightnessMaxGetter.running = false
      }
    }
    
    stderr: SplitParser {
      onRead: data => {
        brightnessMaxGetter.running = false
      }
    }
  }
  
  // ========== GET CURRENT BRIGHTNESS ==========
  Process {
    id: brightnessCurrentGetter
    command: ["brightnessctl", "get"]
    
    stdout: SplitParser {
      onRead: data => {
        var currentVal = parseInt(data.trim())
        
        if (!isNaN(currentVal) && manager.brightnessMax > 0) {
          manager.brightness = currentVal / manager.brightnessMax
        }
        
        brightnessCurrentGetter.running = false
      }
    }
    
    stderr: SplitParser {
      onRead: data => {
        brightnessCurrentGetter.running = false
      }
    }
  }
  
  function getCurrentBrightness() {
    // Get max first, which will chain to getting current
    brightnessMaxGetter.running = true
  }
  
  // ========== SET BRIGHTNESS ==========
  Process {
    id: brightnessSetterProcess
    command: ["brightnessctl", "set", "50%"]
    
    onExited: code => {
      // Clear the user change flag after a short delay
      userChangeResetTimer.start()
    }
    
    stderr: SplitParser {
      onRead: data => {
        console.error("brightnessctl set error:", data)
      }
    }
  }
  
  // Timer to reset the user change flag
  Timer {
    id: userChangeResetTimer
    interval: 200
    onTriggered: {
      manager.brightnessUserChange = false
    }
  }
  
  // Timer for debouncing brightness readback
  Timer {
    id: brightnessDebounceTimer
    interval: 500
    onTriggered: {
      getCurrentBrightness()
    }
  }
  
  function setBrightness(newBrightness) {
    // Mark that this is a user-initiated change
    brightnessUserChange = true
    
    // Clamp between 0.01 and 1 (prevent completely dark screen)
    newBrightness = Math.max(0.01, Math.min(1, newBrightness))
    
    // Convert to percentage
    var percentage = Math.round(newBrightness * 100)
    
    // Update our property immediately for responsive UI
    brightness = newBrightness
    
    // Set using brightnessctl
    brightnessSetterProcess.command = ["brightnessctl", "set", percentage + "%"]
    brightnessSetterProcess.running = true
    
    // Restart debounce timer - only read back after user stops dragging
    brightnessDebounceTimer.restart()
  }
  
  Component.onCompleted: {
    // Read initial brightness - first get max, then current
    brightnessMaxGetter.running = true
  }
}
