import QtQuick
import QtQuick.Layouts
import "../../theme"

Item {
  id: root
  
  // Accept the wlogout window reference from Bar.qml
  required property var wlogoutWindow
  
  Component.onCompleted: {
    console.log("PowerButton.qml - wlogoutWindow is:", wlogoutWindow)
    console.log("PowerButton.qml - wlogoutWindow type:", typeof wlogoutWindow)
  }

  implicitWidth: childrenRect.width
  implicitHeight: Theme.barHeight
  
  Text {
    id: buttonText
    anchors.centerIn: parent
    text: "󰛸"
    color: mouseArea.containsMouse ? Theme.accent : Qt.darker(Theme.accent, 1.3)
    font.pixelSize: Theme.fontSizeM
    font.family: Theme.fontFamily
    verticalAlignment: Text.AlignVCenter
    
    // Smooth color transition on hover
    Behavior on color {
      ColorAnimation {
        duration: 200
        easing.type: Easing.OutCubic
      }
    }
  }
  
  MouseArea {
    id: mouseArea
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    
    onClicked: {
      // Toggle the wlogout visibility
      console.log("PowerButton clicked!")
      console.log("Current wlogout visible state:", wlogoutWindow.visible)
      wlogoutWindow.visible = !wlogoutWindow.visible
      console.log("New wlogout visible state:", wlogoutWindow.visible)
    }
  }
}
