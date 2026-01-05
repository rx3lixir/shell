// NotificationDisplay.qml (Updated)
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import "../theme"
import "../components"  // Import your custom components

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
        
        // Calculate Y position based on stack index (more compact stacking)
        property real stackOffset: {
          var baseOffset = Theme.barHeight + Theme.spacing.md
          var perNotifOffset = 96  // Reduced for minimalism (adjust as needed)
          return baseOffset + (loader.index * perNotifOffset)
        }
        
        anchors {
          top: true
          right: true
        }
        
        margins {
          top: stackOffset
          right: Theme.spacing.md
        }
        
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        
        color: "transparent"
        mask: null
        
        Component.onCompleted: {
          exclusiveZone = 0
          implicitWidth = 320  // Slightly narrower for minimalism
          implicitHeight = notifContent.implicitHeight + (Theme.padding.sm * 2)
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
          Card {
            id: background
            anchors.fill: parent
            radius: Theme.radius.lg
            padding: Theme.padding.sm
            
            property bool hovered: false
            
            // Hover effects similar to Control Center modules
            color: hovered ? Qt.darker(Theme.surface_container_low, 1.05) : Theme.surface_container_low
            
            Behavior on color {
              ColorAnimation { duration: 150 }
            }
            
            ColumnLayout {
              id: notifContent
              anchors.fill: parent
              
              // Header row
              RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: Theme.padding.sm
                Layout.bottomMargin: Theme.padding.xs
                Layout.leftMargin: Theme.padding.sm
                Layout.rightMargin: Theme.padding.md
                spacing: Theme.spacing.sm
                
                // App icon 
                IconCircle {
                  Layout.preferredWidth: 24 // Smaller for minimalism
                  Layout.preferredHeight: 24
                  icon: "󰂚"  // Default app icon (customize per app if possible)
                  bgColor: Theme.surface_container_high
                  iconColor: Theme.on_surface_variant
                  iconSize: Theme.typography.md
                }
                
                // App name - minimal text
                Text {
                  Layout.fillWidth: true
                  text: loader.notifApp || "Notification"
                  color: Theme.on_surface
                  font.pixelSize: Theme.typography.md
                  font.family: Theme.typography.fontFamily
                  font.weight: Theme.typography.weightMedium
                  elide: Text.ElideRight
                }
                
                Text {
                  text: "✕"
                  color: Theme.on_surface_variant
                  font.pixelSize: Theme.typography.md
                  opacity: closeArea.containsMouse ? 0.8 : 0.5

                  Behavior on opacity { NumberAnimation { duration: 150 } }

                  MouseArea {
                    id: closeArea
                    anchors.centerIn: parent
                    width: 28; height: 28 
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: fadeOut.start()
                  }
                }
              }
              
              // Subtle divider (minimal opacity)
              Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1  // Thinner for minimalism
                Layout.leftMargin: Theme.padding.sm
                Layout.rightMargin: Theme.padding.sm
                color: Theme.outline_variant
                opacity: 0.6
              }
              
              // Content - compact and minimal
              ColumnLayout {
                Layout.fillWidth: true
                Layout.topMargin: Theme.padding.sm
                Layout.bottomMargin: Theme.padding.sm
                Layout.leftMargin: Theme.padding.md
                Layout.rightMargin: Theme.padding.md
                spacing: Theme.spacing.sm
                
                // Summary - bold and primary
                Text {
                  Layout.fillWidth: true
                  text: loader.notifSummary
                  color: Theme.on_surface
                  font.pixelSize: Theme.typography.md
                  font.family: Theme.typography.fontFamily
                  font.weight: Theme.typography.weightMedium
                  wrapMode: Text.WordWrap
                  maximumLineCount: 1  // Limit for minimalism
                  elide: Text.ElideRight
                }
                
                // Body - muted and smaller
                Text {
                  Layout.fillWidth: true
                  text: loader.notifBody
                  color: Theme.on_surface_variant
                  font.pixelSize: Theme.typography.sm
                  font.family: Theme.typography.fontFamily
                  wrapMode: Text.WordWrap
                  maximumLineCount: 3  // Limit lines for compactness
                  elide: Text.ElideRight
                  visible: text !== ""
                  opacity: 0.8
                }
              }
            }
            
            // Hover area with effects like in IconButton
            MouseArea {
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              propagateComposedEvents: true
              
              onEntered: background.hovered = true
              onExited: background.hovered = false
              
              onClicked: mouse => {
                mouse.accepted = false  // Allow clicks to pass if needed
              }
            }
          }
        }
        
        // Fade out animation
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
        
        // Auto-dismiss timer (shortened for minimalism)
        Timer {
          id: dismissTimer
          interval: 5000  // 5 seconds - adjust as preferred
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
