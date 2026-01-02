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
  
  // Reference to wallpaper manager (for the Wallpapers item)
  required property var wallpaperManager
  
  // Reference to power menu manager (for the Power item)
  required property var powerMenuManager
  
  onVisibleChanged: {
    if (visible) {
      searchText = "" // Reset search when opening
    }
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
      icon: "",
      name: "Applications",
      description: "Launch applications",
      command: "launcher"  // Special command to trigger launcher
    },
    {
      icon: "󰸉",
      name: "Wallpapers",
      description: "Change wallpaper",
      command: "wallpapers"  // Special command to trigger wallpaper picker
    },
    {
      icon: "󰐥",
      name: "Power",
      description: "Shutdown, reboot, logout...",
      command: "power"  // Special command to trigger power menu
    },
    {
      icon: "",
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
    console.log("[MenuManager] Executing item:", item.name, "command:", item.command)
    
    // Special case: Applications opens the launcher
    if (item.command === "launcher") {
      manager.visible = false
      launcherManager.visible = true
      return
    }
    
    // Special case: Wallpapers opens the wallpaper picker
    if (item.command === "wallpapers") {
      console.log("[MenuManager] Opening wallpaper picker")
      manager.visible = false
      wallpaperManager.visible = true
      return
    }
    
    // Special case: Power opens the power menu
    if (item.command === "power") {
      console.log("[MenuManager] Opening power menu")
      manager.visible = false
      powerMenuManager.visible = true
      return
    }
    
    // For everything else, use execDetached
    try {
      Quickshell.execDetached({
        command: ["sh", "-c", item.command]
      })
      manager.visible = false
    } catch (error) {
      console.error("[MenuManager] Failed to execute command:", error)
    }
  }
  
  // IPC Handler for external control
  IpcHandler {
    target: "menu"
    
    function toggle(): void {
      manager.visible = !manager.visible
    }
    
    function open(): void {
      manager.visible = true
    }
    
    function close(): void {
      manager.visible = false
    }
  }
}
