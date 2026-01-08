import QtQuick
import Quickshell
import Quickshell.Io

Scope {
  id: manager
  
  // ========== WIFI STATE ==========
  property bool wifiEnabled: true
  property string wifiStatus: "Unknown"
  
  // ========== WIFI CONTROL ==========
  Process {
    id: wifiToggleProcess
    command: ["sh", "-c", ""]
  }
  
  function toggleWifi() {
    wifiEnabled = !wifiEnabled
    
    var cmd = wifiEnabled ? "nmcli radio wifi on" : "nmcli radio wifi off"
    
    wifiToggleProcess.command = ["sh", "-c", cmd]
    wifiToggleProcess.running = true
  }
}
