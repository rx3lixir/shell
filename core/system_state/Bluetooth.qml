import QtQuick
import Quickshell
import Quickshell.Io

// Bluetooth State Module
// Manages Bluetooth state using bluetoothctl.
// Monitors power state, connected devices, and provides control functions.
Scope {
  id: module
  
  // ============================================================================
  // DEPENDENCIES
  // ============================================================================
  
  // Set by parent when user is interacting with controls
  // Prevents external change signals during user interaction
  property bool userInteracting: false
  
  // ============================================================================
  // STATE PROPERTIES
  // ============================================================================
  
  // Whether Bluetooth is powered on
  property bool powered: false
  
  // Whether any device is connected
  property bool hasConnectedDevice: false
  
  // Name of the first connected device (or empty string)
  property string connectedDeviceName: ""
  
  // Number of connected devices
  property int connectedDeviceCount: 0
  
  // List of all connected devices (array of {name, address, icon})
  property var connectedDevices: []
  
  // Whether the module is ready (initial state loaded)
  property bool ready: false
  
  // Track if we're changing state programmatically
  property bool changingState: false
  
  // ============================================================================
  // EXTERNAL CHANGE SIGNAL (for OSD)
  // ============================================================================
  
  // Emitted when Bluetooth state changes from an EXTERNAL source
  // (e.g., hardware button, other application)
  // NOT emitted during user interaction or programmatic changes
  signal bluetoothChangedExternally(bool powered, bool hasDevice, string deviceName)
  
  // ============================================================================
  // BLUETOOTH STATE READER
  // ============================================================================
  
  Process {
    id: bluetoothStateProcess
    command: ["sh", "-c", `
      # Get bluetooth power state
      POWERED=$(bluetoothctl show 2>/dev/null | grep 'Powered:' | awk '{print $2}')
      
      # If not powered, return early
      if [ "$POWERED" != "yes" ]; then
        echo "OFF|0|"
        exit 0
      fi
      
      # Get connected devices
      CONNECTED=$(bluetoothctl devices Connected 2>/dev/null)
      
      # Count connected devices
      COUNT=$(echo "$CONNECTED" | grep -c "Device" || echo "0")
      
      # Get device names (one per line)
      NAMES=""
      if [ ! -z "$CONNECTED" ]; then
        NAMES=$(echo "$CONNECTED" | cut -d' ' -f3- | tr '\n' '|')
      fi
      
      echo "ON|$COUNT|$NAMES"
    `]
    
    stdout: SplitParser {
      onRead: data => {
        if (!data) return
        
        var line = data.trim()
        var parts = line.split("|")
        
        if (parts.length < 2) return
        
        var wasPowered = module.powered
        var hadDevice = module.hasConnectedDevice
        var oldDeviceName = module.connectedDeviceName
        
        // Parse power state
        module.powered = (parts[0] === "ON")
        
        // Parse device count
        var deviceCount = parseInt(parts[1]) || 0
        module.connectedDeviceCount = deviceCount
        module.hasConnectedDevice = deviceCount > 0
        
        // Parse device names
        if (parts.length > 2 && parts[2]) {
          var names = parts[2].split("|").filter(function(name) {
            return name.trim().length > 0
          })
          
          module.connectedDeviceName = names.length > 0 ? names[0] : ""
          
          // Build connected devices array
          var devices = []
          for (var i = 0; i < names.length; i++) {
            if (names[i].trim()) {
              devices.push({
                name: names[i].trim(),
                address: "",  // We don't parse address in the simple script
                icon: "󰂯"
              })
            }
          }
          module.connectedDevices = devices
        } else {
          module.connectedDeviceName = ""
          module.connectedDevices = []
        }
        
        module.ready = true
        
        // Emit external change signal if:
        // 1. We're not changing it programmatically
        // 2. User is not interacting
        // 3. State actually changed
        if (!module.changingState && !module.userInteracting) {
          var stateChanged = (wasPowered !== module.powered) || 
                            (hadDevice !== module.hasConnectedDevice) ||
                            (oldDeviceName !== module.connectedDeviceName)
          
          if (stateChanged) {
            module.bluetoothChangedExternally(
              module.powered,
              module.hasConnectedDevice,
              module.connectedDeviceName
            )
          }
        }
      }
    }
    
    stderr: SplitParser {
      onRead: data => {
        // Ignore stderr from bluetoothctl
      }
    }
  }
  
  // Timer to poll Bluetooth state
  Timer {
    id: pollTimer
    interval: 2000  // Poll every 2 seconds
    running: true
    repeat: true
    
    onTriggered: {
      if (!bluetoothStateProcess.running) {
        bluetoothStateProcess.running = true
      }
    }
  }
  
  // Timer to reset the changing flag
  Timer {
    id: stateChangeResetTimer
    interval: 500
    onTriggered: {
      module.changingState = false
    }
  }
  
  // ============================================================================
  // PUBLIC FUNCTIONS - Bluetooth Control
  // ============================================================================
  
  // Toggle Bluetooth power
  function togglePower() {
    setPower(!powered)
  }
  
  // Set Bluetooth power state
  // @param enabled - true to power on, false to power off
  function setPower(enabled) {
    // Mark that we're changing state (prevents OSD)
    changingState = true
    stateChangeResetTimer.restart()
    
    // Update our property immediately for responsive UI
    powered = enabled
    
    // Execute bluetoothctl command
    var command = enabled ? "bluetoothctl power on" : "bluetoothctl power off"
    
    var proc = Qt.createQmlObject(
      'import Quickshell.Io; Process { command: ["sh", "-c", "' + command + '"] }',
      module
    )
    
    proc.exited.connect(function(code) {
      proc.destroy()
      // Force a state refresh after change
      Qt.callLater(function() {
        if (!bluetoothStateProcess.running) {
          bluetoothStateProcess.running = true
        }
      })
    })
    
    proc.running = true
  }
  
  // Connect to a device by address
  // @param address - MAC address of the device
  function connectDevice(address) {
    if (!address) {
      console.error("[Bluetooth] No device address provided")
      return
    }
    
    changingState = true
    stateChangeResetTimer.restart()
    
    var proc = Qt.createQmlObject(
      'import Quickshell.Io; Process { command: ["bluetoothctl", "connect", "' + address + '"] }',
      module
    )
    
    proc.exited.connect(function(code) {
      proc.destroy()
      Qt.callLater(function() {
        if (!bluetoothStateProcess.running) {
          bluetoothStateProcess.running = true
        }
      })
    })
    
    proc.running = true
  }
  
  // Disconnect from a device by address
  // @param address - MAC address of the device
  function disconnectDevice(address) {
    if (!address) {
      console.error("[Bluetooth] No device address provided")
      return
    }
    
    changingState = true
    stateChangeResetTimer.restart()
    
    var proc = Qt.createQmlObject(
      'import Quickshell.Io; Process { command: ["bluetoothctl", "disconnect", "' + address + '"] }',
      module
    )
    
    proc.exited.connect(function(code) {
      proc.destroy()
      Qt.callLater(function() {
        if (!bluetoothStateProcess.running) {
          bluetoothStateProcess.running = true
        }
      })
    })
    
    proc.running = true
  }
  
  // Open Bluetooth manager UI
  function openManager() {
    var proc = Qt.createQmlObject(
      'import Quickshell.Io; Process { command: ["kitty", "--class", "floating_term_s", "-e", "bluetui"] }',
      module
    )
    
    proc.startDetached()
    proc.destroy()
  }
  
  // ============================================================================
  // UTILITY FUNCTIONS
  // ============================================================================
  
  // Get Bluetooth icon based on state
  function getBluetoothIcon(powered, hasDevice) {
    if (!powered) return "󰂲"  // Bluetooth off
    if (hasDevice) return "󰂯"  // Bluetooth connected
    return "󰂯"                  // Bluetooth on but not connected
  }
  
  // Get status text for display
  function getStatusText() {
    if (!powered) return "Off"
    if (!hasConnectedDevice) return "On"
    if (connectedDeviceCount === 1) return connectedDeviceName
    return connectedDeviceCount + " devices"
  }
  
  // Get detailed status text
  function getDetailedStatus() {
    if (!powered) return "Bluetooth is off"
    if (!hasConnectedDevice) return "No devices connected"
    if (connectedDeviceCount === 1) return "Connected to " + connectedDeviceName
    return connectedDeviceCount + " devices connected"
  }
  
  // ============================================================================
  // INITIALIZATION
  // ============================================================================
  
  Component.onCompleted: {
    console.log("[Bluetooth] Module initialized")
    // Initial state read
    bluetoothStateProcess.running = true
  }
}
