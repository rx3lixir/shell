import QtQuick

Text {
  id: clock
  color: "#c0caf5"
  font {
    pixelSize: 14
    bold: false
  }
  
  // Update the time every second
  Timer {
    interval: 1000  // 1 second
    running: true
    repeat: true
    onTriggered: {
      clock.text = Qt.formatTime(new Date(), "hh:mm")
    }
  }
  
  // Set initial time
  Component.onCompleted: {
    clock.text = Qt.formatTime(new Date(), "hh:mm")
  }
}
