import QtQuick
import Quickshell
import Quickshell.Io

Item {
  id: root

  property string icon: "󰖁"
  property string volume: "N/A"
  property string device: "Unknown"

  width: childrenRect.width
  height: childrenRect.height

  Text {
    text: icon + " " + volume + (device !== "Unknown" ? " (" + device + ")" : "")
    color: "#a9b1d6"
    font.pixelSize: 14
    font.family: "Ubuntu Nerd Font"
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
