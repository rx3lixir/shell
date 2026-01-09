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
    
    // Background overlay (same as menu/launcher)
    Rectangle {
      anchors.fill: parent
      color: Theme.scrim
      opacity: 0.2
      
      MouseArea {
        anchors.fill: parent
        onClicked: loader.manager.visible = false
      }
    }
    
    // Main container - Material 3 style
    Rectangle {
      id: container
      x: (parent.width - 900) / 2
      y: (parent.height - 700) / 2
      width: 900
      height: 700
      radius: 28
      color: Theme.surface_container
      border.width: 1
      border.color: Qt.lighter(Theme.surface_container, 1.3)
      
      // Prevent clicks on container from closing
      MouseArea {
        anchors.fill: parent
      }
      
      ColumnLayout {
        anchors {
          fill: parent
          margins: Theme.padding.xl
        }
        spacing: Theme.spacing.md
        
        // ========== HEADER ==========
        RowLayout {
          Layout.fillWidth: true
          Layout.preferredHeight: 40
          spacing: Theme.spacing.sm
          
          Text {
            Layout.fillWidth: true
            Layout.leftMargin: Theme.padding.xs
            text: "Wallpapers"
            color: Theme.on_surface
            font.pixelSize: Theme.typography.xl
            font.family: Theme.typography.fontFamily
            font.weight: Theme.typography.weightMedium
          }
          
          // Refresh button
          Text {
            Layout.preferredWidth: 32
            Layout.preferredHeight: 32
            text: "󰑐"
            color: Theme.on_surface
            font.pixelSize: Theme.typography.lg
            font.family: Theme.typography.fontFamily
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            opacity: refreshMouseArea.containsMouse ? 0.7 : 1
            
            Behavior on opacity {
              NumberAnimation { duration: 200 }
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
          Text {
            Layout.rightMargin: Theme.padding.sm
            text: "✕"
            color: Theme.on_surface
            font.pixelSize: Theme.typography.lg
            font.family: Theme.typography.fontFamily
            opacity: closeMouseArea.containsMouse ? 0.7 : 1
            
            Behavior on opacity {
              NumberAnimation { duration: 200 }
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
        
        // ========== SEARCH BAR ==========
        Components.WallpaperSearchBar {
          Layout.fillWidth: true
          Layout.preferredHeight: 48
          
          onSearchChanged: text => {
            wallpaperWindow.searchText = text
            wallpaperWindow.updateFilteredWallpapers()
          }
        }
        
        // ========== LOADING INDICATOR ==========
        Item {
          Layout.fillWidth: true
          Layout.fillHeight: true
          visible: loader.manager.isLoading
          
          ColumnLayout {
            anchors.centerIn: parent
            spacing: Theme.spacing.md
            
            // Loading spinner icon
            Rectangle {
              Layout.alignment: Qt.AlignHCenter
              Layout.preferredWidth: 64
              Layout.preferredHeight: 64
              radius: Theme.radius.full
              color: Theme.surface_container_high
              
              Text {
                anchors.centerIn: parent
                text: "󰄉"
                color: Theme.on_surface_variant
                font.pixelSize: Theme.typography.xxxl
                font.family: Theme.typography.fontFamily
                opacity: 0.6
              }
            }
            
            Text {
              Layout.alignment: Qt.AlignHCenter
              text: "Loading wallpapers..."
              color: Theme.on_surface
              font.pixelSize: Theme.typography.md
              font.family: Theme.typography.fontFamily
              font.weight: Theme.typography.weightMedium
              opacity: 0.8
            }
          }
        }
        
        // ========== ERROR MESSAGE ==========
        Item {
          Layout.fillWidth: true
          Layout.fillHeight: true
          visible: !loader.manager.isLoading && loader.manager.errorMessage !== ""
          
          ColumnLayout {
            anchors.centerIn: parent
            spacing: Theme.spacing.md
            
            Rectangle {
              Layout.alignment: Qt.AlignHCenter
              Layout.preferredWidth: 64
              Layout.preferredHeight: 64
              radius: Theme.radius.full
              color: Theme.error_container
              
              Text {
                anchors.centerIn: parent
                text: "󰀪"
                color: Theme.on_error_container
                font.pixelSize: Theme.typography.xxxl
                font.family: Theme.typography.fontFamily
              }
            }
            
            Text {
              Layout.alignment: Qt.AlignHCenter
              Layout.maximumWidth: 600
              text: loader.manager.errorMessage
              color: Theme.error
              font.pixelSize: Theme.typography.md
              font.family: Theme.typography.fontFamily
              horizontalAlignment: Text.AlignHCenter
              wrapMode: Text.WordWrap
            }
          }
        }
        
        // ========== WALLPAPER GRID ==========
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
            loader.manager.setWallpaper(filename)
          }
          
          onIndexSelected: index => {
            wallpaperWindow.selectedIndex = index
          }
        }
        
        // ========== EMPTY STATE ==========
        Item {
          Layout.fillWidth: true
          Layout.fillHeight: true
          visible: !loader.manager.isLoading && 
                   wallpaperWindow.filteredWallpapers.length === 0 && 
                   loader.manager.errorMessage === ""
          
          ColumnLayout {
            anchors.centerIn: parent
            spacing: Theme.spacing.md
            
            Rectangle {
              Layout.alignment: Qt.AlignHCenter
              Layout.preferredWidth: 64
              Layout.preferredHeight: 64
              radius: Theme.radius.full
              color: Theme.surface_container_high
              
              Text {
                anchors.centerIn: parent
                text: "󰸉"
                color: Theme.on_surface_variant
                font.pixelSize: Theme.typography.xxxl
                font.family: Theme.typography.fontFamily
                opacity: 0.6
              }
            }
            
            Text {
              Layout.alignment: Qt.AlignHCenter
              text: wallpaperWindow.searchText ? 
                    "No wallpapers found" : 
                    "No wallpapers available"
              color: Theme.on_surface
              font.pixelSize: Theme.typography.md
              font.family: Theme.typography.fontFamily
              font.weight: Theme.typography.weightMedium
              opacity: 0.8
            }
            
            Text {
              Layout.alignment: Qt.AlignHCenter
              text: wallpaperWindow.searchText ? 
                    "Try a different search term" : 
                    "Add wallpapers to " + loader.manager.wallpaperDir
              color: Theme.on_surface_variant
              font.pixelSize: Theme.typography.sm
              font.family: Theme.typography.fontFamily
              opacity: 0.6
            }
          }
        }
        
        // ========== FOOTER WITH HINT ==========
        Text {
          Layout.fillWidth: true
          text: "↑↓ Navigate • ←→ Row • Enter Select • Esc Close"
          color: Theme.on_surface_variant
          font.pixelSize: Theme.typography.sm
          font.family: Theme.typography.fontFamily
          horizontalAlignment: Text.AlignHCenter
          opacity: 0.7
          visible: !loader.manager.isLoading && wallpaperWindow.filteredWallpapers.length > 0
        }
      }
    }
  }
}
