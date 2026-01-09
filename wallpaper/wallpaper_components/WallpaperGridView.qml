import QtQuick
import "../../theme"

GridView {
  id: gridView
  
  // ============================================================================
  // PUBLIC API
  // ============================================================================
  
  property var wallpapers: []
  property int selectedIndex: 0
  property string currentWallpaper: ""
  property string wallpaperDir: ""
  property string thumbnailDir: ""
  
  signal wallpaperSelected(string filename)
  signal indexSelected(int index)
  
  // ============================================================================
  // DYNAMIC COLUMN CALCULATION
  // ============================================================================
  
  // Calculate columns based on available width
  readonly property int columnsPerRow: Math.max(1, Math.floor(width / cellWidth))
  
  // ============================================================================
  // GRID CONFIGURATION
  // ============================================================================
  
  clip: true
  
  cellWidth: 280
  cellHeight: 200
  
  model: wallpapers
  
  currentIndex: selectedIndex
  
  // Smooth scrolling
  maximumFlickVelocity: 2000
  flickDeceleration: 1500
  
  // Optimize performance
  cacheBuffer: cellHeight * 3  // Cache 3 rows above/below
  displayMarginBeginning: cellHeight * 2
  displayMarginEnd: cellHeight * 2
  
  // ============================================================================
  // SELECTION HANDLING
  // ============================================================================
  
  // Watch for selectedIndex changes and position view accordingly
  onSelectedIndexChanged: {
    positionViewAtIndex(selectedIndex, GridView.Contain)
  }
  
  // ============================================================================
  // DELEGATE
  // ============================================================================
  
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
    thumbnailPath: gridView.thumbnailDir + "/" + modelData.replace(/\.[^/.]+$/, "") + ".jpg"
    
    onClicked: {
      gridView.indexSelected(index)
      gridView.wallpaperSelected(modelData)
    }
  }
  
  // ============================================================================
  // MATERIAL 3 SCROLLBAR
  // ============================================================================
  
  Rectangle {
    anchors {
      right: parent.right
      top: parent.top
      bottom: parent.bottom
      rightMargin: Theme.spacing.xs
      topMargin: Theme.spacing.xs
      bottomMargin: Theme.spacing.xs
    }
    width: 6
    radius: Theme.radius.sm
    color: "transparent"
    visible: gridView.contentHeight > gridView.height
    
    // Scrollbar track (subtle)
    Rectangle {
      anchors.fill: parent
      radius: parent.radius
      color: Theme.outline_variant
      opacity: 0.3
    }
    
    // Scrollbar thumb
    Rectangle {
      width: parent.width
      height: {
        if (gridView.contentHeight <= gridView.height) return 0
        var ratio = gridView.height / gridView.contentHeight
        return Math.max(40, parent.height * ratio)
      }
      y: {
        if (gridView.contentHeight <= gridView.height) return 0
        var maxY = parent.height - height
        var progress = gridView.contentY / (gridView.contentHeight - gridView.height)
        return maxY * progress
      }
      radius: parent.radius
      color: scrollThumbMouseArea.containsMouse ? Theme.primary : Theme.outline
      opacity: scrollThumbMouseArea.containsMouse ? 0.8 : 0.6
      
      Behavior on y {
        NumberAnimation {
          duration: 100
          easing.type: Easing.OutCubic
        }
      }
      
      Behavior on color {
        ColorAnimation {
          duration: 200
          easing.type: Easing.OutCubic
        }
      }
      
      Behavior on opacity {
        NumberAnimation {
          duration: 200
          easing.type: Easing.OutCubic
        }
      }
      
      MouseArea {
        id: scrollThumbMouseArea
        anchors.fill: parent
        anchors.margins: -4
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
      }
    }
  }
  
  // ============================================================================
  // DEBUG INFO (can be removed in production)
  // ============================================================================
  
  Component.onCompleted: {
    console.log("[WallpaperGridView] Initialized")
    console.log("[WallpaperGridView] Cell size:", cellWidth, "x", cellHeight)
    console.log("[WallpaperGridView] Columns:", columnsPerRow)
    console.log("[WallpaperGridView] Cache buffer:", cacheBuffer)
  }
}
