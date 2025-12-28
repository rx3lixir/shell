import QtQuick
import "../theme"

Rectangle {
  id: root
  
  property alias text: searchInput.text
  signal searchChanged(string text)
  
  color: "transparent"
  border.color: searchInput.activeFocus ? Theme.accent : "transparent"
  border.width: 0
  
  TextInput {
    id: searchInput
    anchors {
      fill: parent
      leftMargin: Theme.spacingM
      rightMargin: Theme.spacingM
    }
    verticalAlignment: TextInput.AlignVCenter
    color: Theme.fg
    font.pixelSize: Theme.fontSizeL
    font.family: Theme.fontFamily
    
    // Placeholder text
    Text {
      anchors.fill: parent
      text: "Search menu..."
      color: Theme.fgMuted
      font: parent.font
      verticalAlignment: Text.AlignVCenter
      visible: !parent.text
    }
    
    onTextChanged: {
      console.log("Menu search input changed:", text)
      root.searchChanged(text)
    }
    
    Component.onCompleted: {
      console.log("Menu search input loaded, setting focus")
      forceActiveFocus()
    }
  }
}
