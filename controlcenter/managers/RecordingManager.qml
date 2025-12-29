import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
  id: recordingManager

  // ========== STATE ==========
  property bool isRecording: false

  function toggleRecording() {
    recordingManager.isRecording = recordingManager.isRecording
  }
}
