import QtQuick
import Quickshell
import Quickshell.Io

Scope {
  id: manager
  
  // ========== UTILITIES STATE ==========
  property bool xrayActive: false
  property bool kanataActive: false
  property bool nightLightActive: false
  
  // ========== SERVICE STATUS CHECKERS ==========
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
  
  // ========== POLLING TIMER ==========
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
  
  // ========== XRAY TOGGLE ==========
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
  
  // ========== KANATA TOGGLE ==========
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
  
  // ========== NIGHT LIGHT TOGGLE ==========
  function toggleNightLight() {
    console.log("=== TOGGLING NIGHT LIGHT ===")
    console.log("Current state:", nightLightActive)

    var proc
    if (nightLightActive) {
      // Turn OFF: reset to no filter
      proc = Qt.createQmlObject('import Quickshell.Io; Process { command: ["hyprctl", "hyprsunset", "identity"] }', manager)
      console.log("Disabling night light (identity)")
    } else {
      // Turn ON: set your desired warm temperature (4000K)
      proc = Qt.createQmlObject('import Quickshell.Io; Process { command: ["hyprctl", "hyprsunset", "temperature", "4000"] }', manager)
      console.log("Enabling night light (4000K)")
    }

    proc.running = true
    proc.exited.connect(() => {
      console.log("hyprctl command finished with code:", proc.exitCode)
      proc.destroy()
      // Force status re-poll
      Qt.callLater(() => nightLightStatusProcess.running = true)
    })

    // Optimistically flip UI state (poll will correct if needed)
    nightLightActive = !nightLightActive
  }
  
  // ========== LAUNCHER FUNCTIONS ==========
  function launchColorPicker() {
    console.log("=== LAUNCHING COLOR PICKER ===")
    var proc = Qt.createQmlObject('import Quickshell; import Quickshell.Io; Process { command: ["hyprpicker", "-a"] }', manager)
    proc.startDetached()
    console.log("Color picker launched (detached)")
    proc.destroy()
  }
  
  function takeScreenshot() {
    console.log("=== TAKING SCREENSHOT ===")
    var proc = Qt.createQmlObject('import Quickshell; import Quickshell.Io; Process { command: ["hyprshot", "-m", "region"] }', manager)
    proc.startDetached()
    console.log("Screenshot tool launched (detached)")
    proc.destroy()
  }
  
  function openClipboard() {
    console.log("=== OPENING CLIPBOARD MANAGER ===")
    var proc = Qt.createQmlObject('import Quickshell; import Quickshell.Io; Process { command: ["kitty", "--class", "floating_term_s", "-e", "clipse"] }', manager)
    proc.startDetached()
    console.log("Clipboard manager launched (detached)")
    proc.destroy()
  }
  
  Component.onCompleted: {
    console.log("=== UTILITIES MANAGER LOADED ===")
    // Get initial utility service statuses
    xrayStatusProcess.running = true
    kanataStatusProcess.running = true
    nightLightStatusProcess.running = true
  }
}
