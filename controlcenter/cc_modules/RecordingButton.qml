import QtQuick
import QtQuick.Layouts
import "../../theme"

Rectangle {
  id: root
  
  required property var recordingManager
  
  radius: 32
  color: Theme.bg2
  border.width: recordingManager.isRecording ? 2 : 1
  border.color: recordingManager.isRecording ? Theme.error : Theme.borderDim
  
  Behavior on border.width {
    NumberAnimation { duration: 200 }
  }
  
  Behavior on border.color {
    ColorAnimation { duration: 250 }
  }
  
  // Shadow layer 1 (closest)
  Rectangle {
    anchors.fill: parent
    anchors.margins: -2
    radius: parent.radius + 2
    color: "transparent"
    border.width: 2
    border.color: recordingManager.isRecording ? "#30E82424" : "#20000000"
    z: -1
    opacity: mouseArea.containsMouse ? 1 : 0.6
    
    Behavior on opacity {
      NumberAnimation { duration: 200 }
    }
    
    Behavior on border.color {
      ColorAnimation { duration: 250 }
    }
  }
  
  // Shadow layer 2 (outer)
  Rectangle {
    anchors.fill: parent
    anchors.margins: -4
    radius: parent.radius + 4
    color: "transparent"
    border.width: 2
    border.color: recordingManager.isRecording ? "#20E82424" : "#15000000"
    z: -2
    opacity: mouseArea.containsMouse ? 0.8 : 0.4
    
    Behavior on opacity {
      NumberAnimation { duration: 200 }
    }
    
    Behavior on border.color {
      ColorAnimation { duration: 250 }
    }
  }
  
  // Subtle background tint when recording
  Rectangle {
    anchors.fill: parent
    radius: parent.radius
    color: Theme.error
    opacity: recordingManager.isRecording ? 0.08 : 0
    
    Behavior on opacity {
      NumberAnimation { duration: 300 }
    }
  }
  
  RowLayout {
    anchors {
      fill: parent
      margins: Theme.spacingM
      topMargin: 10
      bottomMargin: 10 
      leftMargin: 16
      rightMargin: 16
    }
    spacing: 10
    
    // Icon with container
    Rectangle {
      Layout.preferredWidth: 40
      Layout.preferredHeight: 40
      Layout.alignment: Qt.AlignVCenter
      radius: 20
      
      scale: mouseArea.pressed ? 0.85 : 1.0
      
      Behavior on scale {
        NumberAnimation { 
          duration: 150
          easing.type: Easing.OutBack
          easing.overshoot: 2
        }
      }
      
      color: recordingManager.isRecording ? Theme.error : Qt.darker(Theme.accent, 1.6)
      
      Behavior on color {
        ColorAnimation { duration: 250 }
      }
      
      // Simple pulse glow when recording
      Rectangle {
        anchors.centerIn: parent
        width: parent.width + 8
        height: parent.height + 8
        radius: (parent.width + 8) / 2
        color: "transparent"
        border.width: recordingManager.isRecording ? 4 : 0
        border.color: "#25E82424"
        z: -1
        
        Behavior on border.width {
          NumberAnimation { duration: 250 }
        }
        
        // Gentle pulse
        SequentialAnimation on opacity {
          running: recordingManager.isRecording
          loops: Animation.Infinite
          NumberAnimation { to: 1.0; duration: 1200; easing.type: Easing.InOutQuad }
          NumberAnimation { to: 0.4; duration: 1200; easing.type: Easing.InOutQuad }
        }
      }
      
      Text {
        anchors.centerIn: parent
        text: recordingManager.isRecording ? "󰑊" : "󰻃"
        color: recordingManager.isRecording ? Theme.fg : Theme.accent
        font.pixelSize: 20
        font.family: Theme.fontFamily
        
        Behavior on color {
          ColorAnimation { duration: 250 }
        }
      }
    }
    
    ColumnLayout {
      Layout.fillWidth: true
      Layout.alignment: Qt.AlignVCenter
      spacing: 2
      
      Text {
        text: "Record"
        color: Theme.fg
        font.pixelSize: 14
        font.family: Theme.fontFamily
        font.weight: Font.Medium
      }
      
      Text {
        text: recordingManager.isRecording ? "Recording..." : "Screen"
        color: recordingManager.isRecording ? Theme.error : Theme.fgMuted
        font.pixelSize: 12
        font.family: Theme.fontFamily
        opacity: 0.8
        
        Behavior on color {
          ColorAnimation { duration: 250 }
        }
      }
    }
  }
  
  MouseArea {
    id: mouseArea
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    
    onClicked: {
      recordingManager.toggleRecording()
    }
  }
}
