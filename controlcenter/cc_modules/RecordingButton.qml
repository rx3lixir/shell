import QtQuick
import QtQuick.Layouts
import "../../theme"

Rectangle {
  id: root
  
  // Changed: now receives specific sub-manager
  required property var recordingManager
  
  radius: Theme.radiusXLarge
  color: mouseArea.containsMouse ? Theme.bg2 : Theme.bg2transparent
  border.color: recordingManager.isRecording ? Theme.error : "transparent"
  border.width: 2
  
  Component.onCompleted: {
    console.log("RecordingButton module loaded")
  }
  
  RowLayout {
    anchors {
      fill: parent
      margins: Theme.spacingM
    }
    spacing: Theme.spacingS
    
    Text {
      text: recordingManager.isRecording ? "󰑊" : "󰻃"
      color: recordingManager.isRecording ? Theme.error : Theme.fg
      font.pixelSize: Theme.fontSizeXL
      font.family: Theme.fontFamily
    }
    
    ColumnLayout {
      Layout.fillWidth: true
      spacing: 2
      
      Text {
        text: "Screen Recording"
        color: Theme.fg
        font.pixelSize: Theme.fontSizeM
        font.family: Theme.fontFamily
      }
      
      Text {
        text: recordingManager.isRecording ? "Recording..." : "Start Recording"
        color: Theme.fgMuted
        font.pixelSize: Theme.fontSizeS
        font.family: Theme.fontFamily
      }
    }
  }
  
  MouseArea {
    id: mouseArea
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    
    onClicked: {
      console.log("Recording tile clicked")
      recordingManager.toggleRecording()
    }
  }
}
