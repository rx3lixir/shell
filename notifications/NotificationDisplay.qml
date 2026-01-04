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
        
        // Calculate Y position based on stack index
        property real stackOffset: {
          var baseOffset = Theme.barHeight + Theme.spacingM
          var perNotifOffset = 120 // More compact
          return baseOffset + (loader.index * perNotifOffset)
        }
        
        anchors {
          top: true
          right: true
        }
        
        margins {
          top: stackOffset
          right: Theme.spacingM
        }
        
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        
        color: "transparent"
        mask: null
        
        Component.onCompleted: {
          exclusiveZone = 0
          implicitWidth = 300
          implicitHeight = notifContent.implicitHeight + (Theme.spacingM * 2)
        }
        
        // Smooth position transitions when notifications above are removed
        Behavior on stackOffset {
          NumberAnimation {
            duration: 250
            easing.type: Easing.OutCubic
          }
        }
        
        // Wrapper item for fade animation
        Item {
          id: wrapper
          anchors.fill: parent
          opacity: 0
          
          // Simple fade in
          NumberAnimation on opacity {
            from: 0
            to: 1
            duration: 200
            easing.type: Easing.OutCubic
          }
        
        // Main notification container
        Rectangle {
          id: background
          anchors.fill: parent
          radius: 16 // Slightly less rounded for compact look
          color: Theme.bg1
          border.width: 1
          border.color: Theme.borderDim
          
          property bool hovered: false
          
          // Just the rounding animation on hover
          Behavior on radius {
            NumberAnimation {
              duration: 200
              easing.type: Easing.OutCubic
            }
          }
          
          Behavior on color {
            ColorAnimation { duration: 150 }
          }
          
          ColumnLayout {
            id: notifContent
            anchors {
              fill: parent
              rightMargin: Theme.spacingL
              bottomMargin: Theme.spacingM
              topMargin: Theme.spacingM
              leftMargin: Theme.spacingL
            }

            spacing: Theme.spacingS
            
            // Header row - compact
            RowLayout {
              Layout.fillWidth: true
              spacing: Theme.spacingS
              
              // App icon container - smaller
              Rectangle {
                Layout.preferredWidth: 28
                Layout.preferredHeight: 28
                radius: 14
                color: Qt.lighter(Theme.bg2, 1.2)
                
                Text {
                  anchors.centerIn: parent
                  text: "󰵅"
                  color: Theme.fgMuted
                  font.pixelSize: 14
                  font.family: Theme.fontFamily
                }
              }
              
              // App name
              Text {
                Layout.fillWidth: true
                text: loader.notifApp
                color: Theme.fgMuted
                font.pixelSize: Theme.fontSizeS
                font.family: Theme.fontFamily
                elide: Text.ElideRight
                opacity: 0.8
              }
              
              // Close button - minimal
              Rectangle {
                Layout.preferredWidth: 24
                Layout.preferredHeight: 24
                radius: 12
                color: closeMouseArea.containsMouse ? Theme.bg2 : "transparent"
                
                Behavior on color {
                  ColorAnimation { duration: 100 }
                }
                
                Text {
                  anchors.centerIn: parent
                  text: "✕"
                  color: closeMouseArea.containsMouse ? Theme.fg : Theme.fgMuted
                  font.pixelSize: 12
                  font.family: Theme.fontFamily
                  
                  Behavior on color {
                    ColorAnimation { duration: 100 }
                  }
                }
                
                MouseArea {
                  id: closeMouseArea
                  anchors.fill: parent
                  hoverEnabled: true
                  cursorShape: Qt.PointingHandCursor
                  z: 2
                  
                  onClicked: {
                    fadeOut.start()
                  }
                }
              }
            }
            
            // Subtle divider
            Rectangle {
              Layout.fillWidth: true
              Layout.preferredHeight: 2
              color: Theme.borderDim
              opacity: 0.3
            }
            
            // Content - compact
            ColumnLayout {
              Layout.fillWidth: true
              spacing: 6
              
              // Summary
              Text {
                Layout.fillWidth: true
                text: loader.notifSummary
                color: Theme.fg
                font.pixelSize: Theme.fontSizeM
                font.family: Theme.fontFamily
                font.weight: Font.Medium
                wrapMode: Text.WordWrap
                maximumLineCount: 1
                elide: Text.ElideRight
              }
              
              // Body - compact
              Text {
                Layout.fillWidth: true
                text: loader.notifBody
                color: Theme.fgMuted
                font.pixelSize: Theme.fontSizeS
                font.family: Theme.fontFamily
                wrapMode: Text.WordWrap
                maximumLineCount: 2
                elide: Text.ElideRight
                visible: text !== ""
                opacity: 0.85
              }
            }
          }
          
          // Hover area
          MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            z: 1
            propagateComposedEvents: true
            
            onEntered: {
              background.hovered = true
              background.radius = 24  // More rounded on hover
            }
            
            onExited: {
              background.hovered = false
              background.radius = 20  // Back to normal
            }
            
            onClicked: mouse => {
              mouse.accepted = false
            }
          }
        }
        }  // End of wrapper Item
        
        // Simple fade out animation
        NumberAnimation {
          id: fadeOut
          target: wrapper
          property: "opacity"
          to: 0
          duration: 150
          easing.type: Easing.InCubic
          
          onFinished: {
            loader.active = false
          }
        }
        
        // Auto-dismiss timer
        Timer {
          id: dismissTimer
          interval: 5000
          running: true
          onTriggered: {
            fadeOut.start()
          }
        }
      }
      
      // Clean up when dismissed
      onActiveChanged: {
        if (!active) {
          Qt.callLater(function() {
            root.manager.removeFromQueue(loader.notifId)
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
