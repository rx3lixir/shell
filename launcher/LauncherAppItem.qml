import QtQuick
import QtQuick.Layouts
import Quickshell
import "../theme"

Rectangle {
  id: root
  
  required property var app
  property bool isSelected: false
  signal launched()
  signal clicked()
  
  radius: Theme.radiusXLarge
  color: {
    if (isSelected) return Theme.accent
    if (appMouseArea.containsMouse) return Theme.bg2transparent
    return "transparent"
  }
  
  RowLayout {
    anchors {
      fill: parent
      margins: Theme.spacingS
    }
    spacing: Theme.spacingM
    
    // Icon placeholder - using first letter for now
    Rectangle {
      Layout.preferredWidth: 32
      Layout.preferredHeight: 32
      radius: Theme.radiusLarge
      color: isSelected ? Theme.fg : Theme.accentTransparent
      
      Text {
        anchors.centerIn: parent
        text: root.app.name ? root.app.name.charAt(0).toUpperCase() : "?"
        color: isSelected ? Theme.bg1 : Theme.fg
        font.pixelSize: Theme.fontSizeL
        font.family: Theme.fontFamily
        font.bold: true
        
        Behavior on color {
          ColorAnimation {
            duration: 600
            easing.type: Easing.OutCubic
          }
        }
      }
    }
    
    // App info
    ColumnLayout {
      Layout.fillWidth: true
      spacing: 2
      
      Text {
        Layout.fillWidth: true
        text: root.app.name || "Unknown"
        color: isSelected ? Theme.bg1 : Theme.fg
        font.pixelSize: Theme.fontSizeM
        font.family: Theme.fontFamily
        elide: Text.ElideRight
        
        Behavior on color {
          ColorAnimation {
            duration: 200
            easing.type: Easing.OutCubic
          }
        }
      }
      
      Text {
        Layout.fillWidth: true
        text: root.app.comment || ""
        color: isSelected ? Theme.bg2 : Theme.fgMuted
        font.pixelSize: Theme.fontSizeS
        font.family: Theme.fontFamily
        elide: Text.ElideRight
        visible: text !== ""
        
        Behavior on color {
          ColorAnimation {
            duration: 200
            easing.type: Easing.OutCubic
          }
        }
      }
    }
  }
  
  MouseArea {
    id: appMouseArea
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    
    onClicked: {
      console.log("=== APP CLICKED ===")
      console.log("App name:", root.app.name)
      console.log("App command:", root.app.command)
      
      // Notify parent that this item was clicked
      root.clicked()
      
      // Try execute() first
      try {
        console.log("Attempting app.execute()...")
        root.app.execute()
        console.log("execute() called successfully!")
        root.launched()
      } catch (error) {
        console.error("execute() failed:", error)
        
        // Fallback: try execDetached
        try {
          console.log("Trying fallback: Quickshell.execDetached()...")
          Quickshell.execDetached({
            command: root.app.command,
            workingDirectory: root.app.workingDirectory || ""
          })
          console.log("Fallback launch successful!")
          root.launched()
        } catch (fallbackError) {
          console.error("Fallback also failed:", fallbackError)
        }
      }
    }
  }
}
