import QtQuick
import QtQuick.Layouts
import "../theme"

Rectangle {
  id: root
  
  required property var item
  property bool isSelected: false
  signal clicked()
  signal activated()
  
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
    
    // Icon
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
        text: root.item.icon
        color: isSelected ? Theme.bg1 : Theme.fg
        font.pixelSize: Theme.fontSizeXL
        font.family: Theme.fontFamily
        
        Behavior on color {
          ColorAnimation {
            duration: 200
            easing.type: Easing.OutCubic
          }
        }
      }
    }
    
    // Text info
    ColumnLayout {
      Layout.fillWidth: true
      spacing: 2
      
      Text {
        Layout.fillWidth: true
        text: root.item.name
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
        text: root.item.description
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
  }
  
  MouseArea {
    id: mouseArea
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    
    onClicked: {
      root.clicked()
      root.activated()
    }
  }
}
