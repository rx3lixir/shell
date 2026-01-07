import QtQuick
import "../../components"

SliderCard {
  id: root
  
  required property var audioManager
  required property var systemState  // ← NEW: Need this to set userInteracting
  
  icon: "󰕾"
  label: "Volume"
  value: audioManager.volume
  
  // ============================================================================
  // USER INTERACTION TRACKING
  // ============================================================================
  
  property bool isDragging: false
  
  // When dragging state changes, notify system state
  onIsDraggingChanged: {
    systemState.userInteracting = isDragging
  }
  
  // Timer to detect when dragging session ends
  Timer {
    id: dragDetectionTimer
    interval: 150  // If no movement for 150ms, dragging ended
    onTriggered: {
      root.isDragging = false
    }
  }
  
  // ============================================================================
  // SLIDER INTERACTION
  // ============================================================================
  
  onMoved: newValue => {
    // User is moving the slider - mark as dragging
    if (!isDragging) {
      isDragging = true
    }
    
    // Keep timer alive while moving
    dragDetectionTimer.restart()
    
    // Actually set the volume
    audioManager.setVolume(newValue)
  }
}
