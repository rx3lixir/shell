import QtQuick
import Quickshell
import Quickshell.Io

Scope {
  id: manager
  
  // Visibility state
  property bool visible: false
  
  // Search text
  property string searchText: ""
  
  // Reference to launcher manager (for the Applications item)
  required property var launcherManager
  
  onVisibleChanged: {
    console.log("=== MENU VISIBILITY CHANGED ===")
    console.log("Visible:", visible)
    if (visible) {
      searchText = "" // Reset search when opening
    }
  }
  
  onSearchTextChanged: {
    console.log("Menu search text changed:", searchText)
  }
  
  // Define our menu items
  property var menuItems: [
    {
      icon: "󰂯",
      name: "Bluetooth",
      description: "Manage Bluetooth devices",
      command: "kitty --class floating_term_s -e bluetui"
    },
    {
      icon: "󰤥",
      name: "WiFi",
      description: "Manage WiFi connections",
      command: "kitty --class floating_term_m -e impala"
    },
    {
      icon: "󱡫",
      name: "Audio",
      description: "Audio mixer and settings",
      command: "kitty --class floating_term_s -e wiremix"
    },
    {
      icon: "",
      name: "Applications",
      description: "Launch applications",
      command: "launcher"  // Special command to trigger launcher
    },
    {
      icon: "",
      name: "Files",
      description: "Browse files with Yazi",
      command: "kitty --class floating_term_l -e yazi"
    },
    {
      icon: "󱙣",
      name: "System Monitor",
      description: "View system resources",
      command: "kitty --class floating_term_l -e btop"
    }
  ]
  
  // Execute a menu item's command
  function executeItem(item) {
    console.log("=== EXECUTING MENU ITEM ===")
    console.log("Name:", item.name)
    console.log("Command:", item.command)
    
    // Special case: Applications opens the launcher
    if (item.command === "launcher") {
      console.log("Opening launcher...")
      manager.visible = false
      launcherManager.visible = true
      return
    }
    
    // For everything else, use execDetached
    try {
      console.log("Executing command:", item.command)
      Quickshell.execDetached({
        command: ["sh", "-c", item.command]
      })
      console.log("Command executed successfully!")
      manager.visible = false
    } catch (error) {
      console.error("Failed to execute command:", error)
    }
  }
  
  // IPC Handler for external control
  IpcHandler {
    target: "menu"
    
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
    console.log("=== MENU MANAGER LOADED ===")
    console.log("IPC target 'menu' registered")
    console.log("Available commands:")
    console.log("  - qs ipc call menu toggle")
    console.log("  - qs ipc call menu open")
    console.log("  - qs ipc call menu close")
    console.log("Menu items:", menuItems.length)
  }
}
