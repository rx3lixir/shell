import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import "../theme"
import "../components"
import "cal_modules" as CalModules

LazyLoader {
  id: loader
  
  required property var manager
  
  active: manager.visible
  
  PanelWindow {
    id: calendarWindow
    
    anchors {
      top: true
      right: true
    }
    
    margins {
      top: Theme.component.barHeight + Theme.spacing.md
      right: Theme.spacing.md
    }
    
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    
    color: "transparent"
    mask: null
    
    Component.onCompleted: {
      exclusiveZone = 0
      implicitWidth = 360
      implicitHeight = 520
    }
    
    contentItem {
      focus: true
      
      Keys.onPressed: event => {
        if (event.key === Qt.Key_Escape) {
          loader.manager.visible = false
          event.accepted = true
        }
      }
    }
    
    MouseArea {
      anchors.fill: parent
      onClicked: {
        loader.manager.visible = false
      }
    }
    
    // Main container with Material 3 style
    Rectangle {
      id: background
      anchors.fill: parent
      radius: Theme.radius.xl
      color: Theme.surface_container_transparent
      border.width: 1
      border.color: Qt.lighter(Theme.surface_container, 1.3)
      
      ColumnLayout {
        anchors {
          fill: parent
          margins: Theme.padding.lg
        }
        spacing: Theme.spacing.md
        
        // ========== HEADER ==========
        RowLayout {
          Layout.fillWidth: true
          Layout.preferredHeight: 40
          spacing: Theme.spacing.sm
          
          Text {
            Layout.fillWidth: true
            text: "Calendar"
            color: Theme.on_surface
            font.pixelSize: Theme.typography.lg
            font.family: Theme.typography.fontFamily
            font.weight: Theme.typography.weightMedium
          }
          
          // Close button
          RoundIconButton {
            Layout.preferredWidth: 40
            Layout.preferredHeight: 40
            icon: "✕"
            onClicked: loader.manager.visible = false
          }
        }
        
        // ========== CURRENT TIME & DATE ==========
        CalModules.TimeDisplay {
          Layout.fillWidth: true
          Layout.preferredHeight: 108
          calendarManager: loader.manager
        }
        
        // ========== CALENDAR NAVIGATION ==========
        CalModules.CalendarNavigation {
          Layout.fillWidth: true
          calendarManager: loader.manager
        }
        
        // ========== CALENDAR GRID ==========
        CalModules.CalendarGrid {
          Layout.fillWidth: true
          Layout.fillHeight: true
          calendarManager: loader.manager
        }
        
        // ========== TODAY BUTTON ==========
        CalModules.TodayButton {
          Layout.fillWidth: true
          Layout.preferredHeight: 40
          calendarManager: loader.manager
        }
      }
    }
  }
}
