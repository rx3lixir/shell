import QtQuick
import "../../theme"

Rectangle {
  id: root
  
  property alias text: searchInput.text
  signal searchChanged(string text)
  
  radius: Theme.radiusLarge
  color: Theme.bg2transparent
  border.color: searchInput.activeFocus ? Theme.accent : "transparent"
  border.width: 2
  
  TextInput {
    id: searchInput
    anchors {
      fill: parent
      leftMargin: Theme.spacingM
      rightMargin: Theme.spacingM
    }
    verticalAlignment: TextInput.AlignVCenter
    color: Theme.fg
    font.pixelSize: Theme.fontSizeM
    font.family: Theme.fontFamily
    
    // Placeholder
    Text {
      anchors.fill: parent
      text: "Search wallpapers..."
      color: Theme.fgMuted
      font: parent.font
      verticalAlignment: Text.AlignVCenter
      visible: !parent.text
    }
    
    onTextChanged: {
      root.searchChanged(text)
    }
    
    Component.onCompleted: {
      forceActiveFocus()
    }
  }
}
