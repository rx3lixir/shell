import QtQuick
import Quickshell
import Quickshell.Io

Item {
  id: root

  property string ifname: "—"
  property string icon: "󰖪"  // disconnected

  width: childrenRect.width
  height: childrenRect.height

  Text {
    text: icon + " " + ifname
    color: "#a9b1d6"
    font.pixelSize: 14
    font.family: "Ubuntu Nerd Font"  // or your preferred Nerd Font
  }

  Process {
    id: netProc

    command: ["sh", "-c", "network-state"]

    stdout: SplitParser {
      onRead: data => {
        if (!data) return
        var line = data.trim()
        var parts = line.split("|")
        if (parts.length === 2) {
          root.ifname = parts[0]
          root.icon = parts[1]
        }
      }
    }
  }

  Timer {
    interval: 2000
    running: true
    repeat: true
    onTriggered: if (!netProc.running) netProc.running = true
  }

  Component.onCompleted: netProc.running = true
}
