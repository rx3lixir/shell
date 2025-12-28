import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire

Scope {
  id: manager
  
  // Visibility state
  property bool visible: false
  
  // WiFi state
  property bool wifiEnabled: true
  property string wifiStatus: "Unknown"
  
  // Bluetooth state  
  property bool bluetoothEnabled: false
  property string bluetoothStatus: "Off"
  
  // Recording state
  property bool isRecording: false
  
  // Volume state (0.0 to 1.0) - connected to PipeWire
  property real volume: 0.5
  
  // Brightness state (0.0 to 1.0)
  property real brightness: 0.5
  property real brightnessMax: 1.0
  
  // Flag to track if brightness change came from user interaction (slider)
  property bool brightnessUserChange: false
  
  onVisibleChanged: {
    console.log("=== CONTROL CENTER VISIBILITY CHANGED ===")
    console.log("Visible:", visible)
  }
  
  // ========== PIPEWIRE INTEGRATION FOR VOLUME ==========
  PwObjectTracker {
    objects: [ Pipewire.defaultAudioSink ]
  }
  
  property var audioSinkNode: Pipewire.defaultAudioSink
  property var audioSink: audioSinkNode?.audio ?? null
  
  // Sync volume from PipeWire to our property
  Connections {
    target: manager.audioSink
    enabled: manager.audioSink !== null
    
    function onVolumeChanged() {
      if (!manager.audioSink) return
      console.log("PipeWire volume changed:", manager.audioSink.volume)
      manager.volume = manager.audioSink.volume
    }
  }
  
  // Initialize volume from PipeWire
  Component.onCompleted: {
    console.log("=== CONTROL CENTER MANAGER LOADED ===")
    
    if (audioSink) {
      volume = audioSink.volume
      console.log("Initial volume from PipeWire:", volume)
    }
    
    // Read initial brightness - first get max, then current
    brightnessMaxGetter.running = true
    
    console.log("Initial states:")
    console.log("  WiFi:", wifiEnabled)
    console.log("  Bluetooth:", bluetoothEnabled)
    console.log("  Recording:", isRecording)
    console.log("  Volume:", volume)
    console.log("  Brightness:", brightness)
  }
  
  // ========== WIFI TOGGLE ==========
  Process {
    id: wifiToggleProcess
    command: ["sh", "-c", ""]
    
    onExited: code => {
      console.log("WiFi toggle process exited with code:", code)
    }
  }
  
  function toggleWifi() {
    console.log("=== TOGGLING WIFI ===")
    console.log("Current state:", wifiEnabled)
    
    // Toggle the state
    wifiEnabled = !wifiEnabled
    console.log("New state:", wifiEnabled)
    
    // Run nmcli command to toggle WiFi
    var cmd = wifiEnabled ? "nmcli radio wifi on" : "nmcli radio wifi off"
    console.log("Running command:", cmd)
    
    wifiToggleProcess.command = ["sh", "-c", cmd]
    wifiToggleProcess.running = true
  }
  
  // ========== BLUETOOTH TOGGLE ==========
  Process {
    id: bluetoothToggleProcess
    command: ["sh", "-c", ""]
    
    onExited: code => {
      console.log("Bluetooth toggle process exited with code:", code)
    }
  }
  
  function toggleBluetooth() {
    console.log("=== TOGGLING BLUETOOTH ===")
    console.log("Current state:", bluetoothEnabled)
    
    // Toggle the state
    bluetoothEnabled = !bluetoothEnabled
    console.log("New state:", bluetoothEnabled)
    
    // Run bluetoothctl command to toggle
    var cmd = bluetoothEnabled ? "bluetoothctl power on" : "bluetoothctl power off"
    console.log("Running command:", cmd)
    
    bluetoothToggleProcess.command = ["sh", "-c", cmd]
    bluetoothToggleProcess.running = true
  }
  
  // ========== SCREEN RECORDING ==========
  Process {
    id: recordingProcess
    command: ["sh", "-c", ""]
    
    onExited: code => {
      console.log("Recording process exited with code:", code)
    }
  }
  
  function toggleRecording() {
    console.log("=== TOGGLING RECORDING ===")
    console.log("Current recording state:", isRecording)
    
    // Toggle state
    isRecording = !isRecording
    console.log("New recording state:", isRecording)
    
    // Path to your recording script
    var scriptPath = "$HOME/.config/quickshell/scripts/screen-record.sh"
    console.log("Running recording script:", scriptPath)
    
    recordingProcess.command = ["sh", "-c", scriptPath]
    recordingProcess.running = true
  }
  
  // ========== VOLUME CONTROL ==========
  function setVolume(newVolume) {
    console.log("=== SETTING VOLUME ===")
    console.log("Old volume:", volume)
    console.log("New volume:", newVolume)
    
    // Clamp between 0 and 1
    newVolume = Math.max(0, Math.min(1, newVolume))
    
    // Set via PipeWire
    if (audioSink) {
      console.log("Setting PipeWire volume to:", newVolume)
      audioSink.volume = newVolume
      volume = newVolume
    } else {
      console.error("No audio sink available!")
    }
  }
  
  // ========== BRIGHTNESS CONTROL WITH BRIGHTNESSCTL ==========
  
  // Watch the brightness file for changes
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
  
  // Get max brightness
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
  
  // Separate process to get current brightness value
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
  
  // Set brightness using brightnessctl
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
}
