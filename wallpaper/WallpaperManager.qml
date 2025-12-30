import QtQuick
import Quickshell
import Quickshell.Io

Scope {
  id: manager
  
  // Visibility state
  property bool visible: false
  
  // Wallpaper directory - using StandardPaths to get home directory properly
  property string wallpaperDir: ""
  
  // Script path - you'll need to put the script somewhere in PATH or specify full path
  readonly property string switcherScript: "wallpaper-switcher"
  
  // List of wallpaper files
  property var wallpapers: []
  
  // Currently selected wallpaper (for highlighting)
  property string currentWallpaper: ""
  
  // Loading state
  property bool isLoading: false
  property string errorMessage: ""
  
  // Initialize wallpaper directory on component creation
  Component.onCompleted: {
    // Get HOME from environment
    var homeDir = Quickshell.env("HOME")
    if (!homeDir) {
      console.error("[WallpaperManager] Failed to get HOME directory")
      manager.errorMessage = "Failed to get HOME directory"
      return
    }
    
    manager.wallpaperDir = homeDir + "/.config/hypr/wpapers"
    console.log("[WallpaperManager] Initialized")
    console.log("[WallpaperManager] Wallpaper directory:", manager.wallpaperDir)
    
    // Now refresh wallpapers
    refreshWallpapers()
  }
  
  // Temporary buffer to accumulate wallpapers
  property var wallpaperBuffer: []
  
  // Process to list wallpapers
  Process {
    id: listProcess
    command: ["sh", "-c", ""]
    
    onStarted: {
      // Clear buffer when process starts
      manager.wallpaperBuffer = []
      console.log("[WallpaperManager] List process started")
    }
    
    stdout: SplitParser {
      onRead: data => {
        if (!data) return
        
        var line = data.trim()
        if (line && line !== "") {
          console.log("[WallpaperManager] Got wallpaper:", line)
          // Accumulate in buffer instead of replacing
          manager.wallpaperBuffer.push(line)
        }
      }
    }
    
    stderr: SplitParser {
      onRead: data => {
        if (!data) return
        console.error("[WallpaperManager] List error:", data)
        manager.errorMessage = "Failed to list wallpapers: " + data
        manager.isLoading = false
      }
    }
    
    onExited: code => {
      console.log("[WallpaperManager] List process exited with code:", code)
      
      // Now set the final wallpapers array from buffer
      manager.wallpapers = manager.wallpaperBuffer.slice()
      manager.isLoading = false
      
      console.log("[WallpaperManager] Final wallpaper list:", manager.wallpapers.length, "items")
      
      if (code !== 0 && manager.wallpapers.length === 0) {
        console.error("[WallpaperManager] Failed to list wallpapers")
        manager.errorMessage = "Failed to list wallpapers (exit code: " + code + ")"
      }
    }
  }
  
  // Process to get current wallpaper
  Process {
    id: currentWallpaperProcess
    command: ["sh", "-c", ""]
    
    stdout: SplitParser {
      onRead: data => {
        if (!data) return
        var current = data.trim()
        if (current) {
          manager.currentWallpaper = current
          console.log("[WallpaperManager] Current wallpaper:", current)
        }
      }
    }
    
    stderr: SplitParser {
      onRead: data => {
        if (!data) return
        console.error("[WallpaperManager] Current wallpaper detection error:", data)
      }
    }
  }
  
  // Function to refresh wallpaper list
  function refreshWallpapers() {
    if (!manager.wallpaperDir || manager.wallpaperDir === "") {
      console.error("[WallpaperManager] Cannot refresh: wallpaper directory not set")
      return
    }
    
    console.log("[WallpaperManager] Refreshing wallpaper list from:", manager.wallpaperDir)
    manager.isLoading = true
    manager.errorMessage = ""
    
    // List wallpapers
    var listCmd = "ls -1 \"" + manager.wallpaperDir + "\" 2>/dev/null | grep -E '\\.(png|jpg|jpeg|webp)$' || echo ''"
    console.log("[WallpaperManager] Running command:", listCmd)
    listProcess.command = ["sh", "-c", listCmd]
    listProcess.running = true
    
    // Get current wallpaper
    var homeDir = Quickshell.env("HOME")
    var currentCmd = "grep '^preload' \"" + homeDir + "/.config/hypr/hyprpaper.conf\" 2>/dev/null | awk -F'/' '{print $NF}' || echo ''"
    console.log("[WallpaperManager] Current wallpaper command:", currentCmd)
    currentWallpaperProcess.command = ["sh", "-c", currentCmd]
    currentWallpaperProcess.running = true
  }
  
  // Function to set wallpaper
  function setWallpaper(filename) {
    console.log("[WallpaperManager] Setting wallpaper:", filename)
    
    var proc = Qt.createQmlObject(
      'import Quickshell.Io; Process { command: ["' + manager.switcherScript + '", "' + filename + '"] }',
      manager
    )
    
    var stdoutParser = Qt.createQmlObject(
      'import Quickshell.Io; SplitParser {}',
      proc
    )
    proc.stdout = stdoutParser
    
    stdoutParser.read.connect(data => {
      if (data) console.log("[WallpaperManager] Script output:", data)
    })
    
    var stderrParser = Qt.createQmlObject(
      'import Quickshell.Io; SplitParser {}',
      proc
    )
    proc.stderr = stderrParser
    
    stderrParser.read.connect(data => {
      if (data) console.error("[WallpaperManager] Script error:", data)
    })
    
    proc.exited.connect(code => {
      console.log("[WallpaperManager] Script exited with code:", code)
      proc.destroy()
      
      if (code === 0) {
        manager.currentWallpaper = filename
        // Close the wallpaper picker after successful change
        manager.visible = false
      } else {
        console.error("[WallpaperManager] Failed to set wallpaper, exit code:", code)
      }
    })
    
    proc.running = true
  }
  
  // Load wallpapers when manager becomes visible
  onVisibleChanged: {
    if (visible && manager.wallpaperDir !== "") {
      refreshWallpapers()
    }
  }
}
