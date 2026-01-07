import QtQuick
import QtQuick.Layouts
import "../theme"

ColumnLayout {
  id: root

  // Public API
  required property real value           // 0.0 to 1.0
  signal moved(real newValue)

  property real minimumValue: 0.0
  property real maximumValue: 1.0
  property int tickCount: 11

  spacing: 4

  Item {
    Layout.fillWidth: true
    Layout.preferredHeight: 14

    // Track
    Rectangle {
      id: track
      anchors {
        left: parent.left
        right: parent.right
        verticalCenter: parent.verticalCenter
      }
      height: 6
      radius: Theme.radius.sm
      color: Theme.outline

      // Progress fill
      Rectangle {
        anchors {
          left: parent.left
          top: parent.top
          bottom: parent.bottom
        }
        width: Math.max(0, Math.min(parent.width, parent.width * root.value))
        radius: parent.radius
        color: Theme.primary

        Behavior on width {
          NumberAnimation { duration: 100; easing.type: Easing.OutCubic }
        }
      }
    }

    // Handle
    Rectangle {
      id: handle
      x: Math.max(0, Math.min(parent.width - width, (parent.width - width) * root.value))
      anchors.verticalCenter: parent.verticalCenter
      width: 18
      height: 18
      radius: Theme.radius.full
      color: Theme.primary
      border.color: Theme.surface_container_low
      border.width: 3

      scale: handleMouseArea.drag.active || handleMouseArea.containsMouse ? 1.3 : 1.0

      Behavior on x {
        enabled: !handleMouseArea.drag.active
        NumberAnimation { duration: 100; easing.type: Easing.OutCubic }
      }

      Behavior on scale {
        NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
      }

      MouseArea {
        id: handleMouseArea
        anchors.fill: parent
        anchors.margins: -8
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        drag.target: parent
        drag.axis: Drag.XAxis
        drag.minimumX: 0
        drag.maximumX: track.width - handle.width

        onPositionChanged: if (drag.active) {
          const newValue = (handle.x + handle.width / 2) / track.width
          const clamped = Math.max(root.minimumValue, Math.min(root.maximumValue, newValue))
          root.moved(clamped)
        }
      }
    }

    // Click to jump
    MouseArea {
      anchors.fill: track
      z: -1
      onClicked: mouse => {
        const newValue = mouse.x / track.width
        const clamped = Math.max(root.minimumValue, Math.min(root.maximumValue, newValue))
        root.moved(clamped)
      }
    }
  }
}
