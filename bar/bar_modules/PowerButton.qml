import QtQuick
import QtQuick.Layouts
import "../../theme"

Item {
  id: root

  implicitWidth: childrenRect.width
  implicitHeight: Theme.barHeight
  
  Text {
    id: buttonText
    anchors.centerIn: parent
    text: "󰛸"
    color: Theme.accent
    font.pixelSize: Theme.fontSizeM
    font.family: Theme.fontFamily
    verticalAlignment: Text.AlignVCenter
  }
}
