import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Scope {
  id: manager
  
  required property var brightnessManager

  PwObjectTracker {
    objects: [ Pipewire.defaultAudioSink, Pipewire.defaultAudioSource ]
  }

  readonly property string typeNone: "none"
  readonly property string typeVolume: "volume"
  readonly property string typeMic: "mic"
  readonly property string typeBrightness: "brightness"

  property string currentType: typeNone
  property real currentValue: 0.0
  property bool currentMuted: false
  property string currentIcon: ""
  
  // Track if user is interacting with OSD
  property bool userInteracting: false

  // Hide timer - stops when user is interacting
  Timer {
    id: hideTimer
    interval: 1500
    running: false
    repeat: false
    
    onTriggered: {
      manager.currentType = manager.typeNone
    }
  }
  
  // Watch for interaction changes
  onUserInteractingChanged: {
    if (userInteracting) {
      // User started interacting - stop the timer
      if (hideTimer.running) {
        hideTimer.stop()
      }
    } else {
      // User stopped interacting - restart the timer
      if (manager.currentType !== manager.typeNone) {
        hideTimer.restart()
      }
    }
  }

  // Debounce timer for brightness OSD
  Timer {
    id: brightnessDebounceTimer
    interval: 150
    onTriggered: {
      manager.showOsd(
        manager.typeBrightness,
        manager.brightnessManager.brightness,
        false,
        manager.getBrightnessIcon(manager.brightnessManager.brightness)
      )
    }
  }

  // Helper to show OSD
  function showOsd(type, value, muted, icon) {
    manager.currentType = type
    manager.currentValue = value
    manager.currentMuted = muted
    manager.currentIcon = icon
    
    // Only start timer if user is NOT currently interacting
    if (!manager.userInteracting) {
      hideTimer.restart()
    }
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
      if (manager.brightnessManager.brightnessUserChange) {
        return
      }
      
      brightnessDebounceTimer.restart()
    }
  }
}
