import QtQuick
import QtQuick.Layouts
import "../../theme"

Rectangle {
  id: root
  
  property var groups: []
  property string selectedGroup: ""
  signal groupSelected(string group)
  
  color: "transparent"
  
  // Horizontal scrolling list of group buttons
  ListView {
    anchors.fill: parent
    orientation: ListView.Horizontal
    spacing: Theme.spacingS
    clip: true
    
    model: {
      // Add "All" option at the beginning
      var allGroups = ["All"]
      return allGroups.concat(root.groups)
    }
    
    delegate: Rectangle {
      required property string modelData
      required property int index
      
      height: parent.height
      width: groupText.width + Theme.spacingM * 2
      radius: Theme.radiusLarge
      
      color: {
        var isSelected = (modelData === "All" && root.selectedGroup === "") || 
                         (modelData === root.selectedGroup)
        if (isSelected) return Theme.accent
        if (groupMouseArea.containsMouse) return Theme.bg2transparent
        return Theme.bg2transparent
      }
      
      Behavior on color {
        ColorAnimation {
          duration: 150
          easing.type: Easing.OutCubic
        }
      }
      
      Text {
        id: groupText
        anchors.centerIn: parent
        text: modelData
        color: {
          var isSelected = (modelData === "All" && root.selectedGroup === "") || 
                           (modelData === root.selectedGroup)
          return isSelected ? Theme.bg1 : Theme.fg
        }
        font.pixelSize: Theme.fontSizeS
        font.family: Theme.fontFamily
        font.bold: {
          var isSelected = (modelData === "All" && root.selectedGroup === "") || 
                           (modelData === root.selectedGroup)
          return isSelected
        }
        
        Behavior on color {
          ColorAnimation {
            duration: 150
            easing.type: Easing.OutCubic
          }
        }
      }
      
      MouseArea {
        id: groupMouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        
        onClicked: {
          if (modelData === "All") {
            root.groupSelected("")
          } else {
            root.groupSelected(modelData)
          }
        }
      }
    }
  }
}
