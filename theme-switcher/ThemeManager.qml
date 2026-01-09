import QtQuick
import Quickshell
import Quickshell.Io

Scope {
  id: manager
  
  // ============================================================================
  // STATE
  // ============================================================================
  
  property bool visible: false
  property string currentMode: "dark"
  
  // ============================================================================
  // THEME OPTIONS
  // ============================================================================
  
  property var themeOptions: [
    {
      icon: "󰖙",  // Sun icon
      name: "Light Mode",
      description: "Bright and cheerful",
      mode: "light",
      color: "#fbbf24"  // Yellow/amber
    },
    {
      icon: "󰖔",  // Moon icon  
      name: "Dark Mode",
      description: "Easy on the eyes",
      mode: "dark",
      color: "#3b82f6"  // Blue
    }
  ]
  
  // ============================================================================
  // INITIALIZATION
  // ============================================================================
  
  Component.onCompleted: {
    readCurrentTheme()
  }
  
  // ============================================================================
  // READ CURRENT THEME MODE
  // ============================================================================
  
  function readCurrentTheme() {
    var homeDir = Quickshell.env("HOME")
    var modeFile = homeDir + "/.config/quickshell/theme-mode"
    
    var proc = Qt.createQmlObject(
      'import Quickshell.Io; Process { command: ["cat", "' + modeFile + '"] }',
      manager
    )
    
    var parser = Qt.createQmlObject(
      'import Quickshell.Io; SplitParser {}',
      proc
    )
    
    parser.onRead.connect(data => {
      if (!data) return
      
      var mode = data.trim()
      if (mode === "light" || mode === "dark") {
        manager.currentMode = mode
        console.log("[ThemeManager] Current mode:", mode)
      }
    })
    
    proc.stdout = parser
    
    proc.exited.connect(code => {
      if (code !== 0) {
        // File doesn't exist, default to dark
        manager.currentMode = "dark"
        console.log("[ThemeManager] No theme mode file, defaulting to dark")
      }
      proc.destroy()
    })
    
    proc.running = true
  }
  
  // ============================================================================
  // SET THEME MODE
  // ============================================================================
  
  function setTheme(mode) {
    if (mode !== "light" && mode !== "dark") {
      console.error("[ThemeManager] Invalid mode:", mode)
      return
    }
    
    console.log("[ThemeManager] Switching to", mode, "mode")
    
    var proc = Qt.createQmlObject(
      'import Quickshell.Io; Process { command: ["quickshell-theme", "' + mode + '"] }',
      manager
    )
    
    // Capture stdout
    var stdoutParser = Qt.createQmlObject(
      'import Quickshell.Io; SplitParser {}',
      proc
    )
    stdoutParser.onRead.connect(data => {
      if (data && data.trim()) {
        console.log("[ThemeManager]", data.trim())
      }
    })
    proc.stdout = stdoutParser
    
    // Capture stderr
    var stderrParser = Qt.createQmlObject(
      'import Quickshell.Io; SplitParser {}',
      proc
    )
    stderrParser.onRead.connect(data => {
      if (data && data.trim()) {
        console.error("[ThemeManager]", data.trim())
      }
    })
    proc.stderr = stderrParser
    
    proc.exited.connect(code => {
      if (code === 0) {
        manager.currentMode = mode
        manager.visible = false
        console.log("[ThemeManager] Theme switched successfully")
      } else {
        console.error("[ThemeManager] Failed to switch theme (exit code:", code + ")")
      }
      proc.destroy()
    })
    
    proc.running = true
  }
  
  // ============================================================================
  // TOGGLE THEME
  // ============================================================================
  
  function toggleTheme() {
    var proc = Qt.createQmlObject(
      'import Quickshell.Io; Process { command: ["quickshell-theme", "toggle"] }',
      manager
    )
    
    proc.exited.connect(code => {
      if (code === 0) {
        // Re-read current mode
        Qt.callLater(() => readCurrentTheme())
        manager.visible = false
      }
      proc.destroy()
    })
    
    proc.running = true
  }
  
  // ============================================================================
  // IPC HANDLERS
  // ============================================================================
  
  IpcHandler {
    target: "theme"
    
    function toggle(): void {
      manager.visible = !manager.visible
    }
    
    function open(): void {
      manager.visible = true
    }
    
    function close(): void {
      manager.visible = false
    }
    
    function set(mode: string): void {
      manager.setTheme(mode)
    }
    
    function switch_mode(): void {
      manager.toggleTheme()
    }
  }
}
