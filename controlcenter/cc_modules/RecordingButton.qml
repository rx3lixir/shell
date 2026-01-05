import QtQuick
import "../../components"
import "../../theme"

ToggleCard {
  required property var recordingManager
  
  icon: recordingManager.isRecording ? "󰑊" : "󰻃"
  title: "Record"
  subtitle: recordingManager.isRecording ? "Recording..." : "Screen"
  isActive: recordingManager.isRecording
  
  // Custom error color for recording state
  activeIconBg: Theme.error
  activeIconColor: Theme.on_error
  
  onClicked: recordingManager.toggleRecording()
}
