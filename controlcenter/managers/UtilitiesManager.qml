import QtQuick
import Quickshell
import Quickshell.Io

Scope {
  id: manager
  
  // ========== NIGHT LIGHT STATE ==========
  property bool nightLightActive: false
  
  // ========== CHECK NIGHT LIGHT STATUS ==========
  Process {
    id: nightLightCheckProcess
    command: ["pgrep", "-x", "hyprsunset"]
    
    onExited: code => {
      // Exit code 0 means process found (night light is on)
      // Exit code 1 means process not found (night light is off)
      manager.nightLightActive = (code === 0)
    }
    
    stderr: SplitParser {
      onRead: data => {
        // Ignore stderr, pgrep sometimes complains
      }
    }
  }
  
  // Timer to periodically check night light state
  Timer {
    interval: 2000  // Check every 2 seconds
    running: true
    repeat: true
    onTriggered: {
      if (!nightLightCheckProcess.running) {
        nightLightCheckProcess.running = true
      }
    }
  }
  
  // ========== TOGGLE NIGHT LIGHT ==========
  function toggleNightLight() {
    console.log("Toggling night light, current state:", manager.nightLightActive)
    
    // Create a process to run your script
    var proc = Qt.createQmlObject(
      'import Quickshell; import Quickshell.Io; Process { command: ["night-mode"] }',
      manager
    )
    
    proc.exited.connect(code => {
      console.log("night-mode script exited with code:", code)
      proc.destroy()
      
      // Force immediate state check after toggle
      Qt.callLater(() => {
        nightLightCheckProcess.running = true
      })
    })
    
    proc.running = true
  }
  
  // ========== LAUNCHER FUNCTIONS ==========
  function launchColorPicker() {
    var proc = Qt.createQmlObject('import Quickshell; import Quickshell.Io; Process { command: ["hyprpicker", "-a"] }', manager)
    proc.startDetached()
    proc.destroy()
  }
  
  function takeScreenshot() {
    var proc = Qt.createQmlObject('import Quickshell; import Quickshell.Io; Process { command: ["hyprshot", "-m", "region"] }', manager)
    proc.startDetached()
    proc.destroy()
  }
  
  function openClipboard() {
    var proc = Qt.createQmlObject('import Quickshell; import Quickshell.Io; Process { command: ["kitty", "--class", "floating_term_s", "-e", "clipse"] }', manager)
    proc.startDetached()
    proc.destroy()
  }
  
  // ========== INITIALIZATION ==========
  Component.onCompleted: {
    // Check initial night light state
    nightLightCheckProcess.running = true
  }
}
