import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import QtQuick.Effects
import "../theme"

LazyLoader {
  id: loader
  
  required property var manager
  
  // Only load when there's a notification to show
  active: manager.hasNotification
  
  onActiveChanged: {
    console.log("NotificationDisplay active changed to:", active)
    console.log("hasNotification:", manager.hasNotification)
  }
  
  PanelWindow {
    id: notifWindow
    anchors.top: true
    anchors.right: true
    margins.top: Theme.barHeight + Theme.spacingM
    margins.right: Theme.spacingM
    
    exclusiveZone: 0
    implicitWidth: 350
    implicitHeight: notifContent.implicitHeight + 20
    
    color: "transparent"
    mask: Region {}
    
    // Animation properties
    property real slideOffset: 0
    
    // Slide in from right when notification appears
    Component.onCompleted: {
      slideOffset = 350 // Start off-screen (width of notification)
      slideAnim.start()
    }
    
    NumberAnimation {
      id: slideAnim
      target: notifWindow
      property: "slideOffset"
      from: 350
      to: 0
      duration: 300
      easing.type: Easing.OutCubic
    }
    
    // Shadow
    RectangularShadow {
      anchors.centerIn: parent
      anchors.horizontalCenterOffset: notifWindow.slideOffset
      width: parent.width
      height: parent.height
      radius: background.radius
      color: "#80000000"
      blur: 20
      spread: 0
      offset: Qt.vector2d(0, 4)
    }
    
    Rectangle {
      id: background
      anchors.fill: parent
      anchors.rightMargin: -notifWindow.slideOffset
      radius: Theme.radiusLarge
      color: Theme.bg1transparent
      border.color: Theme.bg1
      border.width: 2
      
      ColumnLayout {
        id: notifContent
        anchors {
          fill: parent
          margins: Theme.spacingM
        }
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
        
        // Summary (title)
        Text {
          Layout.fillWidth: true
          text: loader.manager.notifSummary
          color: Theme.fg
          font.pixelSize: Theme.fontSizeM
          font.family: Theme.fontFamily
          font.bold: true
          wrapMode: Text.WordWrap
        }
        
        // Body
        Text {
          Layout.fillWidth: true
          text: loader.manager.notifBody
          color: Theme.fg
          font.pixelSize: Theme.fontSizeS
          font.family: Theme.fontFamily
          wrapMode: Text.WordWrap
          visible: text !== ""
        }
      }
      
      // Click to dismiss
      MouseArea {
        anchors.fill: parent
        onClicked: {
          loader.manager.hasNotification = false
        }
      }
    }
  }
}
