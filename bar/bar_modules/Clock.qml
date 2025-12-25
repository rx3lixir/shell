import QtQuick
import "../../theme"

Item {
  implicitWidth: clock.implicitWidth
  implicitHeight: Theme.barHeight

  Text {
    id: clock
    anchors.centerIn: parent
    color: Theme.fg
    font.pixelSize: Theme.fontSizeS
    font.family: Theme.fontFamily
    font.bold: false
    verticalAlignment: Text.AlignVCenter
    
    Timer {
      interval: 1000
      running: true
      repeat: true
      onTriggered: {
        clock.text = Qt.formatTime(new Date(), "hh:mm")
      }
    }
    
    Component.onCompleted: {
      clock.text = Qt.formatTime(new Date(), "hh:mm")
    }
  }
}
