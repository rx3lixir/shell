import QtQuick
import "../../components"
import "../../theme"

IconButton {
  required property var recordingManager
  
  icon: recordingManager.isRecording ? "󰑊" : "󰻃"
  title: "Record"
  subtitle: recordingManager.isRecording ? "Recording..." : "Screen"

  isStateful: true
  isActive: recordingManager.isRecording
  
  // Custom error color for recording state
  activeIconBg: Theme.error
  activeIconColor: Theme.on_error
  
  onClicked: recordingManager.toggleRecording()
}
