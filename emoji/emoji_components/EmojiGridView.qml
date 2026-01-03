import QtQuick
import "../../theme"

GridView {
  id: gridView
  
  // Properties
  property var emojis: []
  property int selectedIndex: 0
  
  // Signals
  signal emojiSelected(string emoji)
  signal indexSelected(int index)
  
  clip: true
  
  cellWidth: 70
  cellHeight: 70
  
  model: emojis
  
  currentIndex: selectedIndex
  
  // Function to position view at index (exposed for keyboard nav)
  function positionViewAtIndex(index, mode) {
    GridView.positionViewAtIndex(index, mode)
  }
  
  delegate: EmojiGridItem {
    required property var modelData
    required property int index
    
    width: gridView.cellWidth
    height: gridView.cellHeight
    
    emoji: modelData.emoji
    name: modelData.name
    itemIndex: index
    isSelected: index === gridView.selectedIndex
    
    onClicked: {
      gridView.indexSelected(index)
      gridView.emojiSelected(modelData.emoji)
    }
  }
  
  // Elegant minimal scrollbar
  Rectangle {
    anchors {
      right: parent.right
      top: parent.top
      bottom: parent.bottom
      rightMargin: 2
      topMargin: 2
      bottomMargin: 2
    }
    width: 4
    radius: 2
    color: "transparent"
    visible: gridView.contentHeight > gridView.height
    
    // Scrollbar track
    Rectangle {
      anchors.fill: parent
      radius: parent.radius
      color: Theme.borderDim
      opacity: 0.2
    }
    
    // Scrollbar thumb
    Rectangle {
      width: parent.width
      height: {
        if (gridView.contentHeight <= gridView.height) return 0
        return Math.max(30, parent.height * (gridView.height / gridView.contentHeight))
      }
      y: {
        if (gridView.contentHeight <= gridView.height) return 0
        var maxY = parent.height - height
        var progress = gridView.contentY / (gridView.contentHeight - gridView.height)
        return maxY * progress
      }
      radius: parent.radius
      color: Theme.fgMuted
      opacity: 0.4
      
      Behavior on y {
        NumberAnimation {
          duration: 100
          easing.type: Easing.OutCubic
        }
      }
    }
  }
}
