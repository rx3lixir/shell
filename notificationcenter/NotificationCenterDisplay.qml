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
    id: notifCenterWindow

    anchors {
      top: true
      right: true
    }

    margins {
      top: Theme.barHeight + Theme.spacingM
      right: Theme.spacingM
    }

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    color: "transparent"
    mask: null

    Component.onCompleted: {
      exclusiveZone = 0
      implicitWidth = 320
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
      onClicked: loader.manager.visible = false
    }

    Rectangle {
      id: background
      anchors.fill: parent
      radius: 20
      color: Theme.bg1transparent
      border.width: 1
      border.color: Qt.lighter(Theme.bg1, 1.3)

      ColumnLayout {
        anchors {
          fill: parent
          margins: Theme.spacingM
        }
        spacing: Theme.spacingS

        // ========== HEADER ==========
        RowLayout {
          Layout.fillWidth: true
          Layout.preferredHeight: 36
          spacing: Theme.spacingS

          Text {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            text: "Notifications"
            color: Theme.fg
            font.pixelSize: 16
            font.family: Theme.fontFamily
            font.weight: Font.Medium
          }

          Rectangle {
            Layout.preferredWidth: 70
            Layout.preferredHeight: 32
            Layout.alignment: Qt.AlignVCenter
            radius: 16
            color: clearMouseArea.containsMouse ? Theme.bg2 : Qt.lighter(Theme.bg2, 1.1)
            border.width: 1
            border.color: Theme.borderDim
            visible: loader.manager.notifications.length > 0

            scale: clearMouseArea.pressed ? 0.95 : 1.0

            Behavior on color { ColorAnimation { duration: 150 } }
            Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }

            Text {
              anchors.centerIn: parent
              text: "Clear All"
              color: Theme.fg
              font.pixelSize: 12
              font.family: Theme.fontFamily
              font.weight: Font.Medium
            }

            MouseArea {
              id: clearMouseArea
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: loader.manager.clearAll()
            }
          }

          Rectangle {
            Layout.preferredWidth: 36
            Layout.preferredHeight: 36
            Layout.alignment: Qt.AlignVCenter
            radius: 18
            color: closeMouseArea.containsMouse ? Theme.bg2 : Theme.bg1

            Behavior on color { ColorAnimation { duration: 100 } }

            Text {
              anchors.centerIn: parent
              text: "✕"
              color: Theme.fg
              font.pixelSize: 16
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

        // ========== NOTIFICATIONS LIST ==========
        ListView {
          id: notifList
          Layout.fillWidth: true
          Layout.fillHeight: true
          clip: true
          spacing: 10

          model: loader.manager.notifications

          Behavior on contentY {
            NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
          }

          delegate: Rectangle {
            required property var modelData
            required property int index

            width: notifList.width
            height: notifContent.implicitHeight + (Theme.spacingM * 2)
            radius: 20
            color: Theme.bg1
            border.width: 1
            border.color: Theme.borderDim

            property bool hovered: false

            Behavior on radius {
              NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
            }

            MouseArea {
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              z: 1

              onEntered: parent.hovered = true
              onExited: parent.hovered = false
              onClicked: mouse.accepted = false
            }

            states: State {
              name: "hovered"
              when: hovered
              PropertyChanges { target: parent; radius: 24 }
            }

            transitions: Transition {
              to: "hovered"; reversible: true
              NumberAnimation { property: "radius"; duration: 200; easing.type: Easing.OutCubic }
            }

            ColumnLayout {
              id: notifContent
              anchors.fill: parent
              anchors.margins: Theme.spacingM
              spacing: Theme.spacingXS

              // Header: app name + close button only (no icon)
              RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingXS

                Text {
                  Layout.fillWidth: true
                  Layout.alignment: Qt.AlignVCenter
                  text: modelData.appName
                  color: Theme.fgMuted
                  font.pixelSize: Theme.fontSizeS
                  font.family: Theme.fontFamily
                  elide: Text.ElideRight
                  opacity: 0.8
                }

                Rectangle {
                  Layout.preferredWidth: 24
                  Layout.preferredHeight: 24
                  Layout.alignment: Qt.AlignVCenter
                  radius: 12
                  color: closeNotifMouseArea.containsMouse ? Theme.bg2 : "transparent"

                  Behavior on color { ColorAnimation { duration: 100 } }

                  Text {
                    anchors.centerIn: parent
                    text: "✕"
                    color: closeNotifMouseArea.containsMouse ? Theme.fg : Theme.fgMuted
                    font.pixelSize: 12
                    font.family: Theme.fontFamily

                    Behavior on color { ColorAnimation { duration: 100 } }
                  }

                  MouseArea {
                    id: closeNotifMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: loader.manager.removeNotification(index)
                  }
                }
              }

              // First divider
              Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Theme.borderDim
                opacity: 0.3
              }

              // Main content
              ColumnLayout {
                Layout.fillWidth: true
                spacing: 6

                Text {
                  Layout.fillWidth: true
                  text: modelData.summary
                  color: Theme.fg
                  font.pixelSize: Theme.fontSizeM
                  font.family: Theme.fontFamily
                  font.weight: Font.Medium
                  wrapMode: Text.WordWrap
                  maximumLineCount: 1
                  elide: Text.ElideRight
                }

                Text {
                  Layout.fillWidth: true
                  text: modelData.body
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

              // Second divider (before timestamp)
              Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Theme.borderDim
                opacity: 0.2
                visible: modelData.date !== "" || modelData.time !== ""
              }

              // Timestamp
              Text {
                Layout.fillWidth: true
                Layout.bottomMargin: 4
                text: modelData.date + (modelData.date && modelData.time ? " · " : "") + modelData.time
                color: Theme.fgMuted
                font.pixelSize: 10
                font.family: Theme.fontFamily
                opacity: 0.7
                horizontalAlignment: Text.AlignRight
              }
            }
          }

          // Empty state
          Item {
            anchors.centerIn: parent
            width: parent.width
            height: 160
            visible: notifList.count === 0

            ColumnLayout {
              anchors.centerIn: parent
              spacing: 12

              Rectangle {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 56
                Layout.preferredHeight: 56
                radius: 28
                color: Qt.lighter(Theme.bg2, 1.2)

                Text {
                  anchors.centerIn: parent
                  text: "󰂚"
                  color: Theme.fgMuted
                  font.pixelSize: 28
                  font.family: Theme.fontFamily
                  opacity: 0.6
                }
              }

              Text {
                Layout.alignment: Qt.AlignHCenter
                text: "No notifications"
                color: Theme.fgMuted
                font.pixelSize: 13
                font.family: Theme.fontFamily
                opacity: 0.8
              }
            }
          }
        }
      }
    }
  }
}
