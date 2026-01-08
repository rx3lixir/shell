import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../../theme"

Item {
  id: root

  property string icon: "KB"
  property string layout: "Unknown"

  implicitWidth: layoutText.implicitWidth
  implicitHeight: Theme.barHeight

  Text {
    id: layoutText
    anchors.centerIn: parent
    text: " " + root.layout
    color: Theme.on_surface
    font.pixelSize: Theme.fontSizeS
    font.family: "Ubuntu Nerd Font"
    verticalAlignment: Text.AlignVCenter
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
          root.icon = parts[0]
          root.layout = parts[1]
        }
      }
    }
  }

  Timer {
    interval: 2000
    running: true
    repeat: true
    onTriggered: if (!kbProc.running) kbProc.running = true
  }

  Component.onCompleted: kbProc.running = true
}
