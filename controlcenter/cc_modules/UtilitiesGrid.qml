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
      rowSpacing: Theme.spacingS
      columnSpacing: Theme.spacingS
      
      // Color picker
      Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 40
        radius: Theme.radiusXLarge
        color: pickerMouseArea.containsMouse ? Qt.darker(Theme.accent, 1.3) : Theme.accent
        
        Behavior on color {
          ColorAnimation {
            duration: 150
            easing.type: Easing.OutCubic
          }
        }
        
        RowLayout {
          anchors {
            fill: parent
            margins: Theme.spacingS
          }
          spacing: Theme.spacingS
          
          Text {
            text: "󰴱"
            color: Theme.fg
            font.pixelSize: Theme.fontSizeXL
            font.family: Theme.fontFamily
          }
          
          Text {
            Layout.fillWidth: true
            text: "Color Picker"
            color: Theme.fg
            font.pixelSize: Theme.fontSizeS
            font.family: Theme.fontFamily
            elide: Text.ElideRight
          }
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
        color: screenshotMouseArea.containsMouse ? Theme.accent : Theme.accentTransparent
        
        Behavior on color {
          ColorAnimation {
            duration: 150
            easing.type: Easing.OutCubic
          }
        }
        
        RowLayout {
          anchors {
            fill: parent
            margins: Theme.spacingS
          }
          spacing: Theme.spacingS
          
          Text {
            text: "󰹑"
            color: Theme.fg
            font.pixelSize: Theme.fontSizeL
            font.family: Theme.fontFamily
          }
          
          Text {
            Layout.fillWidth: true
            text: "Screenshot"
            color: Theme.fg
            font.pixelSize: Theme.fontSizeS
            font.family: Theme.fontFamily
            elide: Text.ElideRight
          }
        }
        
        MouseArea {
          id: screenshotMouseArea
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          
          onClicked: {
            console.log("Screenshot clicked")
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
        border.width: 1
        
        RowLayout {
          anchors {
            fill: parent
            margins: Theme.spacingS
          }
          spacing: Theme.spacingS
          
          Text {
            text: utilitiesManager.nightLightActive ? "󱩌" : "󰹐"
            color: utilitiesManager.nightLightActive ? Theme.accent : Theme.fg
            font.pixelSize: Theme.fontSizeL
            font.family: Theme.fontFamily
          }
          
          Text {
            Layout.fillWidth: true
            text: "Night Light"
            color: Theme.fg
            font.pixelSize: Theme.fontSizeS
            font.family: Theme.fontFamily
            elide: Text.ElideRight
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
        color: clipboardMouseArea.containsMouse ? Theme.accent : Theme.accentTransparent
        
        Behavior on color {
          ColorAnimation {
            duration: 150
            easing.type: Easing.OutCubic
          }
        }
        
        RowLayout {
          anchors {
            fill: parent
            margins: Theme.spacingS
          }
          spacing: Theme.spacingS
          
          Text {
            text: "󰨸"
            color: Theme.fg
            font.pixelSize: Theme.fontSizeL
            font.family: Theme.fontFamily
          }
          
          Text {
            Layout.fillWidth: true
            text: "Clipboard"
            color: Theme.fg
            font.pixelSize: Theme.fontSizeS
            font.family: Theme.fontFamily
            elide: Text.ElideRight
          }
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
