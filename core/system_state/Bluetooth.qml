import QtQuick
import Quickshell
import Quickshell.Io

// Bluetooth State Module
// Manages Bluetooth state and connected devices.
// Polls bluetoothctl for current state.
Scope {
  id: module
  
  // ============================================================================
  // STATE PROPERTIES
  // ============================================================================
  
  property bool enabled: false
  property bool powered: false
  property bool discovering: false
  property string adapterName: "Unknown"
  property var connectedDevices: []
  
  // Human-readable status
  readonly property string status: {
    if (!enabled) return "Off"
    if (connectedDevices.length > 0) return "Connected (" + connectedDevices.length + ")"
    if (discovering) return "Discovering"
    return "On"
  }
  
  // Icon based on state
  readonly property string icon: {
    if (!enabled) return "󰂲"
    if (connectedDevices.length > 0) return "󰂯"
    return "󰂯"
  }
  
  // ============================================================================
  // STATE CHANGE SIGNAL
  // ============================================================================
  
  // Emitted when Bluetooth state changes
  signal stateChanged()
  
  // ============================================================================
  // STATE POLLING
  // ============================================================================
  
  Process {
    id: bluetoothStatusProcess
    command: ["sh", "-c", "bluetoothctl show | grep -E '(Powered|Discovering)'"]
    
    stdout: SplitParser {
      onRead: data => {
        if (!data) return
        
        var lines = data.trim().split('\n')
        var oldEnabled = module.enabled
        
        for (var i = 0; i < lines.length; i++) {
          var line = lines[i].trim()
          
          if (line.includes("Powered:")) {
            module.powered = line.includes("yes")
            module.enabled = module.powered
          } else if (line.includes("Discovering:")) {
            module.discovering = line.includes("yes")
          }
        }
        
        // Emit signal if state changed
        if (oldEnabled !== module.enabled) {
          module.stateChanged()
        }
        
        bluetoothStatusProcess.running = false
      }
    }
    
    stderr: SplitParser {
      onRead: data => {
        // Bluetooth might not be available, that's okay
        bluetoothStatusProcess.running = false
      }
    }
  }
  
  // Get connected devices
  Process {
    id: bluetoothDevicesProcess
    command: ["sh", "-c", "bluetoothctl devices Connected | cut -d ' ' -f 3-"]
    
    stdout: SplitParser {
      onRead: data => {
        if (!data) {
          module.connectedDevices = []
          bluetoothDevicesProcess.running = false
          return
        }
        
        var devices = data.trim().split('\n').filter(function(d) {
          return d.length > 0
        })
        
        module.connectedDevices = devices
        bluetoothDevicesProcess.running = false
      }
    }
    
    stderr: SplitParser {
      onRead: data => {
        module.connectedDevices = []
        bluetoothDevicesProcess.running = false
      }
    }
  }
  
  // Poll timer
  Timer {
    interval: 3000
    running: true
    repeat: true
    onTriggered: {
      if (!bluetoothStatusProcess.running) {
        bluetoothStatusProcess.running = true
      }
      if (!bluetoothDevicesProcess.running) {
        bluetoothDevicesProcess.running = true
      }
    }
  }
  
  // ============================================================================
  // PUBLIC FUNCTIONS
  // ============================================================================
  
  // Enable Bluetooth
  function enable() {
    var proc = Qt.createQmlObject(
      'import Quickshell.Io; Process { command: ["bluetoothctl", "power", "on"] }',
      module
    )
    
    proc.exited.connect(code => {
      proc.destroy()
      // Force immediate status update
      Qt.callLater(() => {
        bluetoothStatusProcess.running = true
      })
    })
    
    proc.running = true
  }
  
  // Disable Bluetooth
  function disable() {
    var proc = Qt.createQmlObject(
      'import Quickshell.Io; Process { command: ["bluetoothctl", "power", "off"] }',
      module
    )
    
    proc.exited.connect(code => {
      proc.destroy()
      // Force immediate status update
      Qt.callLater(() => {
        bluetoothStatusProcess.running = true
      })
    })
    
    proc.running = true
  }
  
  // Toggle Bluetooth state
  function toggle() {
    if (enabled) {
      disable()
    } else {
      enable()
    }
  }
  
  // Start device discovery
  function startDiscovery() {
    var proc = Qt.createQmlObject(
      'import Quickshell.Io; Process { command: ["bluetoothctl", "scan", "on"] }',
      module
    )
    proc.startDetached()
    proc.destroy()
  }
  
  // Stop device discovery
  function stopDiscovery() {
    var proc = Qt.createQmlObject(
      'import Quickshell.Io; Process { command: ["bluetoothctl", "scan", "off"] }',
      module
    )
    proc.startDetached()
    proc.destroy()
  }
  
  // ============================================================================
  // INITIALIZATION
  // ============================================================================
  
  Component.onCompleted: {
    // Get initial status
    bluetoothStatusProcess.running = true
    bluetoothDevicesProcess.running = true
  }
}
