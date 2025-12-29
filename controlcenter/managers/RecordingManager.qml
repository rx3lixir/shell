import QtQuick
import Quickshell
import Quickshell.Io

Scope {
  id: manager
  
  // ========== STATE ==========
  property bool isRecording: false
  
  // Path to the PID file that screen-rec uses
  readonly property string pidFilePath: "/tmp/wl-recorder.pid"
  
  // ========== CHECK IF RECORDING ==========
  // We'll poll this to keep the state in sync
  Process {
    id: checkRecordingProcess
    command: ["test", "-f", manager.pidFilePath]
    
    onExited: code => {
      // Exit code 0 means file exists (recording active)
      // Exit code 1 means file doesn't exist (not recording)
      manager.isRecording = (code === 0)
    }
  }
  
  // Timer to periodically check recording state
  Timer {
    interval: 1000  // Check every second
    running: true
    repeat: true
    onTriggered: {
      if (!checkRecordingProcess.running) {
        checkRecordingProcess.running = true
      }
    }
  }
  
  // ========== TOGGLE RECORDING ==========
  function toggleRecording() {
    console.log("Toggle recording called, current state:", manager.isRecording)
    
    // Create a process to run screen-rec
    var proc = Qt.createQmlObject(
      'import Quickshell; import Quickshell.Io; Process { command: ["screen-rec"] }',
      manager
    )
    
    proc.exited.connect(code => {
      console.log("screen-rec exited with code:", code)
      proc.destroy()
      
      // Force immediate state check after toggle
      Qt.callLater(() => {
        checkRecordingProcess.running = true
      })
    })
    
    // Note: stderr handling removed due to QML limitations
    // The script sends notifications anyway
    
    proc.running = true
  }
  
  // ========== INITIALIZATION ==========
  Component.onCompleted: {
    // Check initial state
    checkRecordingProcess.running = true
  }
}
