import QtQuick
import QtQuick.Layouts
import "../../theme"

Item {
  id: root
  
  // Properties
  property string emoji: ""
  property string name: ""
  property int itemIndex: 0
  property bool isSelected: false
  
  // Signal
  signal clicked()
  
  Rectangle {
    anchors {
      fill: parent
      margins: Theme.spacingXS
    }
    radius: Theme.radiusLarge
    color: {
      if (root.isSelected) return Theme.accent
      if (itemMouseArea.containsMouse) return Theme.bg2
      return "transparent"
    }
    
    Behavior on color {
      ColorAnimation {
        duration: 150
        easing.type: Easing.OutCubic
      }
    }
    
    ColumnLayout {
      anchors.fill: parent
      spacing: 2
      
      // Emoji
      Text {
        Layout.fillWidth: true
        Layout.fillHeight: true
        text: root.emoji
        color: Theme.fg
        font.pixelSize: 32
        font.family: Theme.fontFamily
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
      }
      
      // Name tooltip on hover
      Text {
        Layout.fillWidth: true
        Layout.preferredHeight: 16
        text: root.name
        color: root.isSelected ? Theme.bg1 : Theme.fgMuted
        font.pixelSize: Theme.fontSizeXS
        font.family: Theme.fontFamily
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
        visible: itemMouseArea.containsMouse || root.isSelected
        
        Behavior on color {
          ColorAnimation {
            duration: 150
            easing.type: Easing.OutCubic
          }
        }
      }
    }
    
    MouseArea {
      id: itemMouseArea
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      
      onClicked: {
        root.clicked()
      }
    }
  }
}
