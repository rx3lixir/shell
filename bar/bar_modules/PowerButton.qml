import QtQuick
import QtQuick.Layouts
import "../../theme"

Item {
  id: root
  
  // Make it optional with a default, so we can debug better
  property var wlogoutWindow: null
  
  Component.onCompleted: {
    console.log("PowerButton.qml - wlogoutWindow is:", wlogoutWindow)
    console.log("PowerButton.qml - wlogoutWindow type:", typeof wlogoutWindow)
    if (wlogoutWindow === null) {
      console.error("ERROR: wlogoutWindow is null!")
    }
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
      console.log("PowerButton clicked!")
      
      if (wlogoutWindow === null) {
        console.error("Cannot toggle wlogout - window reference is null!")
        return
      }
      
      console.log("Current wlogout visible state:", wlogoutWindow.visible)
      wlogoutWindow.visible = !wlogoutWindow.visible
      console.log("New wlogout visible state:", wlogoutWindow.visible)
    }
  }
}
