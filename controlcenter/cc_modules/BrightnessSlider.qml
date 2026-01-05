import QtQuick
import "../../components"

SliderCard {
  required property var brightnessManager
  
  icon: "󰃠"
  label: "Brightness"
  value: brightnessManager.brightness
  minimumValue: 0.01  // Prevent completely dark screen
  
  onMoved: newValue => {
    brightnessManager.setBrightness(newValue)
  }
}
