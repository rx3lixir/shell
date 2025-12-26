import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../../theme"

Item {
  id: root

  property string icon: "󰂑"
  property string percentage: "N/A"
  property bool hovered: false

  // Width expands when hovered to show the percentage
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
    
    // Icon (always visible)
    Text {
      id: iconText
      text: icon
      color: Theme.fg
      font.pixelSize: Theme.fontSizeS
      font.family: Theme.fontFamily
      verticalAlignment: Text.AlignVCenter
    }
    
    // Percentage (only visible on hover)
    Text {
      id: percentageText
      text: percentage
      color: Theme.fgMuted
      font.pixelSize: Theme.fontSizeS
      font.family: Theme.fontFamily
      verticalAlignment: Text.AlignVCenter
      visible: hovered && percentage !== "N/A"
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
