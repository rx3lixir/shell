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
    
    onExited: code => {
      console.log("WiFi toggle process exited with code:", code)
    }
  }
  
  function toggleWifi() {
    console.log("=== TOGGLING WIFI ===")
    console.log("Current state:", wifiEnabled)
    
    wifiEnabled = !wifiEnabled
    console.log("New state:", wifiEnabled)
    
    var cmd = wifiEnabled ? "nmcli radio wifi on" : "nmcli radio wifi off"
    console.log("Running command:", cmd)
    
    wifiToggleProcess.command = ["sh", "-c", cmd]
    wifiToggleProcess.running = true
  }
  
  // ========== BLUETOOTH CONTROL ==========
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
    
    bluetoothEnabled = !bluetoothEnabled
    console.log("New state:", bluetoothEnabled)
    
    var cmd = bluetoothEnabled ? "bluetoothctl power on" : "bluetoothctl power off"
    console.log("Running command:", cmd)
    
    bluetoothToggleProcess.command = ["sh", "-c", cmd]
    bluetoothToggleProcess.running = true
  }
  
  Component.onCompleted: {
    console.log("=== NETWORK MANAGER LOADED ===")
    console.log("Initial WiFi state:", wifiEnabled)
    console.log("Initial Bluetooth state:", bluetoothEnabled)
  }
}
