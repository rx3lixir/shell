// components/Card.qml
import QtQuick
import "../theme"

Rectangle {
  id: root

  property alias radius: root.radius
  property alias color: root.color
  property alias border: root.border

  property int padding: Theme.padding.lg

  default property alias contentItem: content.data

  radius: Theme.radius.xl
  color: Theme.bg2
  border.width: 1
  border.color: Qt.darker(Theme.outline_variant, 1.2)

  Elevation {
    target: root
    visible: true 
  }

  // Content area
  Item {
    id: content
    anchors.fill: parent
    anchors.margins: root.padding
  }
}
