import QtQuick
import QtQuick.Layouts
import Quickshell
import "../theme"
import "../components"

Rectangle {
  id: root
  
  required property var app
  property bool isSelected: false
  signal launched()
  signal clicked()
  
  radius: Theme.radius.xl
  color: "transparent"
  
  RowLayout {
    id: contentLayout
    anchors {
      fill: parent
      margins: Theme.padding.md
    }
    spacing: Theme.spacing.md
    
    // Icon using IconCircle component
    IconCircle {
      Layout.preferredWidth: 48
      Layout.preferredHeight: 48
      Layout.alignment: Qt.AlignVCenter
      
      // Use first letter of app name as icon
      icon: root.app.name ? root.app.name.charAt(0).toUpperCase() : "?"
      iconSize: Theme.typography.xxl
      bgColor: isSelected ? Theme.secondary : Theme.secondary_container
      iconColor: isSelected ? Theme.on_secondary : Theme.secondary
    }
    
    // Text info
    ColumnLayout {
      Layout.fillWidth: true
      Layout.alignment: Qt.AlignVCenter
      spacing: 2
      
      Text {
        Layout.fillWidth: true
        text: root.app.name || "Unknown"
        color: Theme.on_surface
        font.pixelSize: Theme.typography.md
        font.family: Theme.typography.fontFamily
        font.weight: Theme.typography.weightMedium
        elide: Text.ElideRight
      }
      
      Text {
        Layout.fillWidth: true
        text: root.app.comment || ""
        color: Theme.on_surface_variant
        font.pixelSize: Theme.typography.sm
        font.family: Theme.typography.fontFamily
        opacity: 0.7
        elide: Text.ElideRight
        visible: text !== ""
      }
    }
  }
  
  MouseArea {
    id: mouseArea
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    
    onClicked: {
      // Notify parent that this item was clicked
      root.clicked()
      
      // Try execute() first
      try {
        root.app.execute()
        root.launched()
      } catch (error) {
        console.error("execute() failed:", error)
        // Fallback: try execDetached
        try {
          Quickshell.execDetached({
            command: root.app.command,
            workingDirectory: root.app.workingDirectory || ""
          })
          root.launched()
        } catch (fallbackError) {
          console.error("Fallback also failed:", fallbackError)
        }
      }
    }
  }
}
