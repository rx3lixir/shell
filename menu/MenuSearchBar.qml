import QtQuick
import "../theme"

Rectangle {
  id: root
  
  property alias text: searchInput.text
  signal searchChanged(string text)
  
  radius: Theme.radius.full
  color: Theme.surface_container_high
  //border.width: 2
  //border.color: searchInput.activeFocus ? Theme.primary : "transparent"
  
  Behavior on border.color {
    ColorAnimation {
      duration: 200
      easing.type: Easing.OutCubic
    }
  }
  
  TextInput {
    id: searchInput
    anchors {
      fill: parent
      leftMargin: Theme.padding.lg
      rightMargin: Theme.padding.lg
    }
    verticalAlignment: TextInput.AlignVCenter
    color: Theme.on_surface
    font.pixelSize: Theme.typography.md
    font.family: Theme.typography.fontFamily
    
    // Placeholder text
    Text {
      anchors.fill: parent
      text: "Search menu..."
      color: Theme.on_surface_variant
      font: parent.font
      verticalAlignment: Text.AlignVCenter
      visible: !parent.text
      opacity: 0.6
    }
    
    onTextChanged: {
      root.searchChanged(text)
    }
    
    Component.onCompleted: {
      forceActiveFocus()
    }
  }
}
