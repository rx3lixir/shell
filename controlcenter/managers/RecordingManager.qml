import QtQuick
import Quickshell
import Quickshell.Io

Scope {
  id: manager
  
  // ========== STATE ==========
  property bool isRecording: false
  
  // ========== RECORDING CONTROL ==========
  Process {
    id: recordingProcess
    command: ["sh", "-c", ""]
    
    onExited: code => {
      console.log("Recording process exited with code:", code)
    }
  }
  
  function toggleRecording() {
    console.log("=== TOGGLING RECORDING ===")
    console.log("Current recording state:", isRecording)
    
    // Toggle state
    isRecording = !isRecording
    console.log("New recording state:", isRecording)
    
    // Path to your recording script
    var scriptPath = "$HOME/.config/quickshell/scripts/screen-record.sh"
    console.log("Running recording script:", scriptPath)
    
    recordingProcess.command = ["sh", "-c", scriptPath]
    recordingProcess.running = true
  }
  
  Component.onCompleted: {
    console.log("=== RECORDING MANAGER LOADED ===")
    console.log("Initial recording state:", isRecording)
  }
}
