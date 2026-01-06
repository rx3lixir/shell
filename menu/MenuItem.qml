import QtQuick
import QtQuick.Layouts
import "../theme"
import "../components"

Rectangle {
  id: root
  
  required property var item
  property bool isSelected: false
  signal clicked()
  signal activated()
  
  radius: Theme.radius.xl
  color: "transparent"
  
  RowLayout {
    id: contentLayout
    anchors {
      fill: parent
      margins: Theme.padding.md
    }

    spacing: Theme.spacing.md
    
    // Icon using IconCircle component
    IconCircle {
      Layout.preferredWidth: 48
      Layout.preferredHeight: 48
      Layout.alignment: Qt.AlignVCenter
      
      icon: root.item.icon
      iconSize: Theme.typography.xxl
      bgColor: isSelected ? Theme.primary : Theme.primary_container
      iconColor: isSelected ? Qt.darker(Theme.primary, 1.8) : Theme.primary
    }
    
    // Text info
    ColumnLayout {
      Layout.fillWidth: true
      Layout.alignment: Qt.AlignVCenter
      spacing: 2
      
      Text {
        Layout.fillWidth: true
        text: root.item.name
        color: Theme.on_surface
        font.pixelSize: Theme.typography.md
        font.family: Theme.typography.fontFamily
        font.weight: Theme.typography.weightMedium
        elide: Text.ElideRight
      }
      
      Text {
        Layout.fillWidth: true
        text: root.item.description
        color: Theme.on_surface_variant
        font.pixelSize: Theme.typography.sm
        font.family: Theme.typography.fontFamily
        opacity: 0.7
        elide: Text.ElideRight
      }
    }
  }
  
  MouseArea {
    id: mouseArea
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    
    onClicked: {
      root.activated()
    }
  }
}
