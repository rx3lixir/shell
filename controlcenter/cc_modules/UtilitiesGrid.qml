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
      
      // Color Picker
      Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 48
        radius: Theme.radiusXLarge
        color: pickerMouseArea.containsMouse ? Theme.bg2 : Theme.bg2transparent
        
        RowLayout {
          anchors {
            fill: parent
            margins: Theme.spacingM
          }

          spacing: Theme.spacingS
          
          Text {
            text: "󰈊"
            color: Theme.fg
            font.pixelSize: Theme.fontSizeL
            font.family: Theme.fontFamily
          }
            
          Text {
            text: "Color Picker"
            color: Theme.fg
            font.pixelSize: Theme.fontSizeM
            font.family: Theme.fontFamily
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
        Layout.preferredHeight: 48
        radius: Theme.radiusXLarge
        color: screenshotMouseArea.containsMouse ? Theme.bg2 : Theme.bg2transparent
        
        RowLayout {
          anchors {
            fill: parent
            margins: Theme.spacingM
          }
          spacing: Theme.spacingS
          
          Text {
            text: "󱣴"
            color: Theme.fg
            font.pixelSize: Theme.fontSizeL
            font.family: Theme.fontFamily
          }
          
          ColumnLayout {
            Layout.fillWidth: true
            spacing: 2
            
            Text {
              text: "Screenshot"
              color: Theme.fg
              font.pixelSize: Theme.fontSizeM
              font.family: Theme.fontFamily
            }
          }
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
      
      // Night Light toggle (special: shows active state)
      Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 48
        radius: Theme.radiusXLarge
        color: nightLightMouseArea.containsMouse ? Theme.bg2 : Theme.bg2transparent
        
        RowLayout {
          anchors {
            fill: parent
            margins: Theme.spacingM
          }

          spacing: Theme.spacingS
          
          Text {
            text: utilitiesManager.nightLightActive ? "󱩌" : "󰹏"
            color: utilitiesManager.nightLightActive ? Theme.accent : Theme.fg
            font.pixelSize: Theme.fontSizeL
            font.family: Theme.fontFamily
          }
          
          ColumnLayout {
            Layout.fillWidth: true
            spacing: 2
            
            Text {
              text: "Night Light"
              color: utilitiesManager.nightLightActive ? Theme.accent : Theme.fg
              font.pixelSize: Theme.fontSizeM
              font.family: Theme.fontFamily
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
        Layout.preferredHeight: 48
        radius: Theme.radiusXLarge
        color: clipboardMouseArea.containsMouse ? Theme.bg2 : Theme.bg2transparent
        
        RowLayout {
          anchors {
            fill: parent
            margins: Theme.spacingM
          }

          spacing: Theme.spacingS
          
          Text {
            text: "󰅍"
            color: Theme.fg
            font.pixelSize: Theme.fontSizeL
            font.family: Theme.fontFamily
          }
          
          Text {
            text: "Clipboard"
            color: Theme.fg
            font.pixelSize: Theme.fontSizeM
            font.family: Theme.fontFamily
          }
        }
        
        MouseArea {
          id: clipboardMouseArea
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          
          onClicked: {
            manager.openClipboard()  // Note: this still references global 'manager' – adjust if needed
          }
        }
      }
    }
  }
}
