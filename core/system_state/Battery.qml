import QtQuick
import Quickshell
import Quickshell.Io

// Battery State Module
// Manages battery state information.
// Reads from /sys/class/power_supply/BAT* for battery info.
Scope {
  id: module
  
  // ============================================================================
  // STATE PROPERTIES
  // ============================================================================
  
  property bool present: false
  property int percentage: 0  // 0-100
  property string status: "Unknown"  // Charging, Discharging, Full, Not charging
  property bool charging: false
  property int timeToEmpty: -1  // minutes, -1 if not available
  property int timeToFull: -1   // minutes, -1 if not available
  
  // Capacity and health
  property int capacity: 100  // Design capacity percentage
  property int cycleCount: 0
  
  // Power information
  property real powerNow: 0  // Current power draw/charge in watts
  property real voltage: 0   // Current voltage
  
  // ============================================================================
  // COMPUTED PROPERTIES
  // ============================================================================
  
  // Icon based on charging state and percentage
  readonly property string icon: {
    if (!present) return "󰂑"
    
    if (charging) {
      if (percentage >= 90) return "󰂅"
      if (percentage >= 80) return "󰂋"
      if (percentage >= 60) return "󰂊"
      if (percentage >= 40) return "󰢞"
      if (percentage >= 20) return "󰢜"
      return "󰢟"
    } else {
      if (percentage >= 90) return "󰁹"
      if (percentage >= 80) return "󰂂"
      if (percentage >= 70) return "󰂁"
      if (percentage >= 60) return "󰂀"
      if (percentage >= 50) return "󰁿"
      if (percentage >= 40) return "󰁾"
      if (percentage >= 30) return "󰁽"
      if (percentage >= 20) return "󰁼"
      if (percentage >= 10) return "󰁻"
      return "󰂎"  // Low battery
    }
  }
  
  // Human-readable status text
  readonly property string statusText: {
    if (!present) return "No battery"
    
    var text = percentage + "%"
    
    if (charging) {
      text += " • Charging"
      if (timeToFull > 0) {
        var hours = Math.floor(timeToFull / 60)
        var mins = timeToFull % 60
        text += " (" + hours + "h " + mins + "m)"
      }
    } else if (status === "Full") {
      text += " • Full"
    } else {
      if (timeToEmpty > 0) {
        var hours = Math.floor(timeToEmpty / 60)
        var mins = timeToEmpty % 60
        text += " • " + hours + "h " + mins + "m left"
      }
    }
    
    return text
  }
  
  // Battery level category
  readonly property string level: {
    if (percentage >= 80) return "high"
    if (percentage >= 50) return "medium"
    if (percentage >= 20) return "low"
    return "critical"
  }
  
  // ============================================================================
  // STATE CHANGE SIGNAL
  // ============================================================================
  
  // Emitted when battery state changes significantly
  signal stateChanged()
  signal batteryLow()  // Emitted when battery drops below 20%
  signal batteryCritical()  // Emitted when battery drops below 10%
  
  // ============================================================================
  // BATTERY PATH DETECTION
  // ============================================================================
  
  property string batteryPath: ""
  
  Process {
    id: batteryPathDetector
    command: ["sh", "-c", "ls /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -n1 | xargs dirname"]
    
    stdout: SplitParser {
      onRead: data => {
        if (!data) {
          module.present = false
          batteryPathDetector.running = false
          return
        }
        
        var path = data.trim()
        if (path) {
          module.batteryPath = path
          module.present = true
          // Start reading battery info
          batteryInfoProcess.running = true
        } else {
          module.present = false
        }
        
        batteryPathDetector.running = false
      }
    }
    
    stderr: SplitParser {
      onRead: data => {
        module.present = false
        batteryPathDetector.running = false
      }
    }
  }
  
  // ============================================================================
  // BATTERY INFO READER
  // ============================================================================
  
  Process {
    id: batteryInfoProcess
    command: ["sh", "-c", ""]
    
    stdout: SplitParser {
      onRead: data => {
        if (!data) return
        
        var lines = data.trim().split('\n')
        var oldPercentage = module.percentage
        var oldCharging = module.charging
        
        for (var i = 0; i < lines.length; i++) {
          var line = lines[i]
          var parts = line.split('=')
          if (parts.length !== 2) continue
          
          var key = parts[0].trim()
          var value = parts[1].trim()
          
          switch(key) {
            case "capacity":
              module.percentage = parseInt(value) || 0
              break
            case "status":
              module.status = value
              module.charging = (value === "Charging")
              break
            case "capacity_level":
              // Some systems report level instead of percentage
              break
            case "power_now":
              module.powerNow = parseInt(value) / 1000000.0  // Convert to watts
              break
            case "voltage_now":
              module.voltage = parseInt(value) / 1000000.0  // Convert to volts
              break
            case "cycle_count":
              module.cycleCount = parseInt(value) || 0
              break
          }
        }
        
        // Emit signals if state changed
        if (oldPercentage !== module.percentage || oldCharging !== module.charging) {
          module.stateChanged()
        }
        
        // Check for low battery
        if (module.percentage <= 10 && oldPercentage > 10) {
          module.batteryCritical()
        } else if (module.percentage <= 20 && oldPercentage > 20) {
          module.batteryLow()
        }
        
        batteryInfoProcess.running = false
      }
    }
    
    stderr: SplitParser {
      onRead: data => {
        batteryInfoProcess.running = false
      }
    }
  }
  
  // ============================================================================
  // POLLING
  // ============================================================================
  
  Timer {
    interval: 2000
    running: module.present
    repeat: true
    onTriggered: {
      if (!batteryInfoProcess.running && module.batteryPath) {
        var cmd = "cat " + module.batteryPath + "/capacity " +
                  module.batteryPath + "/status " +
                  module.batteryPath + "/power_now " +
                  module.batteryPath + "/voltage_now " +
                  module.batteryPath + "/cycle_count 2>/dev/null | " +
                  "awk 'NR==1{print \"capacity=\"$0} NR==2{print \"status=\"$0} " +
                  "NR==3{print \"power_now=\"$0} NR==4{print \"voltage_now=\"$0} " +
                  "NR==5{print \"cycle_count=\"$0}'"
        
        batteryInfoProcess.command = ["sh", "-c", cmd]
        batteryInfoProcess.running = true
      }
    }
  }
  
  // ============================================================================
  // INITIALIZATION
  // ============================================================================
  
  Component.onCompleted: {
    // Detect battery path
    batteryPathDetector.running = true
  }
}
