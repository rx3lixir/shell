import QtQuick
import "../../theme"

GridView {
  id: gridView
  
  // Properties exposed to parent
  property var wallpapers: []
  property int selectedIndex: 0
  property string currentWallpaper: ""
  property string wallpaperDir: ""
  
  // Signals
  signal wallpaperSelected(string filename)
  signal indexSelected(int index)
  
  clip: true
  
  cellWidth: 280
  cellHeight: 200
  
  model: wallpapers
  
  currentIndex: selectedIndex
  
  // Function to position view at index (exposed for keyboard nav)
  function positionViewAtIndex(index, mode) {
    GridView.positionViewAtIndex(index, mode)
  }
  
  delegate: WallpaperGridItem {
    required property string modelData
    required property int index
    
    width: gridView.cellWidth
    height: gridView.cellHeight
    
    filename: modelData
    itemIndex: index
    isSelected: index === gridView.selectedIndex
    isCurrent: gridView.currentWallpaper === modelData
    wallpaperPath: gridView.wallpaperDir + "/" + modelData
    
    onClicked: {
      gridView.indexSelected(index)
      gridView.wallpaperSelected(modelData)
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
    
    // Scrollbar track (subtle)
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
