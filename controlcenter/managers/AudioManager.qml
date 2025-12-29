import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Scope {
  id: manager
  
  // ========== STATE ==========
  property real volume: 0.5
  
  // ========== PIPEWIRE INTEGRATION ==========
  PwObjectTracker {
    objects: [ Pipewire.defaultAudioSink ]
  }
  
  property var audioSinkNode: Pipewire.defaultAudioSink
  property var audioSink: audioSinkNode?.audio ?? null
  
  // Sync volume from PipeWire to our property
  Connections {
    target: manager.audioSink
    enabled: manager.audioSink !== null
    
    function onVolumeChanged() {
      if (!manager.audioSink) return
      manager.volume = manager.audioSink.volume
    }
  }
  
  // ========== VOLUME CONTROL ==========
  function setVolume(newVolume) {
    // Clamp between 0 and 1
    newVolume = Math.max(0, Math.min(1, newVolume))
    
    // Set via PipeWire
    if (audioSink) {
      audioSink.volume = newVolume
      volume = newVolume
    } else {
      console.error("No audio sink available!")
    }
  }
  
  Component.onCompleted: {
    if (audioSink) {
      volume = audioSink.volume
    }
  }
}
