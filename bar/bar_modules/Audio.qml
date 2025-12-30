import QtQuick
import Quickshell
import QtQuick.Layouts
import Quickshell.Io
import "../../theme"

Item {
  id: root

  property string icon: "󰖁"
  property string volume: "N/A"
  property string device: "Unknown"
  property bool hovered: false 

  implicitWidth: hovered ? rowLayout.implicitWidth : iconText.implicitWidth
  implicitHeight: Theme.barHeight

  // Smooth width transition
  Behavior on implicitWidth {
    NumberAnimation {
      duration: 250
      easing.type: Easing.OutCubic
    }
  }

  RowLayout {
    id: rowLayout
    anchors.centerIn: parent
    spacing: Theme.spacingS

    Text {
      id: iconText 
      text: icon
      color: Theme.fg
      font.pixelSize: Theme.fontSizeS
      font.family: Theme.fontFamily
      verticalAlignment: Text.AlignVCenter
    }

    Text {
      id: volumeText 
      text: volume 
      color: Theme.fgMuted
      font.pixelSize: Theme.fontSizeS
      font.family: Theme.fontFamily
      verticalAlignment: Text.AlignVCenter
      visible: hovered && volume !== "N/A"
      opacity: hovered ? 1.0 : 0.0
      
      Behavior on opacity {
        NumberAnimation {
          duration: 250
          easing.type: Easing.OutCubic
        }
      }
    }
  }

  MouseArea {
    anchors.fill: parent
    hoverEnabled: true

    onEntered: root.hovered = true
    onExited: root.hovered = false 

    cursorShape: Qt.PointingHandCursor

    onClicked: {
      Quickshell.execDetached({
        command: ["sh", "-c", "kitty --class floating_term_s -e wiremix"]
      })
    }
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
