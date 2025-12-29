import QtQuick
import Quickshell
import "managers" as Managers

Scope {
  id: manager
  
  // Visibility state
  property bool visible: false
  
  // Sub-managers - each handles its own domain
  Managers.NetworkManager {
    id: networkManager
  }
  
  Managers.AudioManager {
    id: audioManager
  }
  
  Managers.BrightnessManager {
    id: brightnessManager
  }
  
  Managers.MediaManager {
    id: mediaManager
  }
  
  Managers.RecordingManager {
    id: recordingManager
  }
  
  Managers.UtilitiesManager {
    id: utilitiesManager
  }
  
  // Expose sub-managers for display components
  readonly property var network: networkManager
  readonly property var audio: audioManager
  readonly property var brightness: brightnessManager
  readonly property var media: mediaManager
  readonly property var recording: recordingManager
  readonly property var utilities: utilitiesManager
}
