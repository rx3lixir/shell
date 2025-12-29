import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Scope {
  id: manager
  
  // Receives the specific BrightnessManager instead of whole ControlCenterManager
  required property var brightnessManager

  // Track PipeWire objects
  PwObjectTracker {
    objects: [ Pipewire.defaultAudioSink, Pipewire.defaultAudioSource ]
  }

  // OSD Types
  readonly property string typeNone: "none"
  readonly property string typeVolume: "volume"
  readonly property string typeMic: "mic"
  readonly property string typeBrightness: "brightness"

  // Exposed state for the display
  property string currentType: typeNone
  property real currentValue: 0.0
  property bool currentMuted: false
  property string currentIcon: ""

  // Single unified timer
  Timer {
    id: hideTimer
    interval: 1500
    onTriggered: manager.currentType = manager.typeNone
  }

  // Debounce timer for brightness OSD
  Timer {
    id: brightnessDebounceTimer
    interval: 150  // Short delay to batch rapid changes
    onTriggered: {
      console.log("Showing brightness OSD")
      manager.showOsd(
        manager.typeBrightness,
        manager.brightnessManager.brightness,  // CHANGED: access via brightnessManager
        false,
        manager.getBrightnessIcon(manager.brightnessManager.brightness)  // CHANGED
      )
    }
  }

  // Helper to show OSD
  function showOsd(type, value, muted, icon) {
    manager.currentType = type
    manager.currentValue = value
    manager.currentMuted = muted
    manager.currentIcon = icon
    hideTimer.restart()
  }

  // Volume icon logic
  function getVolumeIcon(volume, muted) {
    if (muted) return "󰖁"
    if (volume == 0) return "󰕿"
    if (volume < 0.62) return "󰖀"
    return "󰕾"
  }

  // Brightness icon logic
  function getBrightnessIcon(brightness) {
    if (brightness < 0.33) return "󰃞"
    if (brightness < 0.66) return "󰃟"
    return "󰃠"
  }

  // PipeWire: Speaker/Volume
  property var audioSinkNode: Pipewire.defaultAudioSink
  property var audioSink: audioSinkNode?.audio ?? null
  
  Connections {
    target: manager.audioSink
    enabled: manager.audioSink !== null
    
    function onVolumeChanged() {
      if (!manager.audioSink) return
      const vol = manager.audioSink.volume
      const muted = manager.audioSink.muted
      manager.showOsd(
        manager.typeVolume,
        vol,
        muted,
        manager.getVolumeIcon(vol, muted)
      )
    }
    
    function onMutedChanged() {
      if (!manager.audioSink) return
      const vol = manager.audioSink.volume
      const muted = manager.audioSink.muted
      manager.showOsd(
        manager.typeVolume,
        vol,
        muted,
        manager.getVolumeIcon(vol, muted)
      )
    }
  }

  // PipeWire: Microphone
  property var audioSourceNode: Pipewire.defaultAudioSource
  property var audioSource: audioSourceNode?.audio ?? null
  
  Connections {
    target: manager.audioSource
    enabled: manager.audioSource !== null
    
    function onVolumeChanged() {
      if (!manager.audioSource) return
      const vol = manager.audioSource.volume
      const muted = manager.audioSource.muted
      manager.showOsd(
        manager.typeMic,
        vol,
        muted,
        muted ? "󰍭" : "󰍬"
      )
    }
    
    function onMutedChanged() {
      if (!manager.audioSource) return
      const vol = manager.audioSource.volume
      const muted = manager.audioSource.muted
      manager.showOsd(
        manager.typeMic,
        vol,
        muted,
        muted ? "󰍭" : "󰍬"
      )
    }
  }

  // Watch brightness changes from BrightnessManager
  Connections {
    target: manager.brightnessManager
    
    function onBrightnessChanged() {
      // Skip OSD if this is a user-initiated change from the slider
      // (user can see the slider moving, doesn't need OSD spam)
      if (manager.brightnessManager.brightnessUserChange) {
        return
      }
      
      // For external changes (keyboard shortcuts, other apps), show OSD
      // but debounce it to avoid rapid fire
      brightnessDebounceTimer.restart()
    }
  }
}
