import QtQuick
import Quickshell
import Quickshell.Io

Item {
  id: root

  property string icon: "󰂑"
  property string percentage: "N/A"

  width: childrenRect.width
  height: childrenRect.height

  Text {
    text: icon + " " + percentage
    color: "#a9b1d6"
    font.pixelSize: theme.fontSizeS
    font.family: "Ubuntu Nerd Font"
  }

  Process {
    id: batProc
    command: ["sh", "-c", "battery-state"]

    stdout: SplitParser {
      onRead: data => {
        if (!data) return
        var line = data.trim()
        var parts = line.split("|")
        if (parts.length === 2) {
          root.icon = parts[0]
          root.percentage = parts[1]
        }
      }
    }
  }

  Timer {
    interval: 2000
    running: true
    repeat: true
    onTriggered: if (!batProc.running) batProc.running = true
  }

  Component.onCompleted: batProc.running = true
}
