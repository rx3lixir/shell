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
      console.log("Brightness file changed externally")
      // Don't trigger readback if we just set it via slider
      if (!manager.brightnessUserChange) {
        console.log("External change detected - reading brightness")
        getCurrentBrightness()
      } else {
        console.log("User change - skipping readback to avoid conflict")
      }
    }
  }
  
  // ========== GET MAX BRIGHTNESS ==========
  Process {
    id: brightnessMaxGetter
    command: ["brightnessctl", "max"]
    
    stdout: SplitParser {
      onRead: data => {
        console.log("brightnessctl max output:", data)
        var maxVal = parseInt(data.trim())
        
        if (!isNaN(maxVal) && maxVal > 0) {
          manager.brightnessMax = maxVal
          console.log("Max brightness value:", maxVal)
          // Trigger getting current value
          brightnessCurrentGetter.running = true
        }
        
        brightnessMaxGetter.running = false
      }
    }
    
    stderr: SplitParser {
      onRead: data => {
        console.error("brightnessctl max error:", data)
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
        console.log("Current brightness value:", currentVal)
        
        if (!isNaN(currentVal) && manager.brightnessMax > 0) {
          manager.brightness = currentVal / manager.brightnessMax
          console.log("Calculated brightness percentage:", manager.brightness)
        }
        
        brightnessCurrentGetter.running = false
      }
    }
    
    stderr: SplitParser {
      onRead: data => {
        console.error("brightnessctl get error:", data)
        brightnessCurrentGetter.running = false
      }
    }
  }
  
  function getCurrentBrightness() {
    console.log("Getting current brightness...")
    // Get max first, which will chain to getting current
    brightnessMaxGetter.running = true
  }
  
  // ========== SET BRIGHTNESS ==========
  Process {
    id: brightnessSetterProcess
    command: ["brightnessctl", "set", "50%"]
    
    onExited: code => {
      console.log("Brightness set exited with code:", code)
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
      console.log("Resetting brightnessUserChange flag")
      manager.brightnessUserChange = false
    }
  }
  
  // Timer for debouncing brightness readback
  Timer {
    id: brightnessDebounceTimer
    interval: 500
    onTriggered: {
      console.log("Debounce timer triggered - reading back brightness")
      getCurrentBrightness()
    }
  }
  
  function setBrightness(newBrightness) {
    console.log("=== SETTING BRIGHTNESS ===")
    console.log("Old brightness:", brightness)
    console.log("New brightness:", newBrightness)
    
    // Mark that this is a user-initiated change
    brightnessUserChange = true
    
    // Clamp between 0.01 and 1 (prevent completely dark screen)
    newBrightness = Math.max(0.01, Math.min(1, newBrightness))
    
    // Convert to percentage
    var percentage = Math.round(newBrightness * 100)
    console.log("Setting brightness to:", percentage + "%")
    
    // Update our property immediately for responsive UI
    brightness = newBrightness
    
    // Set using brightnessctl
    brightnessSetterProcess.command = ["brightnessctl", "set", percentage + "%"]
    brightnessSetterProcess.running = true
    
    // Restart debounce timer - only read back after user stops dragging
    brightnessDebounceTimer.restart()
  }
  
  Component.onCompleted: {
    console.log("=== BRIGHTNESS MANAGER LOADED ===")
    // Read initial brightness - first get max, then current
    brightnessMaxGetter.running = true
  }
}
