import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import "../theme"
import "../components"

LazyLoader {
  id: loader

  required property var manager

  active: manager.visible

  PanelWindow {
    id: notifCenterWindow

    anchors {
      top: true
      right: true
    }

    margins {
      top: Theme.barHeight + Theme.spacing.md
      right: Theme.spacing.md
    }

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    color: "transparent"
    mask: null

    Component.onCompleted: {
      exclusiveZone = 0
      implicitWidth = 360
      implicitHeight = 600
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
      onClicked: loader.manager.visible = false
    }

    // Main container
    Rectangle {
      id: background
      anchors.fill: parent
      radius: Theme.radius.xl
      color: Theme.bg1transparent
      border.width: 1
      border.color: Qt.lighter(Theme.bg1, 1.3)

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
            Layout.leftMargin: Theme.padding.xs
            text: "Notifications"
            color: Theme.on_surface
            font.pixelSize: Theme.typography.lg
            font.family: Theme.typography.fontFamily
            font.weight: Theme.typography.weightMedium
          }

          // Clear All button - only show when there are notifications
          Rectangle {
            Layout.preferredWidth: 80
            Layout.preferredHeight: 32
            radius: Theme.radius.full
            visible: loader.manager.notifications.length > 0

            color: clearMouseArea.containsMouse 
                   ? Theme.surface_container_high 
                   : Theme.surface_container_low

            border.width: 1
            border.color: clearMouseArea.containsMouse 
                          ? Theme.outline 
                          : Theme.outline_variant

            scale: clearMouseArea.pressed ? 0.95 : 1.0

            Behavior on color { ColorAnimation { duration: 150 } }
            Behavior on border.color { ColorAnimation { duration: 150 } }
            Behavior on scale { 
              NumberAnimation { 
                duration: 100
                easing.type: Easing.OutCubic 
              } 
            }

            Text {
              anchors.centerIn: parent
              text: "Clear All"
              color: Theme.on_surface
              font.pixelSize: Theme.typography.sm
              font.family: Theme.typography.fontFamily
              font.weight: Theme.typography.weightMedium
            }

            MouseArea {
              id: clearMouseArea
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: loader.manager.clearAll()
            }
          }

          // Close button
          RoundIconButton {
            Layout.preferredWidth: 40
            Layout.preferredHeight: 40
            icon: "✕"
            onClicked: loader.manager.visible = false
          }
        }

        // ========== NOTIFICATIONS LIST ==========
        ListView {
          id: notifList
          Layout.fillWidth: true
          Layout.fillHeight: true
          clip: true
          spacing: Theme.spacing.md

          model: loader.manager.notifications

          Behavior on contentY {
            NumberAnimation { 
              duration: 300
              easing.type: Easing.OutCubic 
            }
          }

          delegate: Item {
            required property var modelData
            required property int index

            width: notifList.width
            height: notifCard.height

            Rectangle {
              id: notifCard
              anchors.left: parent.left
              anchors.right: parent.right
              anchors.top: parent.top
              height: notifContent.implicitHeight + (Theme.padding.md * 2)
              
              radius: Theme.radius.lg
              color: hovered 
                     ? Qt.darker(Theme.surface_container_low, 1.05) 
                     : Theme.surface_container_low

              border.width: 1
              border.color: Theme.outline_variant

              property bool hovered: false

              Behavior on color {
                ColorAnimation { duration: 150 }
              }

              ColumnLayout {
                id: notifContent
                anchors.fill: parent
                anchors.margins: Theme.padding.lg
                spacing: Theme.spacing.sm

              // Header: icon + app name + close button
              RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacing.sm

                IconCircle {
                  Layout.preferredWidth: 28
                  Layout.preferredHeight: 28
                  icon: "󰂚"
                  bgColor: Theme.surface_container_high
                  iconColor: Theme.on_surface_variant
                  iconSize: Theme.typography.md
                }

                Text {
                  Layout.fillWidth: true
                  text: modelData.appName
                  color: Theme.on_surface
                  font.pixelSize: Theme.typography.md
                  font.family: Theme.typography.fontFamily
                  font.weight: Theme.typography.weightMedium
                  elide: Text.ElideRight
                }

                // Close button (minimal)
                Rectangle {
                  Layout.preferredWidth: 28
                  Layout.preferredHeight: 28
                  radius: Theme.radius.full
                  color: closeMouseArea.containsMouse 
                         ? Theme.surface_container_high 
                         : "transparent"

                  Behavior on color { 
                    ColorAnimation { duration: 150 } 
                  }

                  Text {
                    anchors.centerIn: parent
                    text: "✕"
                    color: closeMouseArea.containsMouse 
                           ? Theme.on_surface 
                           : Theme.on_surface_variant
                    font.pixelSize: Theme.typography.sm
                    font.family: Theme.typography.fontFamily

                    Behavior on color { 
                      ColorAnimation { duration: 150 } 
                    }
                  }

                  MouseArea {
                    id: closeMouseArea
                    anchors.fill: parent
                    anchors.margins: -4
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: loader.manager.removeNotification(index)
                  }
                }
              }

              // Divider
              Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Theme.outline_variant
                opacity: 0.6
              }

              // Content section
              ColumnLayout {
                Layout.fillWidth: true
                spacing: Theme.spacing.sm

                // Summary (bold)
                Text {
                  Layout.fillWidth: true
                  text: modelData.summary
                  color: Theme.on_surface
                  font.pixelSize: Theme.typography.md
                  font.family: Theme.typography.fontFamily
                  font.weight: Theme.typography.weightMedium
                  wrapMode: Text.WordWrap
                  maximumLineCount: 2
                  elide: Text.ElideRight
                }

                // Body (muted)
                Text {
                  Layout.fillWidth: true
                  text: modelData.body
                  color: Theme.on_surface_variant
                  font.pixelSize: Theme.typography.sm
                  font.family: Theme.typography.fontFamily
                  wrapMode: Text.WordWrap
                  maximumLineCount: 3
                  elide: Text.ElideRight
                  visible: text !== ""
                  opacity: 0.8
                }
              }

              // Bottom divider (subtle)
              Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Theme.outline_variant
                opacity: 0.4
                visible: modelData.date !== "" || modelData.time !== ""
              }

              // Timestamp (bottom right)
              Text {
                Layout.fillWidth: true
                Layout.bottomMargin: Theme.padding.md
                text: modelData.date + (modelData.date && modelData.time ? " · " : "") + modelData.time
                color: Theme.on_surface_variant
                font.pixelSize: Theme.typography.xs
                font.family: Theme.typography.fontFamily
                opacity: 0.7
                horizontalAlignment: Text.AlignRight
              }
            }

              // Hover detection
              MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                propagateComposedEvents: true
                
                onEntered: notifCard.hovered = true
                onExited: notifCard.hovered = false
                
                onClicked: mouse => {
                  mouse.accepted = false
                }
              }
            }
          }

          // Empty state
          Item {
            anchors.centerIn: parent
            width: parent.width
            height: 200
            visible: notifList.count === 0

            ColumnLayout {
              anchors.centerIn: parent
              spacing: Theme.spacing.md

              // Icon container
              Rectangle {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 64
                Layout.preferredHeight: 64
                radius: Theme.radius.full
                color: Theme.surface_container_high

                Text {
                  anchors.centerIn: parent
                  text: "󰂚"
                  color: Theme.on_surface_variant
                  font.pixelSize: Theme.typography.xxxl
                  font.family: Theme.typography.fontFamily
                  opacity: 0.6
                }
              }

              Text {
                Layout.alignment: Qt.AlignHCenter
                text: "No notifications"
                color: Theme.on_surface
                font.pixelSize: Theme.typography.md
                font.family: Theme.typography.fontFamily
                font.weight: Theme.typography.weightMedium
                opacity: 0.8
              }

              Text {
                Layout.alignment: Qt.AlignHCenter
                text: "You're all caught up"
                color: Theme.on_surface_variant
                font.pixelSize: Theme.typography.sm
                font.family: Theme.typography.fontFamily
                opacity: 0.6
              }
            }
          }
        }
      }
    }
  }
}
