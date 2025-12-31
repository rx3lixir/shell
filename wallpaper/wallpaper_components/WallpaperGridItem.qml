import QtQuick
import QtQuick.Layouts
import "../../theme"

Item {
  id: root
  
  // Properties
  property string filename: ""
  property int itemIndex: 0
  property bool isSelected: false
  property bool isCurrent: false
  property string wallpaperPath: ""
  
  // Signal
  signal clicked()
  
  Rectangle {
    anchors {
      fill: parent
      margins: Theme.spacingS
    }
    radius: Theme.radiusLarge
    color: {
      if (root.isSelected) return Theme.accent
      if (itemMouseArea.containsMouse) return Theme.bg2
      return Theme.bg2transparent
    }
    border.color: root.isCurrent ? Theme.accent : "transparent"
    border.width: 3
    
    Behavior on color {
      ColorAnimation {
        duration: 150
        easing.type: Easing.OutCubic
      }
    }
    
    ColumnLayout {
      anchors {
        fill: parent
        margins: Theme.spacingS
      }
      spacing: Theme.spacingS
      
      // Image preview
      Rectangle {
        Layout.fillWidth: true
        Layout.fillHeight: true
        radius: Theme.radiusMedium
        color: Theme.bg1
        clip: true
        
        Image {
          anchors.fill: parent
          source: "file://" + root.wallpaperPath
          fillMode: Image.PreserveAspectCrop
          smooth: true
          cache: true
          asynchronous: true
          
          // Use lower source size for faster loading (thumbnail quality)
          sourceSize.width: 280
          sourceSize.height: 200
          
          // Loading indicator
          Rectangle {
            anchors.centerIn: parent
            width: 32
            height: 32
            radius: 16
            color: Theme.accentTransparent
            visible: parent.status === Image.Loading
            
            Text {
              anchors.centerIn: parent
              text: "⏳"
              color: Theme.fg
              font.pixelSize: Theme.fontSizeM
              font.family: Theme.fontFamily
            }
          }
          
          // Error indicator
          Text {
            anchors.centerIn: parent
            text: "❌ Failed"
            color: Theme.error
            font.pixelSize: Theme.fontSizeS
            font.family: Theme.fontFamily
            visible: parent.status === Image.Error
          }
        }
        
        // Current wallpaper indicator
        Rectangle {
          anchors {
            top: parent.top
            right: parent.right
            margins: Theme.spacingS
          }
          width: 28
          height: 28
          radius: 14
          color: Theme.accent
          visible: root.isCurrent
          
          Text {
            anchors.centerIn: parent
            text: "✓"
            color: Theme.bg1
            font.pixelSize: Theme.fontSizeM
            font.family: Theme.fontFamily
            font.bold: true
          }
        }
        
        // Selected indicator (keyboard nav)
        Rectangle {
          anchors {
            top: parent.top
            left: parent.left
            margins: Theme.spacingS
          }
          width: 28
          height: 28
          radius: 14
          color: Theme.accent
          visible: root.isSelected && !root.isCurrent
          
          Text {
            anchors.centerIn: parent
            text: "→"
            color: Theme.bg1
            font.pixelSize: Theme.fontSizeM
            font.family: Theme.fontFamily
            font.bold: true
          }
        }
      }
      
      // Filename
      Text {
        Layout.fillWidth: true
        text: root.filename
        color: {
          if (root.isSelected) return Theme.bg1
          if (root.isCurrent) return Theme.accent
          return Theme.fg
        }
        font.pixelSize: Theme.fontSizeS
        font.family: Theme.fontFamily
        elide: Text.ElideMiddle
        horizontalAlignment: Text.AlignHCenter
        
        Behavior on color {
          ColorAnimation {
            duration: 150
            easing.type: Easing.OutCubic
          }
        }
      }
    }
    
    MouseArea {
      id: itemMouseArea
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      
      onClicked: {
        root.clicked()
      }
    }
  }
}
