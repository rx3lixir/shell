import QtQuick
import QtQuick.Layouts
import "../../theme"

Item {
  id: root
  
  required property var utilitiesManager 
  
  ColumnLayout {
    anchors.fill: parent
    spacing: 16
    
    // Header
    Text {
      text: "Quick Actions"
      color: Theme.fg
      font.pixelSize: 15
      font.family: Theme.fontFamily
      font.weight: Font.Medium
      opacity: 0.9
    }
    
    // Buttons grid - 4 columns for more compact look
    GridLayout {
      Layout.fillWidth: true
      Layout.fillHeight: true
      columns: 4
      rowSpacing: 16
      columnSpacing: 16
      
      // Color Picker
      ColumnLayout {
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignHCenter
        spacing: 8
        
        Rectangle {
          Layout.alignment: Qt.AlignHCenter
          Layout.preferredWidth: 56
          Layout.preferredHeight: 56
          radius: 28
          color: pickerMouseArea.containsMouse ? Theme.accentTransparent : Theme.bg2transparent
          border.width: 2
          border.color: pickerMouseArea.containsMouse ? Theme.accent : Theme.border
          
          scale: pickerMouseArea.pressed ? 0.92 : 1.0
          
          Behavior on color {
            ColorAnimation { duration: 200 }
          }
          
          Behavior on border.color {
            ColorAnimation { duration: 200 }
          }
          
          Behavior on scale {
            NumberAnimation { 
              duration: 100
              easing.type: Easing.OutCubic
            }
          }
          
          Text {
            anchors.centerIn: parent
            text: "󰈊"
            color: pickerMouseArea.containsMouse ? Theme.accent : Theme.fg
            font.pixelSize: 24
            font.family: Theme.fontFamily
            
            Behavior on color {
              ColorAnimation { duration: 200 }
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
        
        Text {
          Layout.alignment: Qt.AlignHCenter
          text: "Picker"
          color: pickerMouseArea.containsMouse ? Theme.accent : Theme.fgMuted
          font.pixelSize: 11
          font.family: Theme.fontFamily
          
          Behavior on color {
            ColorAnimation { duration: 200 }
          }
        }
      }
      
      // Screenshot
      ColumnLayout {
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignHCenter
        spacing: 8
        
        Rectangle {
          Layout.alignment: Qt.AlignHCenter
          Layout.preferredWidth: 56
          Layout.preferredHeight: 56
          radius: 28
          color: screenshotMouseArea.containsMouse ? Theme.accentTransparent : Theme.bg2transparent
          border.width: 2
          border.color: screenshotMouseArea.containsMouse ? Theme.accent : Theme.border
          
          scale: screenshotMouseArea.pressed ? 0.92 : 1.0
          
          Behavior on color {
            ColorAnimation { duration: 200 }
          }
          
          Behavior on border.color {
            ColorAnimation { duration: 200 }
          }
          
          Behavior on scale {
            NumberAnimation { 
              duration: 100
              easing.type: Easing.OutCubic
            }
          }
          
          Text {
            anchors.centerIn: parent
            text: "󱣴"
            color: screenshotMouseArea.containsMouse ? Theme.accent : Theme.fg
            font.pixelSize: 24
            font.family: Theme.fontFamily
            
            Behavior on color {
              ColorAnimation { duration: 200 }
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
        
        Text {
          Layout.alignment: Qt.AlignHCenter
          text: "Screenshot"
          color: screenshotMouseArea.containsMouse ? Theme.accent : Theme.fgMuted
          font.pixelSize: 11
          font.family: Theme.fontFamily
          
          Behavior on color {
            ColorAnimation { duration: 200 }
          }
        }
      }
      
      // Night Light toggle
      ColumnLayout {
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignHCenter
        spacing: 8
        
        Rectangle {
          Layout.alignment: Qt.AlignHCenter
          Layout.preferredWidth: 56
          Layout.preferredHeight: 56
          radius: 28
          color: {
            if (utilitiesManager.nightLightActive) {
              return nightLightMouseArea.containsMouse ? Theme.accent : "#90FF7E9C"
            }
            return nightLightMouseArea.containsMouse ? Theme.accentTransparent : Theme.bg2transparent
          }
          border.width: 2
          border.color: utilitiesManager.nightLightActive ? Theme.accent : 
            (nightLightMouseArea.containsMouse ? Theme.accent : Theme.border)
          
          scale: nightLightMouseArea.pressed ? 0.92 : 1.0
          
          Behavior on color {
            ColorAnimation { duration: 200 }
          }
          
          Behavior on border.color {
            ColorAnimation { duration: 200 }
          }
          
          Behavior on scale {
            NumberAnimation { 
              duration: 100
              easing.type: Easing.OutCubic
            }
          }
          
          // Subtle glow when active
          Rectangle {
            anchors.centerIn: parent
            width: parent.width + 8
            height: parent.height + 8
            radius: (parent.width + 8) / 2
            color: "transparent"
            border.width: utilitiesManager.nightLightActive ? 8 : 0
            border.color: "#30FF7E9C"
            opacity: utilitiesManager.nightLightActive ? 1 : 0
            z: -1
            
            Behavior on opacity {
              NumberAnimation { duration: 300 }
            }
          }
          
          Text {
            anchors.centerIn: parent
            text: utilitiesManager.nightLightActive ? "󱩌" : "󰹏"
            color: utilitiesManager.nightLightActive ? 
              (nightLightMouseArea.containsMouse ? Theme.bg1 : Theme.bg1) : 
              (nightLightMouseArea.containsMouse ? Theme.accent : Theme.fg)
            font.pixelSize: 24
            font.family: Theme.fontFamily
            
            Behavior on color {
              ColorAnimation { duration: 200 }
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
        
        Text {
          Layout.alignment: Qt.AlignHCenter
          text: "Night Light"
          color: utilitiesManager.nightLightActive ? Theme.accent : 
            (nightLightMouseArea.containsMouse ? Theme.accent : Theme.fgMuted)
          font.pixelSize: 11
          font.family: Theme.fontFamily
          
          Behavior on color {
            ColorAnimation { duration: 200 }
          }
        }
      }
      
      // Clipboard Manager
      ColumnLayout {
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignHCenter
        spacing: 8
        
        Rectangle {
          Layout.alignment: Qt.AlignHCenter
          Layout.preferredWidth: 56
          Layout.preferredHeight: 56
          radius: 28
          color: clipboardMouseArea.containsMouse ? Theme.accentTransparent : Theme.bg2transparent
          border.width: 2
          border.color: clipboardMouseArea.containsMouse ? Theme.accent : Theme.border
          
          scale: clipboardMouseArea.pressed ? 0.92 : 1.0
          
          Behavior on color {
            ColorAnimation { duration: 200 }
          }
          
          Behavior on border.color {
            ColorAnimation { duration: 200 }
          }
          
          Behavior on scale {
            NumberAnimation { 
              duration: 100
              easing.type: Easing.OutCubic
            }
          }
          
          Text {
            anchors.centerIn: parent
            text: "󰅍"
            color: clipboardMouseArea.containsMouse ? Theme.accent : Theme.fg
            font.pixelSize: 24
            font.family: Theme.fontFamily
            
            Behavior on color {
              ColorAnimation { duration: 200 }
            }
          }
          
          MouseArea {
            id: clipboardMouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            
            onClicked: {
              utilitiesManager.openClipboard()
            }
          }
        }
        
        Text {
          Layout.alignment: Qt.AlignHCenter
          text: "Clipboard"
          color: clipboardMouseArea.containsMouse ? Theme.accent : Theme.fgMuted
          font.pixelSize: 11
          font.family: Theme.fontFamily
          
          Behavior on color {
            ColorAnimation { duration: 200 }
          }
        }
      }
    }
  }
}
