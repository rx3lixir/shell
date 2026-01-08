import QtQuick
import Quickshell
import Quickshell.Io

// Network State Module - Following Bluetooth Pattern
// Manages WiFi and network connection state using direct nmcli commands.
// Monitors both programmatic and external changes.
Scope {
  id: module
  
  // ============================================================================
  // DEPENDENCIES
  // ============================================================================
  
  property bool userInteracting: false
  
  // ============================================================================
  // STATE PROPERTIES
  // ============================================================================
  
  property bool wifiEnabled: false
  property bool wifiConnected: false
  property string wifiSsid: ""
  property int wifiSignalStrength: 0  // 0-100
  property string connectionType: "unknown"  // "wifi", "ethernet", "none", "unknown"
  property string interfaceName: ""
  property bool ready: false
  property bool changingState: false
  
  // ============================================================================
  // EXTERNAL CHANGE SIGNAL
  // ============================================================================
  
  signal networkChangedExternally(bool wifiEnabled, bool wifiConnected, string ssid)
  
  // ============================================================================
  // WIFI RADIO STATE READER
  // ============================================================================
  
  Process {
    id: wifiRadioProcess
    command: ["sh", "-c", "nmcli radio wifi 2>/dev/null"]
    
    stdout: SplitParser {
      onRead: data => {
        if (!data) {
          console.log("[Network] No output from nmcli radio")
          return
        }
        
        var state = data.trim().toLowerCase()
        var wasEnabled = module.wifiEnabled
        
        console.log("[Network] WiFi radio state raw:", data.trim())
        
        module.wifiEnabled = (state === "enabled")
        
        console.log("[Network] WiFi enabled:", module.wifiEnabled)
        
        // If WiFi is enabled, check connections
        if (module.wifiEnabled) {
          activeConnectionProcess.running = true
        } else {
          module.wifiConnected = false
          module.wifiSsid = ""
          module.wifiSignalStrength = 0
          module.connectionType = "none"
          module.interfaceName = ""
        }
        
        module.ready = true
        
        // Emit change if needed
        if (!module.changingState && !module.userInteracting && wasEnabled !== module.wifiEnabled) {
          console.log("[Network] WiFi state changed externally")
          module.networkChangedExternally(module.wifiEnabled, module.wifiConnected, module.wifiSsid)
        }
      }
    }
    
    stderr: SplitParser {
      onRead: data => {
        if (data && data.trim()) {
          console.error("[Network] Error checking WiFi radio:", data.trim())
        }
      }
    }
  }
  
  // ============================================================================
  // ACTIVE CONNECTION CHECKER
  // ============================================================================
  
  Process {
    id: activeConnectionProcess
    command: ["sh", "-c", "nmcli -t -f TYPE,STATE,DEVICE connection show --active 2>/dev/null"]
    
    stdout: SplitParser {
      onRead: data => {
        if (!data || !data.trim()) {
          console.log("[Network] No active connections")
          module.wifiConnected = false
          module.connectionType = "none"
          module.interfaceName = ""
          module.wifiSsid = ""
          module.wifiSignalStrength = 0
          return
        }
        
        var lines = data.trim().split('\n')
        var foundWifi = false
        var foundEthernet = false
        
        console.log("[Network] Active connections:", lines.length)
        
        for (var i = 0; i < lines.length; i++) {
          var parts = lines[i].split(':')
          if (parts.length >= 3) {
            var type = parts[0]
            var state = parts[1]
            var device = parts[2]
            
            console.log("[Network] Connection:", type, state, device)
            
            if (state === "activated") {
              if (type === "802-11-wireless" || type === "wifi") {
                foundWifi = true
                module.connectionType = "wifi"
                module.interfaceName = device
                module.wifiConnected = true
                // Get WiFi details
                wifiDetailsProcess.running = true
              } else if (type === "802-3-ethernet" || type === "ethernet") {
                foundEthernet = true
                if (!foundWifi) {  // Prefer showing WiFi if both are active
                  module.connectionType = "ethernet"
                  module.interfaceName = device
                  module.wifiConnected = false
                }
              }
            }
          }
        }
        
        if (!foundWifi && !foundEthernet) {
          module.wifiConnected = false
          module.connectionType = "none"
          module.interfaceName = ""
          module.wifiSsid = ""
          module.wifiSignalStrength = 0
        }
      }
    }
    
    stderr: SplitParser {
      onRead: data => {
        if (data && data.trim()) {
          console.error("[Network] Error checking connections:", data.trim())
        }
      }
    }
  }
  
  // ============================================================================
  // WIFI DETAILS READER (SSID and Signal)
  // ============================================================================
  
  Process {
    id: wifiDetailsProcess
    command: ["sh", "-c", "nmcli -t -f ACTIVE,SSID,SIGNAL dev wifi 2>/dev/null | grep '^yes'"]
    
    stdout: SplitParser {
      onRead: data => {
        if (!data || !data.trim()) {
          console.log("[Network] No active WiFi found")
          return
        }
        
        var line = data.trim()
        var parts = line.split(":")
        
        if (parts.length >= 3) {
          // Format: yes:SSID:SIGNAL
          var oldSsid = module.wifiSsid
          
          module.wifiSsid = parts[1]
          module.wifiSignalStrength = parseInt(parts[2]) || 0
          
          console.log("[Network] WiFi SSID:", module.wifiSsid, "Signal:", module.wifiSignalStrength + "%")
          
          // Emit change if SSID changed
          if (!module.changingState && !module.userInteracting && oldSsid !== module.wifiSsid && oldSsid !== "") {
            module.networkChangedExternally(module.wifiEnabled, module.wifiConnected, module.wifiSsid)
          }
        }
      }
    }
    
    stderr: SplitParser {
      onRead: data => {
        if (data && data.trim()) {
          console.error("[Network] Error getting WiFi details:", data.trim())
        }
      }
    }
  }
  
  // ============================================================================
  // POLLING TIMER
  // ============================================================================
  
  Timer {
    interval: 2000
    running: true
    repeat: true
    onTriggered: {
      if (!wifiRadioProcess.running) {
        wifiRadioProcess.running = true
      }
    }
  }
  
  // ============================================================================
  // STATE CHANGE RESET TIMER
  // ============================================================================
  
  Timer {
    id: stateChangeResetTimer
    interval: 500
    onTriggered: {
      module.changingState = false
    }
  }
  
  // ============================================================================
  // CONTROL FUNCTIONS
  // ============================================================================
  
  function toggleWifi() {
    setWifi(!wifiEnabled)
  }
  
  function setWifi(enabled) {
    changingState = true
    stateChangeResetTimer.restart()
    
    // Update state optimistically
    var oldEnabled = wifiEnabled
    wifiEnabled = enabled
    if (!enabled) {
      wifiConnected = false
      wifiSsid = ""
      wifiSignalStrength = 0
      connectionType = "none"
      interfaceName = ""
    }
    
    var cmd = enabled ? "nmcli radio wifi on" : "nmcli radio wifi off"
    
    var proc = Qt.createQmlObject(
      'import Quickshell.Io; Process { command: ["sh", "-c", "' + cmd + '"] }',
      module
    )
    
    proc.exited.connect(function(code) {
      console.log("[Network] WiFi toggle finished, code:", code)
      proc.destroy()
      
      // Force state refresh
      Qt.callLater(function() {
        if (!wifiRadioProcess.running) {
          wifiRadioProcess.running = true
        }
      })
    })
    
    proc.running = true
  }
  
  function openNetworkManager() {
    var proc = Qt.createQmlObject(
      'import Quickshell.Io; Process { command: ["kitty", "--class", "floating_term_m", "-e", "impala"] }',
      module
    )
    proc.startDetached()
    proc.destroy()
  }
  
  // ============================================================================
  // UTILITY FUNCTIONS
  // ============================================================================
  
  function getNetworkIcon() {
    if (connectionType === "ethernet") {
      return "󰈀"  // Ethernet icon
    } else if (connectionType === "wifi" && wifiConnected) {
      // WiFi icons based on signal strength
      if (wifiSignalStrength >= 75) return "󰤨"
      if (wifiSignalStrength >= 50) return "󰤥"
      if (wifiSignalStrength >= 25) return "󰤢"
      return "󰤟"
    } else if (!wifiEnabled) {
      return "󰤭"  // WiFi disabled
    } else {
      return "󰤮"  // Disconnected
    }
  }
  
  function getStatusText() {
    if (!wifiEnabled) return "Disabled"
    if (connectionType === "ethernet") return "Ethernet"
    if (connectionType === "wifi" && wifiConnected) {
      return wifiSsid || "Connected"
    }
    if (connectionType === "none") return "Disconnected"
    return "Unknown"
  }
  
  function getDetailedStatus() {
    if (!wifiEnabled) return "WiFi is disabled"
    if (connectionType === "ethernet") return "Connected via Ethernet"
    if (connectionType === "wifi" && wifiConnected) {
      return "Connected to " + (wifiSsid || "WiFi") + " (" + wifiSignalStrength + "%)"
    }
    if (connectionType === "none") return "No network connection"
    return "Unknown connection state"
  }
  
  // ============================================================================
  // INITIALIZATION
  // ============================================================================
  
  Component.onCompleted: {
    console.log("[Network] Module initialized")
    wifiRadioProcess.running = true
  }
}
