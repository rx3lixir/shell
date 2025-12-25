import QtQuick
import Quickshell
import Quickshell.Io

Item {
  id: root

  property string icon: "󰂲"
  property string status: "Off"

  width: childrenRect.width
  height: childrenRect.height

  Text {
    text: icon
    color: "#a9b1d6"
    font.pixelSize: theme.fontSizeS
    font.family: "Ubuntu Nerd Font"
  }

  Process {
    id: btProc
    command: ["sh", "-c", "bluetooth-state"]

    stdout: SplitParser {
      onRead: data => {
        if (!data) return
        var line = data.trim()
        var parts = line.split("|")
        if (parts.length === 2) {
          root.icon = parts[0]
          root.status = parts[1]
        }
      }
    }
  }

  Timer {
    interval: 5000  // Bluetooth state doesn't change often
    running: true
    repeat: true
    onTriggered: if (!btProc.running) btProc.running = true
  }

  Component.onCompleted: btProc.running = true
}
