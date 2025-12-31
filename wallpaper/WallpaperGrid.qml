import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import "../theme"
import "wallpaper_components" as Components

LazyLoader {
  id: loader
  
  required property var manager
  
  active: manager.visible
  
  PanelWindow {
    id: wallpaperWindow
    
    // Fill screen - wallpaper grid will be centered
    anchors {
      top: true
      left: true
      bottom: true
      right: true
    }
    
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    
    color: "transparent"
    mask: null
    
    Component.onCompleted: {
      console.log("[WallpaperGrid] Window loaded")
      exclusiveZone = 0
    }
    
    // Search and selection state
    property string searchText: ""
    property int selectedIndex: 0
    property var filteredWallpapers: []
    
    // Filter wallpapers based on search
    function updateFilteredWallpapers() {
      var search = wallpaperWindow.searchText.toLowerCase()
      
      if (!search) {
        wallpaperWindow.filteredWallpapers = loader.manager.wallpapers
      } else {
        // Fuzzy search
        var filtered = []
        for (var i = 0; i < loader.manager.wallpapers.length; i++) {
          var name = loader.manager.wallpapers[i].toLowerCase()
          
          // Simple fuzzy: check if all search chars appear in order
          var searchIdx = 0
          for (var j = 0; j < name.length && searchIdx < search.length; j++) {
            if (name[j] === search[searchIdx]) {
              searchIdx++
            }
          }
          
          if (searchIdx === search.length) {
            filtered.push(loader.manager.wallpapers[i])
          }
        }
        wallpaperWindow.filteredWallpapers = filtered
      }
      
      // Reset selection to first item
      wallpaperWindow.selectedIndex = 0
      
      console.log("[WallpaperGrid] Filtered:", wallpaperWindow.filteredWallpapers.length, "wallpapers")
    }
    
    // Update filtered list when wallpapers change
    Connections {
      target: loader.manager
      function onWallpapersChanged() {
        wallpaperWindow.updateFilteredWallpapers()
      }
    }
    
    // Handle keyboard navigation
    contentItem {
      focus: true
      
      Keys.onPressed: event => {
        if (event.key === Qt.Key_Escape) {
          loader.manager.visible = false
          event.accepted = true
        }
        else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
          // Select current wallpaper
          if (wallpaperWindow.selectedIndex >= 0 && 
              wallpaperWindow.selectedIndex < wallpaperWindow.filteredWallpapers.length) {
            var selected = wallpaperWindow.filteredWallpapers[wallpaperWindow.selectedIndex]
            console.log("[WallpaperGrid] Selected via Enter:", selected)
            loader.manager.setWallpaper(selected)
          }
          event.accepted = true
        }
        else if (event.key === Qt.Key_Up || (event.key === Qt.Key_P && (event.modifiers & Qt.ControlModifier))) {
          // Move up (left in grid)
          if (wallpaperWindow.selectedIndex > 0) {
            wallpaperWindow.selectedIndex--
            gridView.positionViewAtIndex(wallpaperWindow.selectedIndex, GridView.Contain)
          }
          event.accepted = true
        }
        else if (event.key === Qt.Key_Down || (event.key === Qt.Key_N && (event.modifiers & Qt.ControlModifier))) {
          // Move down (right in grid)
          if (wallpaperWindow.selectedIndex < wallpaperWindow.filteredWallpapers.length - 1) {
            wallpaperWindow.selectedIndex++
            gridView.positionViewAtIndex(wallpaperWindow.selectedIndex, GridView.Contain)
          }
          event.accepted = true
        }
        else if (event.key === Qt.Key_Left) {
          // Move left by 3 (one row up)
          if (wallpaperWindow.selectedIndex >= 3) {
            wallpaperWindow.selectedIndex -= 3
            gridView.positionViewAtIndex(wallpaperWindow.selectedIndex, GridView.Contain)
          }
          event.accepted = true
        }
        else if (event.key === Qt.Key_Right) {
          // Move right by 3 (one row down)
          if (wallpaperWindow.selectedIndex + 3 < wallpaperWindow.filteredWallpapers.length) {
            wallpaperWindow.selectedIndex += 3
            gridView.positionViewAtIndex(wallpaperWindow.selectedIndex, GridView.Contain)
          }
          event.accepted = true
        }
      }
    }
    
    // Click outside to close
    MouseArea {
      anchors.fill: parent
      onClicked: {
        loader.manager.visible = false
      }
    }
    
    // Main container - centered and bigger
    Rectangle {
      id: container
      x: (parent.width - 900) / 2
      y: (parent.height - 700) / 2
      width: 900
      height: 700
      radius: Theme.radiusXLarge
      color: Theme.bg1transparentLauncher
      
      // Prevent clicks on container from closing
      MouseArea {
        anchors.fill: parent
      }
      
      ColumnLayout {
        anchors {
          fill: parent
          margins: Theme.spacingL
        }
        spacing: Theme.spacingM
        
        // Header
        RowLayout {
          Layout.fillWidth: true
          spacing: Theme.spacingS
          
          Text {
            Layout.fillWidth: true
            text: "Select Wallpaper"
            color: Theme.fg
            font.pixelSize: Theme.fontSizeL
            font.family: Theme.fontFamily
            font.bold: true
          }
          
          // Refresh button
          Rectangle {
            Layout.preferredWidth: 32
            Layout.preferredHeight: 32
            radius: Theme.radiusLarge
            color: refreshMouseArea.containsMouse ? Theme.bg2 : "transparent"
            
            Text {
              anchors.centerIn: parent
              text: "󰑐"
              color: Theme.fg
              font.pixelSize: Theme.fontSizeL
              font.family: Theme.fontFamily
            }
            
            MouseArea {
              id: refreshMouseArea
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              
              onClicked: {
                loader.manager.refreshWallpapers()
              }
            }
          }
          
          // Close button
          Rectangle {
            Layout.preferredWidth: 32
            Layout.preferredHeight: 32
            radius: Theme.radiusLarge
            color: closeMouseArea.containsMouse ? Theme.bg2 : "transparent"
            
            Text {
              anchors.centerIn: parent
              text: "✕"
              color: Theme.fg
              font.pixelSize: Theme.fontSizeM
              font.family: Theme.fontFamily
            }
            
            MouseArea {
              id: closeMouseArea
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              
              onClicked: {
                loader.manager.visible = false
              }
            }
          }
        }
        
        // Search bar
        Components.WallpaperSearchBar {
          Layout.fillWidth: true
          Layout.preferredHeight: 40
          
          onSearchChanged: text => {
            wallpaperWindow.searchText = text
            wallpaperWindow.updateFilteredWallpapers()
          }
        }
        
        // Loading indicator
        Text {
          Layout.fillWidth: true
          Layout.alignment: Qt.AlignCenter
          text: "Loading wallpapers..."
          color: Theme.fgMuted
          font.pixelSize: Theme.fontSizeM
          font.family: Theme.fontFamily
          horizontalAlignment: Text.AlignHCenter
          visible: loader.manager.isLoading
        }
        
        // Error message
        Text {
          Layout.fillWidth: true
          Layout.alignment: Qt.AlignCenter
          text: loader.manager.errorMessage
          color: Theme.error
          font.pixelSize: Theme.fontSizeS
          font.family: Theme.fontFamily
          horizontalAlignment: Text.AlignHCenter
          wrapMode: Text.WordWrap
          visible: loader.manager.errorMessage !== ""
        }
        
        // Wallpaper grid
        Components.WallpaperGridView {
          id: gridView
          Layout.fillWidth: true
          Layout.fillHeight: true
          
          visible: !loader.manager.isLoading && loader.manager.errorMessage === ""
          
          wallpapers: wallpaperWindow.filteredWallpapers
          selectedIndex: wallpaperWindow.selectedIndex
          currentWallpaper: loader.manager.currentWallpaper
          wallpaperDir: loader.manager.wallpaperDir
          
          onWallpaperSelected: filename => {
            console.log("[WallpaperGrid] Selected via click:", filename)
            loader.manager.setWallpaper(filename)
          }
          
          onIndexSelected: index => {
            wallpaperWindow.selectedIndex = index
          }
        }
        
        // Empty state
        Text {
          Layout.fillWidth: true
          Layout.fillHeight: true
          text: wallpaperWindow.searchText ? 
                "No wallpapers match '" + wallpaperWindow.searchText + "'" : 
                "No wallpapers found in " + loader.manager.wallpaperDir
          color: Theme.fgMuted
          font.pixelSize: Theme.fontSizeM
          font.family: Theme.fontFamily
          horizontalAlignment: Text.AlignHCenter
          verticalAlignment: Text.AlignVCenter
          visible: !loader.manager.isLoading && 
                   wallpaperWindow.filteredWallpapers.length === 0 && 
                   loader.manager.errorMessage === ""
        }
        
        // Footer hint
        Text {
          Layout.fillWidth: true
          text: "↑↓ Navigate • ←→ Row • Ctrl+N/P • Enter Select • Esc Close"
          color: Theme.fgMuted
          font.pixelSize: Theme.fontSizeS
          font.family: Theme.fontFamily
          horizontalAlignment: Text.AlignHCenter
          visible: !loader.manager.isLoading
        }
      }
    }
  }
}
