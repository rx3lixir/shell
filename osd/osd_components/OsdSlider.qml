import QtQuick
import "../../theme"

Item {
  id: root
  
  property real value: 0.5
  property bool isDragging: false  // Expose drag state
  signal sliderMoved(real newValue)
  
  implicitHeight: 50
  
  // Track background
  Rectangle {
    id: track
    anchors {
      left: parent.left
      right: parent.right
      top: parent.top
    }
    height: 6
    radius: 3
    color: Theme.border
    
    // Filled portion
    Rectangle {
      anchors {
        left: parent.left
        top: parent.top
        bottom: parent.bottom
      }
      width: parent.width * root.value
      radius: parent.radius
      color: Theme.accent
      
      Behavior on width {
        NumberAnimation {
          duration: 100
          easing.type: Easing.OutCubic
        }
      }
    }
  }
  
  // Draggable handle
  Rectangle {
    id: handle
    x: Math.max(0, Math.min(parent.width - width, (parent.width - width) * root.value))
    y: track.y + (track.height - height) / 2
    width: 16
    height: 16
    radius: 8
    color: handleMouseArea.drag.active || handleMouseArea.containsMouse ? Theme.accent : Theme.fg
    border.color: Theme.bg1
    border.width: 2
    
    Behavior on x {
      enabled: !handleMouseArea.drag.active
      NumberAnimation {
        duration: 100
        easing.type: Easing.OutCubic
      }
    }
    
    Behavior on color {
      ColorAnimation {
        duration: 150
        easing.type: Easing.OutCubic
      }
    }
    
    MouseArea {
      id: handleMouseArea
      anchors.fill: parent
      anchors.margins: -8  // Bigger hit area
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      
      drag.target: handle
      drag.axis: Drag.XAxis
      drag.minimumX: 0
      drag.maximumX: root.width - handle.width
      
      onPressed: {
        root.isDragging = true  // Signal that dragging started
      }
      
      onPositionChanged: {
        if (drag.active) {
          var newValue = (handle.x + handle.width / 2) / root.width
          newValue = Math.max(0, Math.min(1, newValue))
          
          root.value = newValue
          root.sliderMoved(newValue)
        }
      }
      
      onReleased: {
        root.isDragging = false  // Signal that dragging ended
      }
    }
  }
  
  // Click on track to jump
  MouseArea {
    anchors.fill: track
    z: -1
    
    onClicked: mouse => {
      var newValue = mouse.x / track.width
      newValue = Math.max(0, Math.min(1, newValue))
      
      root.value = newValue
      root.sliderMoved(newValue)
    }
  }
  
  // Segment markers (spikes) below the slider
  Row {
    anchors {
      left: parent.left
      right: parent.right
      top: track.bottom
      topMargin: 8
    }
    height: 20
    
    Repeater {
      model: [
        { pos: 0.0, label: "" },
        { pos: 0.10, label: "" },
        { pos: 0.20, label: "" },
        { pos: 0.30, label: "" },
        { pos: 0.40, label: "" },
        { pos: 0.50, label: "" },
        { pos: 0.60, label: "" },
        { pos: 0.70, label: "" },
        { pos: 0.80, label: "" },
        { pos: 0.90, label: "" },
        { pos: 1, label: "" },
      ]
      
      delegate: Item {
        required property var modelData
        required property int index
        
        x: parent.width * modelData.pos
        width: 1
        height: parent.height
        
        // Spike line
        Rectangle {
          anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.top
          }
          width: 2
          height: 5
          color: Theme.fgMuted
        }
        
        // Label
        Text {
          anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.top
            topMargin: 8
          }
          text: modelData.label
          color: Theme.fgMuted
          font.pixelSize: Theme.fontSizeXS
          font.family: Theme.fontFamily
          visible: modelData.label !== ""
        }
      }
    }
  }
}
