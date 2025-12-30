import QtQuick
import QtQuick.Layouts
import "../../theme"

Rectangle {
  id: root
  
  required property var utilitiesManager 
  
  radius: Theme.radiusXLarge
  color: Theme.bg2transparent
  
  ColumnLayout {
    anchors {
      fill: parent
      margins: Theme.spacingM
    }
    spacing: Theme.spacingS
    
    // Header
    Text {
      text: "Utilities"
      color: Theme.fg
      font.pixelSize: Theme.fontSizeM
      font.family: Theme.fontFamily
      font.bold: true
    }
    
    // Buttons grid - 2 columns
    GridLayout {
      Layout.fillWidth: true
      columns: 2
      rowSpacing: Theme.spacingM
      columnSpacing: Theme.spacingM
      
      // Color picker
      Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 40
        radius: Theme.radiusXLarge
        color: pickerMouseArea.containsMouse ? Qt.darker(Theme.accent, 1.8) : Qt.darker(Theme.accent, 1.6)
        
        Behavior on color {
          ColorAnimation {
            duration: 200
            easing.type: Easing.OutCubic
          }
        }
        
        RowLayout {
          anchors.verticalCenter: parent.verticalCenter
          anchors.horizontalCenter: parent.horizontalCenter
          spacing: Theme.spacingS

          Item { Layout.fillWidth: true }

          Text {
            text: ""
            color: Theme.fg
            font.pixelSize: Theme.fontSizeL
            font.family: Theme.fontFamily
          }
          
          Text {
            text: "Color Picker"
            color: Theme.fg
            font.pixelSize: Theme.fontSizeS
            font.family: Theme.fontFamily
          }

          Item { Layout.fillWidth: true }
        }
        
        MouseArea {
          id: pickerMouseArea
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          
          onClicked: {
            utilitiesManager.launchColorPicker()
          }
        }
      }
      
      // Screenshot
      Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 40
        radius: Theme.radiusXLarge
        color: screenshotMouseArea.containsMouse ? Qt.darker(Theme.accent, 1.8) : Qt.darker(Theme.accent, 1.6)
        
        Behavior on color {
          ColorAnimation {
            duration: 200 
            easing.type: Easing.OutCubic
          }
        }
        
        RowLayout {
          anchors.verticalCenter: parent.verticalCenter
          anchors.horizontalCenter: parent.horizontalCenter
          spacing: Theme.spacingS

          Item { Layout.fillWidth: true }

          Text {
            text: "󰹑"
            color: Theme.fg
            font.pixelSize: Theme.fontSizeL
            font.family: Theme.fontFamily
          }
          
          Text {
            text: "Screenshot"
            color: Theme.fg
            font.pixelSize: Theme.fontSizeS
            font.family: Theme.fontFamily
          }

          Item { Layout.fillWidth: true }
        }
        
        MouseArea {
          id: screenshotMouseArea
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          
          onClicked: {
            utilitiesManager.takeScreenshot()
          }
        }
      }
      
      // Night Light toggle
      Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 40
        radius: Theme.radiusXLarge
        color: nightLightMouseArea.containsMouse ? Theme.bg1 : "transparent"
        border.color: utilitiesManager.nightLightActive ? Theme.accent : Theme.border
        border.width: 2
        
        RowLayout {
          anchors.verticalCenter: parent.verticalCenter
          anchors.horizontalCenter: parent.horizontalCenter
          spacing: Theme.spacingS

          Item { Layout.fillWidth: true }

          Text {
            text: utilitiesManager.nightLightActive ? "󱩌" : "󰹐"
            color: utilitiesManager.nightLightActive ? Theme.accent : Theme.fg
            font.pixelSize: Theme.fontSizeL
            font.family: Theme.fontFamily
          }
          
          Text {
            text: "Night Light"
            color: Theme.fg
            font.pixelSize: Theme.fontSizeS
            font.family: Theme.fontFamily
          }
          
          Rectangle {
            width: 8
            height: 8
            radius: 4
            color: utilitiesManager.nightLightActive ? Theme.accent : Theme.fgMuted
            
            Behavior on color {
              ColorAnimation {
                duration: 200
                easing.type: Easing.OutCubic
              }
            }
          }

          Item { Layout.fillWidth: true }
        }
        
        MouseArea {
          id: nightLightMouseArea
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          
          onClicked: {
            utilitiesManager.toggleNightLight()
          }
        }
      }
      
      // Clipboard Manager
      Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 40
        radius: Theme.radiusXLarge
        color: clipboardMouseArea.containsMouse ? Qt.darker(Theme.accent, 1.8) : Qt.darker(Theme.accent, 1.6)
        
        Behavior on color {
          ColorAnimation {
            duration: 200
            easing.type: Easing.OutCubic
          }
        }
        
        RowLayout {
          anchors.verticalCenter: parent.verticalCenter
          anchors.horizontalCenter: parent.horizontalCenter
          spacing: Theme.spacingS

          Item { Layout.fillWidth: true }

          Text {
            text: "󰨸"
            color: Theme.fg
            font.pixelSize: Theme.fontSizeL
            font.family: Theme.fontFamily
          }
          
          Text {
            text: "Clipboard"
            color: Theme.fg
            font.pixelSize: Theme.fontSizeS
            font.family: Theme.fontFamily
          }

          Item { Layout.fillWidth: true }
        }
        
        MouseArea {
          id: clipboardMouseArea
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          
          onClicked: {
            manager.openClipboard()
          }
        }
      }
    }
  }
}
