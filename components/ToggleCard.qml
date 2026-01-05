import QtQuick
import QtQuick.Layouts
import "../theme"

Rectangle {
  id: root
  
  // Public API
  required property string icon
  required property string title
  required property string subtitle
  required property bool isActive
  signal clicked()
  
  // Optional customization
  property color activeIconBg: Theme.primary_container
  property color activeIconColor: Theme.primary
  property color inactiveIconBg: Theme.surface_container_high
  property color inactiveIconColor: Theme.on_surface_variant
  
  radius: Theme.radius.xxl
  color: mouseArea.containsMouse ? Qt.darker(Theme.surface_container_low, 1.1) : Theme.surface_container_low
  border.width: 1
  border.color: Theme.outline_variant
  
  Behavior on color {
    ColorAnimation { duration: 200 }
  }
  
  // Shadow layers for depth
  Rectangle {
    anchors.fill: parent
    anchors.margins: -2
    radius: parent.radius + 2
    color: "transparent"
    border.width: 2
    border.color: Theme.scrim_transparent
    z: -1
    opacity: mouseArea.containsMouse ? 1 : 0.6
    
    Behavior on opacity {
      NumberAnimation { duration: 200 }
    }
  }
  
  Rectangle {
    anchors.fill: parent
    anchors.margins: -4
    radius: parent.radius + 4
    color: "transparent"
    border.width: 2
    border.color: "#15000000"
    z: -2
    opacity: mouseArea.containsMouse ? 0.8 : 0.4
    
    Behavior on opacity {
      NumberAnimation { duration: 200 }
    }
  }
  
  RowLayout {
    anchors {
      fill: parent
      topMargin: Theme.padding.sm
      bottomMargin: Theme.padding.sm
      leftMargin: Theme.padding.lg
      rightMargin: Theme.padding.lg
    }
    spacing: Theme.spacing.sm
    
    // Icon container
    Rectangle {
      Layout.preferredWidth: 40
      Layout.preferredHeight: 40
      Layout.alignment: Qt.AlignVCenter
      radius: Theme.radius.full
      
      scale: mouseArea.pressed ? 0.9 : 1.0
      
      Behavior on scale {
        NumberAnimation { 
          duration: 150
          easing.type: Easing.OutCubic
        }
      }
      
      color: root.isActive ? root.activeIconBg : root.inactiveIconBg
      
      Behavior on color {
        ColorAnimation { duration: 200 }
      }
      
      Text {
        anchors.centerIn: parent
        text: root.icon
        font.pixelSize: Theme.typography.xl
        font.family: Theme.typography.fontFamily
        color: root.isActive ? root.activeIconColor : root.inactiveIconColor
        
        Behavior on color {
          ColorAnimation { duration: 200 }
        }
      }
    }
    
    // Text content
    ColumnLayout {
      Layout.fillWidth: true
      Layout.alignment: Qt.AlignVCenter
      spacing: 2
      
      Text {
        text: root.title
        color: Theme.on_surface
        opacity: root.isActive ? 1 : 0.8
        font.pixelSize: Theme.typography.md
        font.family: Theme.typography.fontFamily
        font.weight: Theme.typography.weightMedium
        
        Behavior on opacity {
          NumberAnimation { duration: 200 }
        }
      }
      
      Text {
        text: root.subtitle
        color: root.isActive ? Theme.primary : Theme.on_surface_variant
        font.pixelSize: Theme.typography.sm
        font.family: Theme.typography.fontFamily
        opacity: 0.8
        
        Behavior on color {
          ColorAnimation { duration: 200 }
        }
      }
    }
  }
  
  MouseArea {
    id: mouseArea
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onClicked: root.clicked()
  }
}
