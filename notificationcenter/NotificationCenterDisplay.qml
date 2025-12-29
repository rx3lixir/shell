import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import "../theme"

LazyLoader {
  id: loader
  
  required property var manager
  
  // Load when visible
  active: manager.visible
  
  PanelWindow {
    id: notifCenterWindow
    
    anchors {
      top: true
      right: true
    }
    
    margins {
      top: Theme.barHeight + Theme.spacingS
      right: Theme.spacingM
    }
    
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    
    color: "transparent"
    mask: null
    
    Component.onCompleted: {
      exclusiveZone = 0
      implicitWidth = 340
      implicitHeight = 420
    }
    
    // Handle Escape key to close
    contentItem {
      focus: true
      
      Keys.onPressed: event => {
        if (event.key === Qt.Key_Escape) {
          loader.manager.visible = false
          event.accepted = true
        }
      }
    }
    
    Rectangle {
      id: background
      anchors.fill: parent
      radius: Theme.radiusXLarge
      color: Theme.bg1transparent
      
      ColumnLayout {
        anchors {
          fill: parent
          margins: Theme.spacingM
        }
        spacing: Theme.spacingS
        
        // Header
        RowLayout {
          Layout.fillWidth: true
          spacing: Theme.spacingS
          
          Text {
            Layout.fillWidth: true
            text: "Notifications"
            color: Theme.fg
            font.pixelSize: Theme.fontSizeM
            font.family: Theme.fontFamily
            font.bold: true
          }
          
          // Clear all button (smaller)
          Rectangle {
            Layout.preferredWidth: 60
            Layout.preferredHeight: 24
            radius: Theme.radiusMedium
            color: clearMouseArea.containsMouse ? Theme.bg2 : "transparent"
            border.color: Theme.border
            border.width: 0
            visible: loader.manager.notifications.length > 0
            
            Text {
              anchors.centerIn: parent
              text: "Clear"
              color: Theme.fg
              font.pixelSize: Theme.fontSizeM
              font.family: Theme.fontFamily
            }
            
            MouseArea {
              id: clearMouseArea
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              
              onClicked: {
                loader.manager.clearAll()
              }
            }
          }
          
          // Close button
          Rectangle {
            Layout.preferredWidth: 30
            Layout.preferredHeight: 30
            radius: Theme.radiusMedium
            color: closeMouseArea.containsMouse ? Theme.bg2 : "transparent"
            
            Text {
              anchors.centerIn: parent
              text: "✕"
              color: Theme.fg
              font.pixelSize: Theme.fontSizeM
              font.family: Theme.fontFamily
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
        
        // Notifications list - showing exactly 3, scrollable
        ListView {
          id: notifList
          Layout.fillWidth: true
          Layout.fillHeight: true
          clip: true
          spacing: Theme.spacingS
          
          model: loader.manager.notifications
          
          // Smooth scrolling animation
          Behavior on contentY {
            NumberAnimation {
              duration: 300
              easing.type: Easing.OutCubic
            }
          }
          
          delegate: Rectangle {
            required property var modelData
            required property int index
            
            width: notifList.width
            height: 90  // Slightly taller for better text readability
            radius: Theme.radiusXLarge
            color: notifMouseArea.containsMouse ? Theme.bg2 : Theme.bg2transparent
            
            ColumnLayout {
              id: notifContent
              anchors {
                fill: parent
                margins: Theme.spacingM
              }
              spacing: 6
              
              // Header row with app name, time, and close button
              RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingS
                
                Text {
                  text: modelData.appName
                  color: Theme.fgMuted
                  font.pixelSize: Theme.fontSizeS
                  font.family: Theme.fontFamily
                  elide: Text.ElideRight
                }
                
                Item { Layout.fillWidth: true }
                
                Text {
                  text: modelData.date + " " + modelData.time
                  color: Theme.fgMuted
                  font.pixelSize: Theme.fontSizeS
                  font.family: Theme.fontFamily
                }
                
                Text {
                  text: "✕"
                  color: closeNotifMouseArea.containsMouse ? Theme.fg : Theme.fgMuted
                  font.pixelSize: Theme.fontSizeXS
                  font.family: Theme.fontFamily
                  
                  MouseArea {
                    id: closeNotifMouseArea
                    anchors.fill: parent
                    anchors.margins: -4  // Easier to click
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    
                    onClicked: {
                      loader.manager.removeNotification(index)
                      mouse.accepted = true
                    }
                  }
                }
              }
              
              // Summary (title) - bigger and more readable
              Text {
                Layout.fillWidth: true
                text: modelData.summary
                color: Theme.fg
                font.pixelSize: Theme.fontSizeM
                font.family: Theme.fontFamily
                font.bold: true
                wrapMode: Text.WordWrap
                maximumLineCount: 2
                elide: Text.ElideRight
              }
              
              // Body - more readable size
              Text {
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: modelData.body
                color: Theme.fgMuted
                font.pixelSize: Theme.fontSizeS
                font.family: Theme.fontFamily
                wrapMode: Text.WordWrap
                maximumLineCount: 2
                elide: Text.ElideRight
                visible: text !== ""
              }
            }
            
            MouseArea {
              id: notifMouseArea
              anchors.fill: parent
              hoverEnabled: true
              z: -1  // Behind the close button
            }
          }
          
          // Empty state
          Text {
            anchors.centerIn: parent
            text: "No notifications"
            color: Theme.fgMuted
            font.pixelSize: Theme.fontSizeS
            font.family: Theme.fontFamily
            visible: notifList.count === 0
          }
          
          // Elegant minimal scrollbar
          Rectangle {
            anchors {
              right: parent.right
              top: parent.top
              bottom: parent.bottom
              rightMargin: 2
              topMargin: 2
              bottomMargin: 2
            }
            width: 3
            radius: 1.5
            color: "transparent"
            visible: notifList.count > 3
            
            // Scrollbar track (subtle)
            Rectangle {
              anchors.fill: parent
              radius: parent.radius
              color: Theme.borderDim
              opacity: 0.2
            }
            
            // Scrollbar thumb
            Rectangle {
              width: parent.width
              height: {
                if (notifList.contentHeight <= notifList.height) return 0
                return Math.max(30, parent.height * (notifList.height / notifList.contentHeight))
              }
              y: {
                if (notifList.contentHeight <= notifList.height) return 0
                var maxY = parent.height - height
                var progress = notifList.contentY / (notifList.contentHeight - notifList.height)
                return maxY * progress
              }
              radius: parent.radius
              color: Theme.fgMuted
              opacity: notifMouseArea.containsMouse || scrollMouseArea.drag.active ? 0.5 : 0.3
              
              Behavior on opacity {
                NumberAnimation {
                  duration: 150
                  easing.type: Easing.OutCubic
                }
              }
              
              Behavior on y {
                NumberAnimation {
                  duration: 100
                  easing.type: Easing.OutCubic
                }
              }
              
              MouseArea {
                id: scrollMouseArea
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
              }
            }
          }
        }
      }
    }
  }
}
