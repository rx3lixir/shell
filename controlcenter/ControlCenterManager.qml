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
    
    // Read initial brightness
    checkBrightness()
    
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
  
  // ========== BRIGHTNESS CONTROL ==========
  
  // Read max brightness once at startup
  Process {
    id: maxBrightnessReader
    running: true
    command: ["cat", "/sys/class/backlight/amdgpu_bl1/max_brightness"]
    
    stdout: SplitParser {
      onRead: data => {
        var maxVal = parseInt(data.trim())
        if (!isNaN(maxVal) && maxVal > 0) {
          manager.brightnessMax = maxVal
          console.log("Max brightness:", manager.brightnessMax)
        }
        maxBrightnessReader.running = false
      }
    }
  }
  
  // Read current brightness
  Process {
    id: currentBrightnessReader
    command: ["cat", "/sys/class/backlight/amdgpu_bl1/actual_brightness"]
    
    stdout: SplitParser {
      onRead: data => {
        var rawValue = parseInt(data.trim())
        if (!isNaN(rawValue) && manager.brightnessMax > 0) {
          var newBrightness = rawValue / manager.brightnessMax
          console.log("Current brightness read:", newBrightness)
          manager.brightness = newBrightness
        }
        currentBrightnessReader.running = false
      }
    }
  }
  
  function checkBrightness() {
    console.log("Checking current brightness...")
    currentBrightnessReader.running = true
  }
  
  // Set brightness
  Process {
    id: brightnessWriter
    command: ["sh", "-c", ""]
    
    onExited: code => {
      console.log("Brightness write exited with code:", code)
      // Read back the actual brightness after setting
      checkBrightness()
    }
  }
  
  function setBrightness(newBrightness) {
    console.log("=== SETTING BRIGHTNESS ===")
    console.log("Old brightness:", brightness)
    console.log("New brightness:", newBrightness)
    
    // Clamp between 0 and 1
    newBrightness = Math.max(0, Math.min(1, newBrightness))
    
    // Calculate raw value
    var rawValue = Math.round(newBrightness * brightnessMax)
    console.log("Setting raw brightness value:", rawValue)
    
    // Write to brightness file (requires sudo or appropriate permissions)
    var cmd = "echo " + rawValue + " | tee /sys/class/backlight/amdgpu_bl1/brightness"
    console.log("Running command:", cmd)
    
    brightnessWriter.command = ["sh", "-c", cmd]
    brightnessWriter.running = true
    
    // Update our property optimistically
    brightness = newBrightness
  }
}
