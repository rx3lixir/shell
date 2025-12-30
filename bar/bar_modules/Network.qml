import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../../theme"

Item {
  id: root

  property string ifname: "—"
  property string icon: "󰖪"
  property bool hovered: false

  // Width expands when hovered to show the text
  implicitWidth: hovered ? rowLayout.implicitWidth : label.implicitWidth
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
    
    // Icon (always visible)
    Text {
      id: label
      text: icon
      color: Theme.fg
      font.pixelSize: Theme.fontSizeS
      font.family: Theme.fontFamily
      verticalAlignment: Text.AlignVCenter
    }
    
    // Interface name (only visible on hover)
    Text {
      id: ifnameText
      text: ifname
      color: Theme.fgMuted
      font.pixelSize: Theme.fontSizeS
      font.family: Theme.fontFamily
      verticalAlignment: Text.AlignVCenter
      visible: hovered && ifname !== "—"
      opacity: hovered ? 1.0 : 0.0
      
      Behavior on opacity {
        NumberAnimation {
          duration: 250 
          easing.type: Easing.OutCubic
        }
      }
    }
  }

  // MouseArea to detect hover
  MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    
    onEntered: root.hovered = true
    onExited: root.hovered = false

    cursorShape: Qt.PointingHandCursor

    onClicked: {
      Quickshell.execDetached({
        command: ["sh", "-c", "kitty --class floating_term_m -e impala"]
      })
    }
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
