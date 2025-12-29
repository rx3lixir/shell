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
  
  // ========== MEDIA PLAYER STATE ==========
  property bool playerActive: false
  property bool playerPlaying: false
  property string playerTitle: ""
  property string playerArtist: ""
  property string playerName: ""
  property real playerPosition: 0.0  // Current position in seconds
  property real playerLength: 0.0     // Total length in seconds
  
  // ========== UTILITIES STATE ==========
  property bool xrayActive: false
  property bool kanataActive: false
  property bool nightLightActive: false
  
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
  
  // ========== MEDIA PLAYER STATE ==========
  
  // Get player status
  Process {
    id: playerStatusProcess
    command: ["playerctl", "status"]
    
    stdout: SplitParser {
      onRead: data => {
        if (!data) {
          manager.playerActive = false
          return
        }
        var status = data.trim()
        console.log("Player status:", status)
        
        if (status === "Playing" || status === "Paused") {
          manager.playerActive = true
          manager.playerPlaying = (status === "Playing")
          
          // Get metadata and position
          playerMetadataProcess.running = true
          playerPositionProcess.running = true
        } else {
          manager.playerActive = false
        }
      }
    }
    
    stderr: SplitParser {
      onRead: data => {
        // No player available
        manager.playerActive = false
      }
    }
  }
  
  // Get player metadata (including length)
  Process {
    id: playerMetadataProcess
    command: ["playerctl", "metadata", "--format", "{{title}}|{{artist}}|{{playerName}}|{{mpris:length}}"]
    
    stdout: SplitParser {
      onRead: data => {
        if (!data) return
        var parts = data.trim().split("|")
        manager.playerTitle = parts[0] || ""
        manager.playerArtist = parts[1] || ""
        manager.playerName = parts[2] || ""
        
        // Length comes in microseconds, convert to seconds
        var lengthMicro = parseInt(parts[3] || "0")
        manager.playerLength = lengthMicro / 1000000.0
        
        console.log("Player metadata - Title:", manager.playerTitle, "Artist:", manager.playerArtist, "Length:", manager.playerLength)
      }
    }
  }
  
  // Get current position
  Process {
    id: playerPositionProcess
    command: ["playerctl", "position"]
    
    stdout: SplitParser {
      onRead: data => {
        if (!data) return
        var pos = parseFloat(data.trim())
        if (!isNaN(pos)) {
          manager.playerPosition = pos
        }
      }
    }
  }
  
  // Timer to poll player status (every 2 seconds)
  Timer {
    interval: 2000
    running: true
    repeat: true
    onTriggered: {
      if (!playerStatusProcess.running) {
        playerStatusProcess.running = true
      }
    }
  }
  
  // Timer to update position more frequently when playing (every 1 second)
  Timer {
    interval: 1000
    running: manager.playerPlaying
    repeat: true
    onTriggered: {
      if (!playerPositionProcess.running) {
        playerPositionProcess.running = true
      }
    }
  }
  
  // ========== MEDIA PLAYER CONTROLS ==========
  function playerPlayPause() {
    console.log("=== PLAY/PAUSE ===")
    var proc = Qt.createQmlObject('import Quickshell.Io; Process { command: ["playerctl", "play-pause"] }', manager)
    proc.running = true
    proc.exited.connect(() => {
      console.log("Play/pause command sent")
      proc.destroy()
      // Force update status
      playerStatusProcess.running = true
    })
  }
  
  function playerNext() {
    console.log("=== NEXT TRACK ===")
    var proc = Qt.createQmlObject('import Quickshell.Io; Process { command: ["playerctl", "next"] }', manager)
    proc.running = true
    proc.exited.connect(() => {
      console.log("Next command sent")
      proc.destroy()
      // Small delay before updating to let player switch
      Qt.callLater(() => playerStatusProcess.running = true)
    })
  }
  
  function playerPrevious() {
    console.log("=== PREVIOUS TRACK ===")
    var proc = Qt.createQmlObject('import Quickshell.Io; Process { command: ["playerctl", "previous"] }', manager)
    proc.running = true
    proc.exited.connect(() => {
      console.log("Previous command sent")
      proc.destroy()
      // Small delay before updating to let player switch
      Qt.callLater(() => playerStatusProcess.running = true)
    })
  }
  
  function playerSeek(position) {
    console.log("=== SEEKING TO:", position, "===")
    // Update UI immediately for responsive feel
    manager.playerPosition = position
    
    var proc = Qt.createQmlObject('import Quickshell.Io; Process { command: ["playerctl", "position", "' + position + '"] }', manager)
    proc.running = true
    proc.exited.connect(() => {
      console.log("Seek command sent")
      proc.destroy()
      // Update position after seek
      Qt.callLater(() => playerPositionProcess.running = true)
    })
  }
  
  // Helper function to format time (seconds -> MM:SS)
  function formatTime(seconds) {
    if (isNaN(seconds) || seconds < 0) return "0:00"
    
    var mins = Math.floor(seconds / 60)
    var secs = Math.floor(seconds % 60)
    return mins + ":" + (secs < 10 ? "0" : "") + secs
  }
  
  // ========== UTILITIES FUNCTIONS ==========
  
  // Check service status helper
  Process {
    id: xrayStatusProcess
    command: ["systemctl", "--user", "is-active", "xray"]
    
    stdout: SplitParser {
      onRead: data => {
        var status = data.trim()
        manager.xrayActive = (status === "active")
        console.log("Xray status:", status, "Active:", manager.xrayActive)
      }
    }
    
    stderr: SplitParser {
      onRead: data => {
        manager.xrayActive = false
      }
    }
  }
  
  Process {
    id: kanataStatusProcess
    command: ["systemctl", "--user", "is-active", "kanata"]
    
    stdout: SplitParser {
      onRead: data => {
        var status = data.trim()
        manager.kanataActive = (status === "active")
        console.log("Kanata status:", status, "Active:", manager.kanataActive)
      }
    }
    
    stderr: SplitParser {
      onRead: data => {
        manager.kanataActive = false
      }
    }
  }
  
  Process {
  id: nightLightStatusProcess
  command: ["pgrep", "-x", "hyprsunset"]
  
  stdout: SplitParser {
    onRead: data => {
      // If pgrep finds the process, it returns the PID
      manager.nightLightActive = (data.trim().length > 0)
      console.log("Night Light status - Active:", manager.nightLightActive)
    }
  }
  
  onExited: code => {
    // Exit code 1 means process not found
    if (code !== 0) {
      manager.nightLightActive = false
    }
  }
  }
  
  // Timer to poll service statuses
  Timer {
    interval: 3000
    running: true
    repeat: true
    onTriggered: {
      if (!xrayStatusProcess.running) xrayStatusProcess.running = true
      if (!kanataStatusProcess.running) kanataStatusProcess.running = true
      if (!nightLightStatusProcess.running) nightLightStatusProcess.running = true
    }
  }
  
  // Xray toggle
  function toggleXray() {
    console.log("=== TOGGLING XRAY ===")
    console.log("Current state:", xrayActive)
    
    var action = xrayActive ? "stop" : "start"
    var proc = Qt.createQmlObject('import Quickshell.Io; Process { command: ["systemctl", "--user", "' + action + '", "xray"] }', manager)
    proc.running = true
    proc.exited.connect(() => {
      console.log("Xray", action, "command sent")
      proc.destroy()
      // Check status after a short delay
      Qt.callLater(() => xrayStatusProcess.running = true)
    })
  }
  
  // Kanata toggle
  function toggleKanata() {
    console.log("=== TOGGLING KANATA ===")
    console.log("Current state:", kanataActive)
    
    var action = kanataActive ? "stop" : "start"
    var proc = Qt.createQmlObject('import Quickshell.Io; Process { command: ["systemctl", "--user", "' + action + '", "kanata"] }', manager)
    proc.running = true
    proc.exited.connect(() => {
      console.log("Kanata", action, "command sent")
      proc.destroy()
      // Check status after a short delay
      Qt.callLater(() => kanataStatusProcess.running = true)
    })
  }
  
  // Night Light toggle (using hyprsunset)
  function toggleNightLight() {
    console.log("=== TOGGLING NIGHT LIGHT ===")
    console.log("Current state:", nightLightActive)

    var proc
    if (nightLightActive) {
        // Turn OFF: reset to no filter
        proc = Qt.createQmlObject('import Quickshell.Io; Process { command: ["hyprctl", "hyprsunset", "identity"] }', manager)
        console.log("Disabling night light (identity)")
    } else {
        // Turn ON: set your desired warm temperature (4000K is a good balanced value; adjust as needed)
        proc = Qt.createQmlObject('import Quickshell.Io; Process { command: ["hyprctl", "hyprsunset", "temperature", "4000"] }', manager)
        console.log("Enabling night light (4000K)")
    }

    proc.running = true
    proc.exited.connect(() => {
        console.log("hyprctl command finished with code:", proc.exitCode)
        proc.destroy()
        // Force status re-poll in case of any hiccup
        Qt.callLater(() => nightLightStatusProcess.running = true)
    })

    // Optimistically flip UI state (poll will correct if needed)
    nightLightActive = !nightLightActive
}
  
  // Color picker (using hyprpicker)
  function launchColorPicker() {
    console.log("=== LAUNCHING COLOR PICKER ===")
    var proc = Qt.createQmlObject('import Quickshell; import Quickshell.Io; Process { command: ["hyprpicker", "-a"] }', manager)
    proc.startDetached()
    console.log("Color picker launched (detached)")
    proc.destroy()
    // Close control center after launching
    manager.visible = false
  }
  
  // Screenshot (using hyprshot)
  function takeScreenshot() {
    console.log("=== TAKING SCREENSHOT ===")
    var proc = Qt.createQmlObject('import Quickshell; import Quickshell.Io; Process { command: ["hyprshot", "-m", "region"] }', manager)
    proc.startDetached()
    console.log("Screenshot tool launched (detached)")
    proc.destroy()
    // Close control center after launching
    manager.visible = false
  }
  
  // Clipboard manager (using clipse in floating terminal)
  function openClipboard() {
    console.log("=== OPENING CLIPBOARD MANAGER ===")
    var proc = Qt.createQmlObject('import Quickshell; import Quickshell.Io; Process { command: ["kitty", "--class", "floating_term_s", "-e", "clipse"] }', manager)
    proc.startDetached()
    console.log("Clipboard manager launched (detached)")
    proc.destroy()
    // Close control center after launching
    manager.visible = false
  }
  
  Component.onCompleted: {
    console.log("=== CONTROL CENTER MANAGER LOADED ===")
    
    if (audioSink) {
      volume = audioSink.volume
      console.log("Initial volume from PipeWire:", volume)
    }
    
    // Read initial brightness - first get max, then current
    brightnessMaxGetter.running = true
    
    // Get initial player status
    playerStatusProcess.running = true
    
    // Get initial utility service statuses
    xrayStatusProcess.running = true
    kanataStatusProcess.running = true
    nightLightStatusProcess.running = true
    
    console.log("Initial states:")
    console.log("  WiFi:", wifiEnabled)
    console.log("  Bluetooth:", bluetoothEnabled)
    console.log("  Recording:", isRecording)
    console.log("  Volume:", volume)
    console.log("  Brightness:", brightness)
  }
}
