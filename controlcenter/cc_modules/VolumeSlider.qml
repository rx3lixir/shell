import QtQuick
import "../../components"

SliderCard {
  required property var audioManager
  
  icon: "󰕾"
  label: "Volume"
  value: audioManager.volume
  
  onMoved: newValue => {
    audioManager.setVolume(newValue)
  }
}
