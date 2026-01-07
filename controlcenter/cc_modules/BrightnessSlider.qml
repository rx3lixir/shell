import QtQuick
import "../../components"

SliderCard {
  id: root
  
  required property var brightnessManager
  required property var systemState
  
  icon: "󰃠"
  label: "Brightness"
  value: brightnessManager.brightness
  minimumValue: 0.01
  
  // Track dragging
  property bool isDragging: false
  
  onIsDraggingChanged: {
    systemState.userInteracting = isDragging
  }
  
  Timer {
    id: dragDetectionTimer
    interval: 150
    onTriggered: {
      root.isDragging = false
    }
  }
  
  onMoved: newValue => {
    if (!isDragging) {
      isDragging = true
    }
    
    dragDetectionTimer.restart()
    brightnessManager.setBrightness(newValue)
  }
}
