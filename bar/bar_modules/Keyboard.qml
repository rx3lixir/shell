import QtQuick
import Quickshell
import Quickshell.Io

Item {
  id: root

  property string icon: "KB"
  property string layout: "Unknown"

  width: childrenRect.width
  height: childrenRect.height

  Text {
    text:" " + layout
    color: "#a9b1d6"
    font.pixelSize: 14
    font.family: "Ubuntu Nerd Font"
  }

  Process {
    id: kbProc
    command: ["sh", "-c", "keyboard-state"]

    stdout: SplitParser {
      onRead: data => {
        if (!data) return
        var line = data.trim()
        var parts = line.split("|")
        if (parts.length === 2) {
          root.icon = parts[0]      // "KB"
          root.layout = parts[1]    // e.g. "English(US)" or "Русский"
        }
      }
    }
  }

  Timer {
    interval: 2000 // Update every 2 seconds
    running: true
    repeat: true
    onTriggered: if (!kbProc.running) kbProc.running = true
  }

  Component.onCompleted: kbProc.running = true
}
