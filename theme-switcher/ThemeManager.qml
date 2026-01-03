import QtQuick
import Quickshell
import Quickshell.Io

Scope {
  id: manager
  
  // Visibility state
  property bool visible: false
  
  // Search text
  property string searchText: ""
  
  // Themes directory
  readonly property string themesDir: Quickshell.env("HOME") + "/.config/themes"
  
  // Current theme file
  readonly property string currentThemeFile: themesDir + "/.current"
  
  // Script path
  readonly property string switcherScript: Quickshell.env("HOME") + "/.local/bin/theme-switcher"
  
  // List of available themes
  property var themes: []
  
  // Currently active theme
  property string currentTheme: ""
  
  // Loading state
  property bool isLoading: false
  property string errorMessage: ""
  
  // Temporary buffer for theme names
  property var themeBuffer: []
  
  onVisibleChanged: {
    if (visible) {
      searchText = ""
      refreshThemes()
    }
  }
  
  // Process to get current theme
  Process {
    id: currentThemeProcess
    command: ["sh", "-c", "cat '" + manager.currentThemeFile + "' 2>/dev/null || echo ''"]
    
    stdout: SplitParser {
      onRead: data => {
        if (!data) return
        var line = data.trim()
        if (line && line !== "") {
          manager.currentTheme = line
          console.log("[ThemeManager] Current theme:", line)
        }
      }
    }
    
    stderr: SplitParser {
      onRead: data => {
        if (!data) return
        console.log("[ThemeManager] Current theme detection failed:", data)
        manager.currentTheme = ""
      }
    }
  }
  
  // Process to list themes
  Process {
    id: listThemesProcess
    command: ["sh", "-c", ""]
    
    property string buffer: ""
    
    onStarted: {
      manager.themeBuffer = ["Matugen"] // Always include Matugen
      buffer = ""
    }
    
    stdout: SplitParser {
      onRead: data => {
        if (!data) return
        
        var lines = data.split("\n")
        for (var i = 0; i < lines.length; i++) {
          var line = lines[i].trim()
          if (line && line !== "" && line !== "Matugen") {
            manager.themeBuffer.push(line)
          }
        }
      }
    }
    
    stderr: SplitParser {
      onRead: data => {
        if (!data) return
        console.error("[ThemeManager] List themes error:", data)
      }
    }
    
    onExited: code => {
      manager.themes = manager.themeBuffer.slice()
      manager.isLoading = false
      
      console.log("[ThemeManager] Found", manager.themes.length, "themes")
      
      if (code !== 0 && manager.themes.length === 1) {
        manager.errorMessage = "Failed to scan themes directory"
      }
    }
  }
  
  // Function to refresh theme list
  function refreshThemes() {
    manager.isLoading = true
    manager.errorMessage = ""
    
    // Get current theme
    currentThemeProcess.running = true
    
    // List available themes
    // This script finds all theme.conf files and extracts their names
    var listCmd = [
      "cd '" + manager.themesDir + "' 2>/dev/null &&",
      "find -L . -maxdepth 2 -name 'theme.conf' -type f 2>/dev/null |",
      "while read conf; do",
      "  grep -E '^name[[:space:]]*=' \"$conf\" 2>/dev/null |",
      "  head -1 |",
      "  sed -E 's/^name[[:space:]]*=[[:space:]]*//' |",
      "  tr -d '\"' |",
      "  xargs;",
      "done |",
      "sort -u"
    ].join(" ")
    
    listThemesProcess.command = ["sh", "-c", listCmd]
    listThemesProcess.running = true
  }
  
  // Function to apply a theme
  function applyTheme(themeName) {
    console.log("[ThemeManager] Applying theme:", themeName)
    
    var proc = Qt.createQmlObject(
      'import Quickshell.Io; Process { command: ["' + manager.switcherScript + '", "' + themeName + '"] }',
      manager
    )
    
    var stdoutParser = Qt.createQmlObject(
      'import Quickshell.Io; SplitParser {}',
      proc
    )
    proc.stdout = stdoutParser
    
    stdoutParser.read.connect(data => {
      if (data) {
        console.log("[ThemeManager]", data.trim())
      }
    })
    
    var stderrParser = Qt.createQmlObject(
      'import Quickshell.Io; SplitParser {}',
      proc
    )
    proc.stderr = stderrParser
    
    stderrParser.read.connect(data => {
      if (data) {
        console.error("[ThemeManager]", data.trim())
      }
    })
    
    proc.exited.connect(code => {
      proc.destroy()
      
      if (code === 0) {
        manager.currentTheme = themeName
        manager.visible = false
        console.log("[ThemeManager] Theme applied successfully:", themeName)
      } else {
        manager.errorMessage = "Failed to apply theme (exit code: " + code + ")"
        console.error("[ThemeManager] Failed to apply theme, exit code:", code)
      }
    })
    
    proc.running = true
  }
  
  // IPC Handler for external control
  IpcHandler {
    target: "themes"
    
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
  
  // Initialize on component creation
  Component.onCompleted: {
    refreshThemes()
  }
}
