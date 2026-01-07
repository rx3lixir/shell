import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

// Volume State Module
// Manages audio volume state (speakers and microphone) via PipeWire.
// Monitors both programmatic and external changes (e.g., media keys).
Scope {
  id: module
  
  // ============================================================================
  // DEPENDENCIES
  // ============================================================================
  
  // Set by parent when user is interacting with controls
  // Prevents external change signals during user interaction
  property bool userInteracting: false
  
  // ============================================================================
  // PIPEWIRE INTEGRATION
  // ============================================================================
  
  PwObjectTracker {
    objects: [ Pipewire.defaultAudioSink, Pipewire.defaultAudioSource ]
  }
  
  // Audio sink (speakers/headphones)
  property var audioSinkNode: Pipewire.defaultAudioSink
  property var audioSink: audioSinkNode?.audio ?? null
  
  // Audio source (microphone)
  property var audioSourceNode: Pipewire.defaultAudioSource
  property var audioSource: audioSourceNode?.audio ?? null
  
  // ============================================================================
  // STATE PROPERTIES
  // ============================================================================
  
  // Speaker/output volume
  readonly property real volume: audioSink?.volume ?? 0.5
  readonly property bool volumeMuted: audioSink?.muted ?? false
  
  // Microphone/input volume
  readonly property real micVolume: audioSource?.volume ?? 0.5
  readonly property bool micMuted: audioSource?.muted ?? false
  
  // Device information
  readonly property string outputDevice: audioSink?.description ?? "Unknown"
  readonly property string inputDevice: audioSource?.description ?? "Unknown"
  
  // ============================================================================
  // EXTERNAL CHANGE SIGNALS (for OSD)
  // ============================================================================
  
  // Emitted when volume changes from an EXTERNAL source
  // (e.g., media keys, other applications)
  // NOT emitted during user interaction
  signal volumeChangedExternally(real volume, bool muted)
  signal micChangedExternally(real volume, bool muted)
  
  // ============================================================================
  // VOLUME MONITORING
  // ============================================================================
  
  // Watch for speaker volume changes
  Connections {
    target: module.audioSink
    enabled: module.audioSink !== null
    
    function onVolumeChanged() {
      if (!module.audioSink) return
      
      // Only emit signal if user is NOT interacting
      if (!module.userInteracting) {
        module.volumeChangedExternally(
          module.audioSink.volume,
          module.audioSink.muted
        )
      }
    }
    
    function onMutedChanged() {
      if (!module.audioSink) return
      
      // Only emit signal if user is NOT interacting
      if (!module.userInteracting) {
        module.volumeChangedExternally(
          module.audioSink.volume,
          module.audioSink.muted
        )
      }
    }
  }
  
  // Watch for microphone volume changes
  Connections {
    target: module.audioSource
    enabled: module.audioSource !== null
    
    function onVolumeChanged() {
      if (!module.audioSource) return
      
      if (!module.userInteracting) {
        module.micChangedExternally(
          module.audioSource.volume,
          module.audioSource.muted
        )
      }
    }
    
    function onMutedChanged() {
      if (!module.audioSource) return
      
      if (!module.userInteracting) {
        module.micChangedExternally(
          module.audioSource.volume,
          module.audioSource.muted
        )
      }
    }
  }
  
  // ============================================================================
  // PUBLIC FUNCTIONS - Speaker/Output
  // ============================================================================
  
  // Set output volume level
  // @param newVolume - value between 0.0 and 1.0
  function setVolume(newVolume) {
    if (!audioSink) {
      console.error("[Volume] No audio sink available!")
      return
    }
    
    // Clamp between 0 and 1
    newVolume = Math.max(0, Math.min(1, newVolume))
    audioSink.volume = newVolume
  }
  
  // Toggle output mute state
  function toggleVolumeMute() {
    if (!audioSink) {
      console.error("[Volume] No audio sink available!")
      return
    }
    audioSink.muted = !audioSink.muted
  }
  
  // Set output mute state
  // @param muted - true to mute, false to unmute
  function setVolumeMute(muted) {
    if (!audioSink) {
      console.error("[Volume] No audio sink available!")
      return
    }
    audioSink.muted = muted
  }
  
  // ============================================================================
  // PUBLIC FUNCTIONS - Microphone/Input
  // ============================================================================
  
  // Set input volume level
  // @param newVolume - value between 0.0 and 1.0
  function setMicVolume(newVolume) {
    if (!audioSource) {
      console.error("[Volume] No audio source available!")
      return
    }
    
    newVolume = Math.max(0, Math.min(1, newVolume))
    audioSource.volume = newVolume
  }
  
  // Toggle input mute state
  function toggleMicMute() {
    if (!audioSource) {
      console.error("[Volume] No audio source available!")
      return
    }
    audioSource.muted = !audioSource.muted
  }
  
  // Set input mute state
  // @param muted - true to mute, false to unmute
  function setMicMute(muted) {
    if (!audioSource) {
      console.error("[Volume] No audio source available!")
      return
    }
    audioSource.muted = muted
  }
  
  // ============================================================================
  // UTILITY FUNCTIONS
  // ============================================================================
  
  // Get appropriate volume icon based on level and mute state
  // @param volume - volume level (0.0 to 1.0)
  // @param muted - whether audio is muted
  // @returns icon string
  function getVolumeIcon(volume, muted) {
    if (muted) return "󰖁"
    if (volume == 0) return "󰕿"
    if (volume < 0.33) return "󰕿"
    if (volume < 0.66) return "󰖀"
    return "󰕾"
  }
  
  
  // Get microphone icon based on mute state
  // @param muted - whether microphone is muted
  // @returns icon string
  function getMicIcon(muted) {
    return muted ? "󰍭" : "󰍬"
  }
}
