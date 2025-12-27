import QtQuick
import Quickshell
import Quickshell.Io

Scope {
  id: manager
  
  // Current state
  property bool visible: false
  property string searchText: ""
  
  onVisibleChanged: {
    console.log("=== LAUNCHER VISIBILITY CHANGED ===")
    console.log("Visible:", visible)
    if (visible) {
      console.log("Launcher opened!")
      searchText = "" // Reset search when opening
    } else {
      console.log("Launcher closed!")
    }
  }
  
  onSearchTextChanged: {
    console.log("Search text changed:", searchText)
  }
  
  // IPC Handler - allows external control via command line
  IpcHandler {
    target: "launcher"
    
    function toggle(): void {
      console.log("=== IPC TOGGLE CALLED ===")
      manager.visible = !manager.visible
      console.log("New visible state:", manager.visible)
    }
    
    function open(): void {
      console.log("=== IPC OPEN CALLED ===")
      manager.visible = true
    }
    
    function close(): void {
      console.log("=== IPC CLOSE CALLED ===")
      manager.visible = false
    }
  }
  
  Component.onCompleted: {
    console.log("=== LAUNCHER MANAGER LOADED ===")
    console.log("IPC target 'launcher' registered")
    console.log("Available commands:")
    console.log("  - qs ipc call launcher toggle")
    console.log("  - qs ipc call launcher open")
    console.log("  - qs ipc call launcher close")
  }
}
