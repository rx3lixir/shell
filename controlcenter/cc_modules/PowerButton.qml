import QtQuick
import QtQuick.Layouts
import "../../theme"

Rectangle {
  id: root
  
  required property var powerMenuManager
  
  radius: Theme.radiusXLarge
  color: mouseArea.containsMouse ? Theme.bg2 : Theme.bg2transparent
  
  RowLayout {
    anchors {
      fill: parent
      margins: Theme.spacingM
    }
    spacing: Theme.spacingM
    
    Text {
      text: "󰐥"
      color: Theme.fg
      font.pixelSize: Theme.fontSizeXL
      font.family: Theme.fontFamily
    }
    
    ColumnLayout {
      Layout.fillWidth: true
      spacing: 2
      
      Text {
        text: "Power Menu"
        color: Theme.fg
        font.pixelSize: Theme.fontSizeM
        font.family: Theme.fontFamily
      }
      
      Text {
        text: "Power actions"
        color: Theme.fgMuted
        font.pixelSize: Theme.fontSizeS
        font.family: Theme.fontFamily
      }
    }
  }
  
  MouseArea {
    id: mouseArea
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    
    onClicked: {
      powerMenuManager.visible = true
    }
  }
}
