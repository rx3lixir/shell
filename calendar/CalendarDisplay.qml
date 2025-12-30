import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import "../theme"

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
      implicitHeight = 460
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
        spacing: Theme.spacingM
        
        // ========== HEADER ==========
        RowLayout {
          Layout.fillWidth: true
          spacing: Theme.spacingS
          
          Text {
            Layout.fillWidth: true
            text: "Calendar"
            color: Theme.fg
            font.pixelSize: Theme.fontSizeM
            font.family: Theme.fontFamily
            font.bold: true
          }
          
          // Close button
          Rectangle {
            Layout.preferredWidth: 24
            Layout.preferredHeight: 24
            radius: Theme.radiusMedium
            color: closeMouseArea.containsMouse ? Theme.bg2 : "transparent"
            
            Text {
              anchors.centerIn: parent
              text: "✕"
              color: Theme.fg
              font.pixelSize: Theme.fontSizeS
              font.family: Theme.fontFamily
            }
            
            MouseArea {
              id: closeMouseArea
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: loader.manager.visible = false
            }
          }
        }
        
        // ========== CURRENT TIME & DATE ==========
        Rectangle {
          Layout.fillWidth: true
          Layout.preferredHeight: 100
          radius: Theme.radiusXLarge
          color: Theme.bg2transparent
          
          ColumnLayout {
            anchors {
              fill: parent
              margins: Theme.spacingM
            }
            spacing: 4
            
            // Time (big)
            Text {
              Layout.fillWidth: true
              text: loader.manager.timeString
              color: Theme.fg
              font.pixelSize: Theme.fontSizeXL * 1.5
              font.family: Theme.fontFamily
              font.bold: true
              horizontalAlignment: Text.AlignHCenter
            }
            
            // Day of week
            Text {
              Layout.fillWidth: true
              text: loader.manager.dayOfWeek
              color: Theme.fgMuted
              font.pixelSize: Theme.fontSizeM
              font.family: Theme.fontFamily
              horizontalAlignment: Text.AlignHCenter
            }
            
            // Date
            Text {
              Layout.fillWidth: true
              text: loader.manager.dateString
              color: Theme.fgMuted
              font.pixelSize: Theme.fontSizeS
              font.family: Theme.fontFamily
              horizontalAlignment: Text.AlignHCenter
            }
          }
        }
        
        // ========== CALENDAR NAVIGATION ==========
        RowLayout {
          Layout.fillWidth: true
          spacing: Theme.spacingS
          
          // Previous month button
          Rectangle {
            Layout.preferredWidth: 32
            Layout.preferredHeight: 32
            radius: Theme.radiusLarge
            color: prevMouseArea.containsMouse ? Theme.bg2 : "transparent"
            
            Text {
              anchors.centerIn: parent
              text: ""
              color: Theme.fg
              font.pixelSize: Theme.fontSizeL
              font.family: Theme.fontFamily
            }
            
            MouseArea {
              id: prevMouseArea
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              
              onClicked: {
                loader.manager.previousMonth()
              }
            }
          }
          
          // Month/Year display
          Text {
            Layout.fillWidth: true
            text: {
              var monthName = Qt.locale().monthName(loader.manager.displayMonth, Locale.LongFormat)
              return monthName + " " + loader.manager.displayYear
            }
            color: Theme.fg
            font.pixelSize: Theme.fontSizeM
            font.family: Theme.fontFamily
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
          }
          
          // Next month button
          Rectangle {
            Layout.preferredWidth: 32
            Layout.preferredHeight: 32
            radius: Theme.radiusLarge
            color: nextMouseArea.containsMouse ? Theme.bg2 : "transparent"
            
            Text {
              anchors.centerIn: parent
              text: ""
              color: Theme.fg
              font.pixelSize: Theme.fontSizeL
              font.family: Theme.fontFamily
            }
            
            MouseArea {
              id: nextMouseArea
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              
              onClicked: {
                loader.manager.nextMonth()
              }
            }
          }
        }
        
        // ========== CALENDAR GRID ==========
        Rectangle {
          Layout.fillWidth: true
          Layout.fillHeight: true
          radius: Theme.radiusXLarge
          color: Theme.bg2transparent
          
          ColumnLayout {
            anchors {
              fill: parent
              margins: Theme.spacingS
            }
            spacing: 2
            
            // Day names header
            DayOfWeekRow {
              Layout.fillWidth: true
              locale: Qt.locale()
              
              delegate: Text {
                required property string shortName
                
                text: shortName
                color: Theme.fgMuted
                font.pixelSize: Theme.fontSizeS
                font.family: Theme.fontFamily
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
              }
            }
            
            // Calendar grid
            MonthGrid {
              id: monthGrid
              Layout.fillWidth: true
              Layout.fillHeight: true
              
              month: loader.manager.displayMonth
              year: loader.manager.displayYear
              locale: Qt.locale()
              
              delegate: Rectangle {
                required property var model
                
                radius: height / 2
                color: {
                  // Today's date
                  var now = new Date()
                  var isToday = model.day === now.getDate() && 
                                model.month === now.getMonth() && 
                                model.year === now.getFullYear()
                  
                  if (isToday) return Theme.accent
                  if (dateMouseArea.containsMouse) return Qt.darker(Theme.accent, 2)
                  return "transparent"
                }
                
                Behavior on color {
                  ColorAnimation {
                    duration: 150
                    easing.type: Easing.OutCubic
                  }
                }
                
                Text {
                  anchors.centerIn: parent
                  text: model.day
                  color: {
                    var now = new Date()
                    var isToday = model.day === now.getDate() && 
                                  model.month === now.getMonth() && 
                                  model.year === now.getFullYear()
                    
                    if (isToday) return Theme.bg1
                    if (model.month !== monthGrid.month) return Theme.borderDim
                    return Theme.fg
                  }
                  font.pixelSize: Theme.fontSizeM
                  font.family: Theme.fontFamily
                  opacity: model.month === monthGrid.month ? 1.0 : 0.8
                  
                  Behavior on color {
                    ColorAnimation {
                      duration: 150
                      easing.type: Easing.OutCubic
                    }
                  }
                }
                
                MouseArea {
                  id: dateMouseArea
                  anchors.fill: parent
                  hoverEnabled: true
                  cursorShape: Qt.PointingHandCursor
                }
              }
            }
          }
        }
        
        // ========== TODAY BUTTON ==========
        Rectangle {
          Layout.fillWidth: true
          Layout.preferredHeight: 32
          radius: Theme.radiusLarge
          color: todayMouseArea.containsMouse ? Theme.accent : Theme.accentTransparent
          
          Behavior on color {
            ColorAnimation {
              duration: 150
              easing.type: Easing.OutCubic
            }
          }
          
          Text {
            anchors.centerIn: parent
            text: "Today"
            color: Theme.fg
            font.pixelSize: Theme.fontSizeS
            font.family: Theme.fontFamily
          }
          
          MouseArea {
            id: todayMouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            
            onClicked: {
              loader.manager.goToToday()
            }
          }
        }
      }
    }
  }
}
