import QtQuick
import Quickshell
import Quickshell.Io
import "../../theme"

Item {
  id: root

  property string icon: "󰖁"
  property string volume: "N/A"
  property string device: "Unknown"

  implicitWidth: label.implicitWidth
  implicitHeight: Theme.barHeight

  Text {
    id: label
    anchors.centerIn: parent
    text: icon// add to appear volume:  + " " + volume
    color: Theme.fg
    font.pixelSize: Theme.fontSizeS
    font.family: Theme.fontFamily
    verticalAlignment: Text.AlignVCenter
  }

  Process {
    id: audioProc
    command: ["sh", "-c", "audio-state"]

    stdout: SplitParser {
      onRead: data => {
        if (!data) return
        var line = data.trim()
        var parts = line.split("|")
        if (parts.length >= 2) {
          root.icon = parts[0]
          root.volume = parts[1]
          root.device = parts.length === 3 ? parts[2] : "Unknown"
        }
      }
    }
  }

  Timer {
    interval: 2000
    running: true
    repeat: true
    onTriggered: if (!audioProc.running) audioProc.running = true
  }

  Component.onCompleted: audioProc.running = true
}
