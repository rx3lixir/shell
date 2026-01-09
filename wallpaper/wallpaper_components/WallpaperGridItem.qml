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
      margins: Theme.spacing.sm
    }
    radius: Theme.radius.xl
    
    // Material 3 color states
    color: {
      if (root.isSelected) return Theme.primary_container
      if (itemMouseArea.containsMouse) return Theme.surface_container_high
      return Theme.surface_container
    }
    
    border.width: root.isCurrent ? 3 : 1
    border.color: root.isCurrent ? Theme.primary : Theme.surface_container_high
    
    scale: itemMouseArea.pressed ? 0.95 : 1.0
    
    Behavior on color {
      ColorAnimation {
        duration: 200
        easing.type: Easing.OutCubic
      }
    }
    
    Behavior on border.color {
      ColorAnimation {
        duration: 200
        easing.type: Easing.OutCubic
      }
    }
    
    Behavior on scale {
      NumberAnimation {
        duration: 100
        easing.type: Easing.OutCubic
      }
    }
    
    ColumnLayout {
      anchors {
        fill: parent
        margins: Theme.spacing.sm
      }
      spacing: Theme.spacing.sm
      
      // ========== IMAGE PREVIEW ==========
      Rectangle {
        id: imageContainer
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.margins: Theme.spacing.sm // Add margins to pull image away from edges
        radius: Theme.radius.lg
        color: Theme.surface_container_low
        clip: true
        
        // Enable layer rendering on the container to properly clip the image
        layer.enabled: true
        layer.smooth: true
        
        Image {
          id: previewImage
          anchors.fill: parent
          anchors.margins: 0
          source: "file://" + root.wallpaperPath
          fillMode: Image.PreserveAspectCrop
          smooth: true
          cache: true
          asynchronous: true
          
          // Thumbnail quality for faster loading
          sourceSize.width: 280
          sourceSize.height: 200
        }
        
        // Loading indicator
        Item {
          anchors.centerIn: parent
          width: 48
          height: 48
          visible: previewImage.status === Image.Loading
          
          Rectangle {
            anchors.centerIn: parent
            width: 40
            height: 40
            radius: Theme.radius.full
            color: Theme.primary_container
            
            Text {
              anchors.centerIn: parent
              text: "󰄉"
              color: Theme.on_primary_container
              font.pixelSize: Theme.typography.xl
              font.family: Theme.typography.fontFamily
            }
          }
        }
        
        // Error indicator
        Item {
          anchors.centerIn: parent
          width: parent.width
          height: 80
          visible: previewImage.status === Image.Error
          
          ColumnLayout {
            anchors.centerIn: parent
            spacing: Theme.spacing.xs
            
            Rectangle {
              Layout.alignment: Qt.AlignHCenter
              Layout.preferredWidth: 40
              Layout.preferredHeight: 40
              radius: Theme.radius.full
              color: Theme.error_container
              
              Text {
                anchors.centerIn: parent
                text: "󰀪"
                color: Theme.on_error_container
                font.pixelSize: Theme.typography.xl
                font.family: Theme.typography.fontFamily
              }
            }
            
            Text {
              Layout.alignment: Qt.AlignHCenter
              text: "Failed to load"
              color: Theme.error
              font.pixelSize: Theme.typography.xs
              font.family: Theme.typography.fontFamily
            }
          }
        }
        
        // ========== CURRENT WALLPAPER BADGE ==========
        Rectangle {
          anchors {
            top: parent.top
            right: parent.right
            margins: Theme.spacing.sm
          }
          width: 32
          height: 32
          radius: Theme.radius.full
          color: Theme.primary
          visible: root.isCurrent
          
          Text {
            anchors.centerIn: parent
            text: "✓"
            color: Theme.on_primary
            font.pixelSize: Theme.typography.md
            font.family: Theme.typography.fontFamily
            font.weight: Theme.typography.weightMedium
          }
        }
        
        // ========== SELECTED INDICATOR (keyboard nav) ==========
        Rectangle {
          anchors {
            top: parent.top
            left: parent.left
            margins: Theme.spacing.sm
          }
          width: 32
          height: 32
          radius: Theme.radius.full
          color: Theme.primary
          visible: root.isSelected && !root.isCurrent
          
          Text {
            anchors.centerIn: parent
            text: "→"
            color: Theme.on_primary
            font.pixelSize: Theme.typography.md
            font.family: Theme.typography.fontFamily
            font.weight: Theme.typography.weightMedium
          }
        }
      }
      
      // ========== FILENAME ==========
      Text {
        Layout.fillWidth: true
        text: root.filename
        color: {
          if (root.isCurrent) return Theme.primary
          if (root.isSelected) return Theme.on_primary_container
          return Theme.on_surface
        }
        font.pixelSize: Theme.typography.sm
        font.family: Theme.typography.fontFamily
        font.weight: root.isCurrent || root.isSelected ? Theme.typography.weightMedium : Theme.typography.weightNormal
        elide: Text.ElideMiddle
        horizontalAlignment: Text.AlignHCenter
        
        Behavior on color {
          ColorAnimation {
            duration: 200
            easing.type: Easing.OutCubic
          }
        }
      }
    }
    
    // ========== INTERACTION ==========
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
