import QtQuick
import QtQuick.Layouts
import "../../theme"

Rectangle {
  id: root
  
  // Properties
  property string themeName: ""
  property bool isSelected: false
  property bool isCurrent: false
  
  // Signal
  signal clicked()
  
  radius: Theme.radiusXLarge
  color: {
    if (isSelected) return Theme.accent
    if (mouseArea.containsMouse) return Theme.bg2transparent
    return "transparent"
  }
  
  Behavior on color {
    ColorAnimation {
      duration: 200
      easing.type: Easing.OutCubic
    }
  }
  
  RowLayout {
    anchors {
      fill: parent
      margins: Theme.spacingM
    }
    spacing: Theme.spacingM
    
    // Icon - first letter of theme name (like launcher)
    Rectangle {
      Layout.preferredWidth: 48
      Layout.preferredHeight: 48
      radius: Theme.radiusLarge
      color: isSelected ? Theme.fg : Theme.accentTransparent
      
      Behavior on color {
        ColorAnimation {
          duration: 200
          easing.type: Easing.OutCubic
        }
      }
      
      Text {
        anchors.centerIn: parent
        text: root.themeName ? root.themeName.charAt(0).toUpperCase() : "?"
        color: isSelected ? Theme.bg1 : Theme.fg
        font.pixelSize: Theme.fontSizeXL
        font.family: Theme.fontFamily
        font.bold: true
        
        Behavior on color {
          ColorAnimation {
            duration: 200
            easing.type: Easing.OutCubic
          }
        }
      }
    }
    
    // Theme name
    ColumnLayout {
      Layout.fillWidth: true
      spacing: 2
      
      Text {
        Layout.fillWidth: true
        text: root.themeName
        color: isSelected ? Theme.bg1 : Theme.fg
        font.pixelSize: Theme.fontSizeM
        font.family: Theme.fontFamily
        font.bold: true
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
        text: root.themeName === "Matugen" ? 
              "Dynamic theme from wallpaper" : 
              "Static color scheme"
        color: isSelected ? Theme.bg2 : Theme.fgMuted
        font.pixelSize: Theme.fontSizeS
        font.family: Theme.fontFamily
        elide: Text.ElideRight
        
        Behavior on color {
          ColorAnimation {
            duration: 200
            easing.type: Easing.OutCubic
          }
        }
      }
    }
    
    // Current theme indicator
    Rectangle {
      Layout.preferredWidth: 32
      Layout.preferredHeight: 32
      radius: 16
      color: isSelected ? Theme.fg : Theme.accent
      visible: root.isCurrent
      
      Behavior on color {
        ColorAnimation {
          duration: 200
          easing.type: Easing.OutCubic
        }
      }
      
      Text {
        anchors.centerIn: parent
        text: "✓"
        color: isSelected ? Theme.bg1 : Theme.bg1
        font.pixelSize: Theme.fontSizeM
        font.family: Theme.fontFamily
        font.bold: true
        
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
    id: mouseArea
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    
    onClicked: {
      root.clicked()
    }
  }
}
