import QtQuick
import Quickshell
import Quickshell.Io

Scope {
  id: manager
  
  // ========== MEDIA PLAYER STATE ==========
  property bool playerActive: false
  property bool playerPlaying: false
  property string playerTitle: ""
  property string playerArtist: ""
  property string playerName: ""
  property real playerPosition: 0.0  // Current position in seconds
  property real playerLength: 0.0     // Total length in seconds
  
  // ========== GET PLAYER STATUS ==========
  Process {
    id: playerStatusProcess
    command: ["playerctl", "status"]
    
    stdout: SplitParser {
      onRead: data => {
        if (!data) {
          manager.playerActive = false
          return
        }
        var status = data.trim()
        console.log("Player status:", status)
        
        if (status === "Playing" || status === "Paused") {
          manager.playerActive = true
          manager.playerPlaying = (status === "Playing")
          
          // Get metadata and position
          playerMetadataProcess.running = true
          playerPositionProcess.running = true
        } else {
          manager.playerActive = false
        }
      }
    }
    
    stderr: SplitParser {
      onRead: data => {
        // No player available
        manager.playerActive = false
      }
    }
  }
  
  // ========== GET PLAYER METADATA ==========
  Process {
    id: playerMetadataProcess
    command: ["playerctl", "metadata", "--format", "{{title}}|{{artist}}|{{playerName}}|{{mpris:length}}"]
    
    stdout: SplitParser {
      onRead: data => {
        if (!data) return
        var parts = data.trim().split("|")
        manager.playerTitle = parts[0] || ""
        manager.playerArtist = parts[1] || ""
        manager.playerName = parts[2] || ""
        
        // Length comes in microseconds, convert to seconds
        var lengthMicro = parseInt(parts[3] || "0")
        manager.playerLength = lengthMicro / 1000000.0
        
        console.log("Player metadata - Title:", manager.playerTitle, "Artist:", manager.playerArtist, "Length:", manager.playerLength)
      }
    }
  }
  
  // ========== GET CURRENT POSITION ==========
  Process {
    id: playerPositionProcess
    command: ["playerctl", "position"]
    
    stdout: SplitParser {
      onRead: data => {
        if (!data) return
        var pos = parseFloat(data.trim())
        if (!isNaN(pos)) {
          manager.playerPosition = pos
        }
      }
    }
  }
  
  // ========== TIMERS ==========
  // Timer to poll player status (every 2 seconds)
  Timer {
    interval: 2000
    running: true
    repeat: true
    onTriggered: {
      if (!playerStatusProcess.running) {
        playerStatusProcess.running = true
      }
    }
  }
  
  // Timer to update position more frequently when playing (every 1 second)
  Timer {
    interval: 1000
    running: manager.playerPlaying
    repeat: true
    onTriggered: {
      if (!playerPositionProcess.running) {
        playerPositionProcess.running = true
      }
    }
  }
  
  // ========== MEDIA PLAYER CONTROLS ==========
  function playerPlayPause() {
    console.log("=== PLAY/PAUSE ===")
    var proc = Qt.createQmlObject('import Quickshell.Io; Process { command: ["playerctl", "play-pause"] }', manager)
    proc.running = true
    proc.exited.connect(() => {
      console.log("Play/pause command sent")
      proc.destroy()
      // Force update status
      playerStatusProcess.running = true
    })
  }
  
  function playerNext() {
    console.log("=== NEXT TRACK ===")
    var proc = Qt.createQmlObject('import Quickshell.Io; Process { command: ["playerctl", "next"] }', manager)
    proc.running = true
    proc.exited.connect(() => {
      console.log("Next command sent")
      proc.destroy()
      // Small delay before updating to let player switch
      Qt.callLater(() => playerStatusProcess.running = true)
    })
  }
  
  function playerPrevious() {
    console.log("=== PREVIOUS TRACK ===")
    var proc = Qt.createQmlObject('import Quickshell.Io; Process { command: ["playerctl", "previous"] }', manager)
    proc.running = true
    proc.exited.connect(() => {
      console.log("Previous command sent")
      proc.destroy()
      // Small delay before updating to let player switch
      Qt.callLater(() => playerStatusProcess.running = true)
    })
  }
  
  function playerSeek(position) {
    console.log("=== SEEKING TO:", position, "===")
    // Update UI immediately for responsive feel
    manager.playerPosition = position
    
    var proc = Qt.createQmlObject('import Quickshell.Io; Process { command: ["playerctl", "position", "' + position + '"] }', manager)
    proc.running = true
    proc.exited.connect(() => {
      console.log("Seek command sent")
      proc.destroy()
      // Update position after seek
      Qt.callLater(() => playerPositionProcess.running = true)
    })
  }
  
  // Helper function to format time (seconds -> MM:SS)
  function formatTime(seconds) {
    if (isNaN(seconds) || seconds < 0) return "0:00"
    
    var mins = Math.floor(seconds / 60)
    var secs = Math.floor(seconds % 60)
    return mins + ":" + (secs < 10 ? "0" : "") + secs
  }
  
  Component.onCompleted: {
    console.log("=== MEDIA MANAGER LOADED ===")
    // Get initial player status
    playerStatusProcess.running = true
  }
}
