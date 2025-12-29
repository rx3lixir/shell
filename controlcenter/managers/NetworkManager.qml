import QtQuick
import Quickshell
import Quickshell.Io

Scope {
  id: manager
  
  // ========== WIFI STATE ==========
  property bool wifiEnabled: true
  property string wifiStatus: "Unknown"
  
  // ========== BLUETOOTH STATE ==========
  property bool bluetoothEnabled: false
  property string bluetoothStatus: "Off"
  
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
  
  // ========== BLUETOOTH CONTROL ==========
  Process {
    id: bluetoothToggleProcess
    command: ["sh", "-c", ""]
  }
  
  function toggleBluetooth() {
    bluetoothEnabled = !bluetoothEnabled

    var cmd = bluetoothEnabled ? "bluetoothctl power on" : "bluetoothctl power off"
    
    bluetoothToggleProcess.command = ["sh", "-c", cmd]
    bluetoothToggleProcess.running = true
  }
}
