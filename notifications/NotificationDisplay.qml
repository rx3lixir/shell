import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import QtQuick.Effects
import "../theme"

LazyLoader {
  id: loader
  
  required property var manager
  
  // Only load when there's a notification to show
  active: manager.hasNotification
  
  PanelWindow {
    id: notifWindow
    
    property real slideOffset: 0
    
    anchors {
      top: true
      right: true
    }
    
    margins {
      top: Theme.barHeight + Theme.spacingM
      right: Theme.spacingL
    }
    
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    
    color: "transparent"
    
    // Don't use a mask - let the whole window receive input
    mask: null
    
    Component.onCompleted: {
      exclusiveZone = 0
      implicitWidth = 320
      implicitHeight = notifContent.implicitHeight + (Theme.spacingM * 2)
      slideOffset = 350
      slideAnim.start()
    }
    
    NumberAnimation {
      id: slideAnim
      target: notifWindow
      property: "slideOffset"
      from: 350
      to: 0
      duration: 500
      easing.type: Easing.OutCubic
    }
    
    Rectangle {
      id: background
      anchors.fill: parent
      anchors.rightMargin: -notifWindow.slideOffset
      radius: Theme.radiusLarge
      color: Theme.bg1transparent
      
      // Hover state for better feedback
      property bool hovered: false
      
      Behavior on border.color {
        ColorAnimation {
          duration: 200
          easing.type: Easing.OutCubic
        }
      }
      
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
            text: loader.manager.notifApp
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
          text: loader.manager.notifSummary
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
          text: loader.manager.notifBody
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
          loader.manager.hasNotification = false
        }
      }
    }

    MultiEffect {
      source: background
      anchors.fill: background
      shadowEnabled: true
      shadowColor: "#80000000"     // Black with ~50% opacity – adjust for subtlety
      shadowBlur: 0.5             // Maximum softness (Gaussian-like)
      shadowVerticalOffset: 6     // Downward lift for floating feel
      shadowHorizontalOffset: 0
      // For even larger/spread-out Tahoe vibe:
      shadowScale: 1.05        // Slightly enlarges the shadow area
      maskEnabled: true
      maskThresholdMin: 0.5
      maskSpreadAtMin: 1.0
    }
  }
}
