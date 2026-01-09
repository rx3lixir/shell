import QtQuick
import Quickshell
import Quickshell.Io

Scope {
  id: manager
  
  // Visibility state
  property bool visible: false
  
  // Wallpaper directory
  property string wallpaperDir: ""
  
  // Script path
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
    var homeDir = Quickshell.env("HOME")
    if (!homeDir) {
      manager.errorMessage = "Failed to get HOME directory"
      return
    }
    
    manager.wallpaperDir = homeDir + "/.config/hypr/wpapers"
    refreshWallpapers()
  }
  
  // Temporary buffer to accumulate wallpapers
  property var wallpaperBuffer: []
  
  // Process to list wallpapers
  Process {
    id: listProcess
    command: ["sh", "-c", ""]
    
    onStarted: {
      manager.wallpaperBuffer = []
    }
    
    stdout: SplitParser {
      onRead: data => {
        if (!data) return
        
        var line = data.trim()
        if (line && line !== "") {
          manager.wallpaperBuffer.push(line)
        }
      }
    }
    
    stderr: SplitParser {
      onRead: data => {
        if (!data) return
        manager.errorMessage = "Failed to list wallpapers: " + data
        manager.isLoading = false
      }
    }
    
    onExited: code => {
      manager.wallpapers = manager.wallpaperBuffer.slice()
      manager.isLoading = false
      
      if (code !== 0 && manager.wallpapers.length === 0) {
        manager.errorMessage = "Failed to list wallpapers (exit code: " + code + ")"
      }
    }
  }
  
  // Process to get current wallpaper from new config format
  Process {
    id: currentWallpaperProcess
    command: ["sh", "-c", ""]
    
    stdout: SplitParser {
      onRead: data => {
        if (!data) return
        
        var line = data.trim()
        
        // Parse the new wallpaper { } block format
        // Look for lines like: path = /path/to/wallpaper.jpg
        var pathMatch = line.match(/^\s*path\s*=\s*(.+)$/)
        if (pathMatch && pathMatch[1]) {
          var fullPath = pathMatch[1].trim()
          // Extract just the filename from the full path
          var filename = fullPath.split('/').pop()
          if (filename) {
            manager.currentWallpaper = filename
          }
        }
      }
    }
    
    stderr: SplitParser {
      onRead: data => {
        // Silently ignore errors for current wallpaper detection
      }
    }
  }
  
  // Function to refresh wallpaper list
  function refreshWallpapers() {
    if (!manager.wallpaperDir || manager.wallpaperDir === "") {
      return
    }
    
    manager.isLoading = true
    manager.errorMessage = ""
    
    // List wallpapers
    var listCmd = "ls -1 \"" + manager.wallpaperDir + "\" 2>/dev/null | grep -E '\\.(png|jpg|jpeg|webp)$' || echo ''"
    listProcess.command = ["sh", "-c", listCmd]
    listProcess.running = true
    
    // Get current wallpaper from new config format
    var homeDir = Quickshell.env("HOME")
    var currentCmd = "cat \"" + homeDir + "/.config/hypr/hyprpaper.conf\" 2>/dev/null || echo ''"
    currentWallpaperProcess.command = ["sh", "-c", currentCmd]
    currentWallpaperProcess.running = true
  }
  
  // Function to set wallpaper
  function setWallpaper(filename) {
    var proc = Qt.createQmlObject(
      'import Quickshell.Io; Process { command: ["' + manager.switcherScript + '", "' + filename + '"] }',
      manager
    )
    
    var stdoutParser = Qt.createQmlObject(
      'import Quickshell.Io; SplitParser {}',
      proc
    )
    proc.stdout = stdoutParser
    
    var stderrParser = Qt.createQmlObject(
      'import Quickshell.Io; SplitParser {}',
      proc
    )
    proc.stderr = stderrParser
    
    proc.exited.connect(code => {
      proc.destroy()
      
      if (code === 0) {
        manager.currentWallpaper = filename
        // Close the wallpaper picker after successful change
        manager.visible = false
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
