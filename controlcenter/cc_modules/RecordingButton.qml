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
  
  onClicked: recordingManager.toggleRecording()
}
