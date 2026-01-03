import QtQuick
import "../../theme"

Rectangle {
  id: root
  
  property alias text: searchInput.text
  signal searchChanged(string text)
  
  radius: Theme.radiusLarge
  color: Theme.bg2transparent
  
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
      text: "Search themes..."
      color: Theme.fgMuted
      font: parent.font
      verticalAlignment: Text.AlignVCenter
      visible: !parent.text
    }
    
    Timer {
      id: searchTimer
      interval: 150
      repeat: false
      onTriggered: root.searchChanged(searchInput.text)
    }
    
    onTextChanged: {
      searchTimer.restart()
    }
    
    Component.onCompleted: {
      forceActiveFocus()
    }
  }
}
