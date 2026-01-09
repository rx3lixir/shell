import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import "../theme"

LazyLoader {
  id: loader
  
  required property var manager
  
  active: manager.visible
  
  PanelWindow {
    id: themeWindow
    
    // Fill screen - theme picker will be centered
    anchors {
      top: true
      left: true
      bottom: true
      right: true
    }
    
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    
    color: "transparent"
    mask: null
    
    Component.onCompleted: {
      exclusiveZone = 0
    }
    
    // Selection state
    property int selectedIndex: loader.manager.currentMode === "light" ? 0 : 1
    
    // Handle keyboard navigation
    contentItem {
      focus: true
      
      Keys.onPressed: event => {
        if (event.key === Qt.Key_Escape) {
          loader.manager.visible = false
          event.accepted = true
        }
        else if (event.key === Qt.Key_Up || event.key === Qt.Key_Left) {
          themeWindow.selectedIndex = 0  // Light
          event.accepted = true
        }
        else if (event.key === Qt.Key_Down || event.key === Qt.Key_Right) {
          themeWindow.selectedIndex = 1  // Dark
          event.accepted = true
        }
        else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
          var selected = loader.manager.themeOptions[themeWindow.selectedIndex]
          loader.manager.setTheme(selected.mode)
          event.accepted = true
        }
      }
    }
    
    // Background overlay
    Rectangle {
      anchors.fill: parent
      color: Theme.scrim
      opacity: 0.2
      
      MouseArea {
        anchors.fill: parent
        onClicked: loader.manager.visible = false
      }
    }
    
    // Theme picker container - centered
    Rectangle {
      id: container
      x: (parent.width - 500) / 2
      y: (parent.height - 300) / 2
      width: 500
      height: 300
      radius: Theme.radius.xl
      color: Theme.surface_container
      border.width: 1
      border.color: Qt.lighter(Theme.surface_container, 1.3)
      
      // Prevent clicks on container from closing
      MouseArea {
        anchors.fill: parent
      }
      
      ColumnLayout {
        anchors {
          fill: parent
          margins: Theme.padding.xl
        }
        spacing: Theme.spacing.lg
        
        // ====================================================================
        // HEADER
        // ====================================================================
        
        RowLayout {
          Layout.fillWidth: true
          spacing: Theme.spacing.sm
          
          Text {
            Layout.fillWidth: true
            text: "Choose Theme"
            color: Theme.on_surface
            font.pixelSize: Theme.typography.xl
            font.family: Theme.typography.fontFamily
            font.weight: Theme.typography.weightMedium
          }
          
          // Close button
          Rectangle {
            Layout.preferredWidth: 32
            Layout.preferredHeight: 32
            radius: Theme.radius.full
            color: closeMouseArea.containsMouse ? Theme.surface_container_high : "transparent"
            
            Text {
              anchors.centerIn: parent
              text: "✕"
              color: Theme.on_surface
              font.pixelSize: Theme.typography.lg
              font.family: Theme.typography.fontFamily
            }
            
            MouseArea {
              id: closeMouseArea
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              
              onClicked: {
                loader.manager.visible = false
              }
            }
          }
        }
        
        // ====================================================================
        // THEME OPTIONS
        // ====================================================================
        
        Row {
          Layout.fillWidth: true
          Layout.fillHeight: true
          spacing: Theme.spacing.lg
          
          Repeater {
            model: loader.manager.themeOptions
            
            delegate: Rectangle {
              required property var modelData
              required property int index
              
              width: (parent.width - Theme.spacing.lg) / 2
              height: parent.height
              
              radius: Theme.radius.xl
              color: {
                var isCurrent = loader.manager.currentMode === modelData.mode
                var isSelected = index === themeWindow.selectedIndex
                
                if (isCurrent) return modelData.color
                if (isSelected) return Theme.primary_container
                if (optionMouseArea.containsMouse) return Theme.surface_container_high
                return Theme.surface_container_low
              }
              
              border.width: {
                var isCurrent = loader.manager.currentMode === modelData.mode
                return isCurrent ? 3 : 1
              }
              border.color: {
                var isCurrent = loader.manager.currentMode === modelData.mode
                return isCurrent ? modelData.color : Theme.outline_variant
              }
              
              scale: optionMouseArea.pressed ? 0.95 : 1.0
              
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
                anchors.centerIn: parent
                spacing: Theme.spacing.md
                
                // Icon
                Text {
                  Layout.alignment: Qt.AlignHCenter
                  text: modelData.icon
                  color: {
                    var isCurrent = loader.manager.currentMode === modelData.mode
                    return isCurrent ? Theme.surface_container : Theme.on_surface
                  }
                  font.pixelSize: 64
                  font.family: Theme.typography.fontFamily
                  
                  Behavior on color {
                    ColorAnimation {
                      duration: 200
                      easing.type: Easing.OutCubic
                    }
                  }
                }
                
                // Name
                Text {
                  Layout.alignment: Qt.AlignHCenter
                  text: modelData.name
                  color: {
                    var isCurrent = loader.manager.currentMode === modelData.mode
                    return isCurrent ? Theme.surface_container : Theme.on_surface
                  }
                  font.pixelSize: Theme.typography.lg
                  font.family: Theme.typography.fontFamily
                  font.weight: Theme.typography.weightMedium
                  
                  Behavior on color {
                    ColorAnimation {
                      duration: 200
                      easing.type: Easing.OutCubic
                    }
                  }
                }
                
                // Description
                Text {
                  Layout.alignment: Qt.AlignHCenter
                  text: modelData.description
                  color: {
                    var isCurrent = loader.manager.currentMode === modelData.mode
                    return isCurrent ? Theme.surface_container_low : Theme.on_surface_variant
                  }
                  font.pixelSize: Theme.typography.sm
                  font.family: Theme.typography.fontFamily
                  opacity: 0.8
                  
                  Behavior on color {
                    ColorAnimation {
                      duration: 200
                      easing.type: Easing.OutCubic
                    }
                  }
                }
              }
              
              MouseArea {
                id: optionMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                
                onClicked: {
                  themeWindow.selectedIndex = index
                  loader.manager.setTheme(modelData.mode)
                }
                
                onEntered: {
                  themeWindow.selectedIndex = index
                }
              }
            }
          }
        }
        
        // ====================================================================
        // FOOTER
        // ====================================================================
        
        Text {
          Layout.fillWidth: true
          text: "Arrow keys Navigate • Enter Select • Esc Cancel"
          color: Theme.on_surface_variant
          font.pixelSize: Theme.typography.sm
          font.family: Theme.typography.fontFamily
          horizontalAlignment: Text.AlignHCenter
          opacity: 0.7
        }
      }
    }
  }
}
