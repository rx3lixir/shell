import QtQuick
import Quickshell
import Quickshell.Io
import "../../theme"

Item {
  id: root

  property string ifname: "—"
  property string icon: "󰖪"

  implicitWidth: label.implicitWidth
  implicitHeight: Theme.barHeight

  Text {
    id: label
    anchors.centerIn: parent
    text: icon // + " " + ifname
    color: Theme.fg
    font.pixelSize: Theme.fontSizeS
    font.family: Theme.fontFamily
    verticalAlignment: Text.AlignVCenter
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
