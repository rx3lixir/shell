import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import "../theme"

Scope {
  id: root
  
  required property var manager
  
  // Component for a single notification popup
  Component {
    id: notificationWindowComponent
    
    LazyLoader {
      id: loader
      
      // Properties for this specific notification
      required property int notifId
      required property string notifSummary
      required property string notifBody
      required property string notifApp
      required property int index  // Position in stack
      
      active: true
      
      PanelWindow {
        id: notifWindow
        
        property real slideOffset: 0
        
        // Calculate Y position based on stack index
        property real stackOffset: {
          // Each notification takes roughly 100px + spacing
          var baseOffset = Theme.barHeight + Theme.spacingM
          var perNotifOffset = 108  // Approximate height + spacing
          return baseOffset + (loader.index * perNotifOffset)
        }
        
        anchors {
          top: true
          right: true
        }
        
        margins {
          top: stackOffset
          right: Theme.spacingL
        }
        
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        
        color: "transparent"
        mask: null
        
        Component.onCompleted: {
          exclusiveZone = 0
          implicitWidth = 300
          implicitHeight = notifContent.implicitHeight + (Theme.spacingM * 2)
          slideOffset = 350
          slideAnim.start()
        }
        
        // Slide in animation
        NumberAnimation {
          id: slideAnim
          target: notifWindow
          property: "slideOffset"
          from: 350
          to: 0
          duration: 500
          easing.type: Easing.OutCubic
        }
        
        // Smooth position transitions when notifications above are removed
        Behavior on stackOffset {
          NumberAnimation {
            duration: 300
            easing.type: Easing.OutCubic
          }
        }
        
        Rectangle {
          id: background
          anchors.fill: parent
          anchors.rightMargin: -notifWindow.slideOffset
          radius: Theme.radiusXLarge
          color: Theme.bg0transparent
          
          property bool hovered: false
          
          ColumnLayout {
            id: notifContent
            anchors {
              fill: parent
              margins: Theme.spacingM
            }
            spacing: Theme.spacingS
            
            // Header row with app name and close hint
            RowLayout {
              Layout.fillWidth: true
              spacing: Theme.spacingM
              
              // App name
              Text {
                Layout.fillWidth: true
                text: loader.notifApp
                color: Theme.fgMuted
                font.pixelSize: Theme.fontSizeS
                font.family: Theme.fontFamily
                elide: Text.ElideRight
              }
              
              // Close hint (shows on hover)
              Text {
                text: "✕"
                color: background.hovered ? Theme.fg : Theme.fgMuted
                font.pixelSize: Theme.fontSizeS
                font.family: Theme.fontFamily
                opacity: background.hovered ? 1.0 : 0.5
                
                Behavior on opacity {
                  NumberAnimation {
                    duration: 150
                    easing.type: Easing.OutCubic
                  }
                }
                
                Behavior on color {
                  ColorAnimation {
                    duration: 150
                    easing.type: Easing.OutCubic
                  }
                }
              }
            }
            
            // Summary (title)
            Text {
              Layout.fillWidth: true
              text: loader.notifSummary
              color: Theme.fg
              font.pixelSize: Theme.fontSizeM
              font.family: Theme.fontFamily
              font.bold: true
              wrapMode: Text.WordWrap
              maximumLineCount: 2
              elide: Text.ElideRight
            }
            
            // Body
            Text {
              Layout.fillWidth: true
              text: loader.notifBody
              color: Theme.fgMuted
              font.pixelSize: Theme.fontSizeS
              font.family: Theme.fontFamily
              wrapMode: Text.WordWrap
              maximumLineCount: 3
              elide: Text.ElideRight
              visible: text !== ""
            }
          }
          
          // Click to dismiss
          MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            z: 1
            
            onEntered: background.hovered = true
            onExited: background.hovered = false
            
            onClicked: {
              dismissTimer.stop()
              loader.active = false
            }
          }
        }
        
        // Auto-dismiss timer (5 seconds)
        Timer {
          id: dismissTimer
          interval: 5000
          running: true
          onTriggered: {
            loader.active = false
          }
        }
      }
      
      // Clean up when dismissed
      onActiveChanged: {
        if (!active) {
          // Remove from manager's queue
          Qt.callLater(function() {
            root.manager.removeFromQueue(loader.notifId)
            // Destroy this component
            loader.destroy()
          })
        }
      }
    }
  }
  
  // Instantiator to create windows for each notification in the queue
  Instantiator {
    model: root.manager.notificationQueue
    
    delegate: Item {
      required property var modelData
      required property int index
      
      Component.onCompleted: {
        // Create notification window
        var windowObj = notificationWindowComponent.createObject(root, {
          notifId: modelData.id,
          notifSummary: modelData.summary,
          notifBody: modelData.body,
          notifApp: modelData.appName,
          index: index
        })
      }
    }
  }
}
