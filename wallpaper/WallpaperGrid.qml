import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import "../theme"

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
            wallpaperGrid.positionViewAtIndex(wallpaperWindow.selectedIndex, GridView.Contain)
          }
          event.accepted = true
        }
        else if (event.key === Qt.Key_Down || (event.key === Qt.Key_N && (event.modifiers & Qt.ControlModifier))) {
          // Move down (right in grid)
          if (wallpaperWindow.selectedIndex < wallpaperWindow.filteredWallpapers.length - 1) {
            wallpaperWindow.selectedIndex++
            wallpaperGrid.positionViewAtIndex(wallpaperWindow.selectedIndex, GridView.Contain)
          }
          event.accepted = true
        }
        else if (event.key === Qt.Key_Left) {
          // Move left by 3 (one row up)
          if (wallpaperWindow.selectedIndex >= 3) {
            wallpaperWindow.selectedIndex -= 3
            wallpaperGrid.positionViewAtIndex(wallpaperWindow.selectedIndex, GridView.Contain)
          }
          event.accepted = true
        }
        else if (event.key === Qt.Key_Right) {
          // Move right by 3 (one row down)
          if (wallpaperWindow.selectedIndex + 3 < wallpaperWindow.filteredWallpapers.length) {
            wallpaperWindow.selectedIndex += 3
            wallpaperGrid.positionViewAtIndex(wallpaperWindow.selectedIndex, GridView.Contain)
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
        Rectangle {
          Layout.fillWidth: true
          Layout.preferredHeight: 40
          radius: Theme.radiusLarge
          color: Theme.bg2transparent
          border.color: searchInput.activeFocus ? Theme.accent : "transparent"
          border.width: 2
          
          TextInput {
            id: searchInput
            anchors {
              fill: parent
              leftMargin: Theme.spacingM
              rightMargin: Theme.spacingM
            }
            verticalAlignment: TextInput.AlignVCenter
            color: Theme.fg
            font.pixelSize: Theme.fontSizeM
            font.family: Theme.fontFamily
            
            // Placeholder
            Text {
              anchors.fill: parent
              text: "Search wallpapers..."
              color: Theme.fgMuted
              font: parent.font
              verticalAlignment: Text.AlignVCenter
              visible: !parent.text
            }
            
            onTextChanged: {
              wallpaperWindow.searchText = text
              wallpaperWindow.updateFilteredWallpapers()
            }
            
            Component.onCompleted: {
              forceActiveFocus()
            }
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
        
        // Wallpaper grid - 3 columns, bigger cells
        GridView {
          id: wallpaperGrid
          Layout.fillWidth: true
          Layout.fillHeight: true
          clip: true
          
          cellWidth: 280
          cellHeight: 200
          
          visible: !loader.manager.isLoading && loader.manager.errorMessage === ""
          
          model: wallpaperWindow.filteredWallpapers
          
          currentIndex: wallpaperWindow.selectedIndex
          
          delegate: Item {
            required property string modelData
            required property int index
            
            width: wallpaperGrid.cellWidth
            height: wallpaperGrid.cellHeight
            
            Rectangle {
              anchors {
                fill: parent
                margins: Theme.spacingS
              }
              radius: Theme.radiusLarge
              color: {
                if (index === wallpaperWindow.selectedIndex) return Theme.accent
                if (itemMouseArea.containsMouse) return Theme.bg2
                return Theme.bg2transparent
              }
              border.color: loader.manager.currentWallpaper === modelData ? Theme.accent : "transparent"
              border.width: 3
              
              Behavior on color {
                ColorAnimation {
                  duration: 150
                  easing.type: Easing.OutCubic
                }
              }
              
              ColumnLayout {
                anchors {
                  fill: parent
                  margins: Theme.spacingS
                }
                spacing: Theme.spacingS
                
                // Image preview
                Rectangle {
                  Layout.fillWidth: true
                  Layout.fillHeight: true
                  radius: Theme.radiusMedium
                  color: Theme.bg1
                  clip: true
                  
                  Image {
                    anchors.fill: parent
                    source: "file://" + loader.manager.wallpaperDir + "/" + modelData
                    fillMode: Image.PreserveAspectCrop
                    smooth: true
                    cache: true
                    asynchronous: true
                    
                    // Use lower source size for faster loading (thumbnail quality)
                    sourceSize.width: 280
                    sourceSize.height: 200
                    
                    // Loading indicator
                    Rectangle {
                      anchors.centerIn: parent
                      width: 32
                      height: 32
                      radius: 16
                      color: Theme.accentTransparent
                      visible: parent.status === Image.Loading
                      
                      Text {
                        anchors.centerIn: parent
                        text: "⏳"
                        color: Theme.fg
                        font.pixelSize: Theme.fontSizeM
                        font.family: Theme.fontFamily
                      }
                    }
                    
                    // Error indicator
                    Text {
                      anchors.centerIn: parent
                      text: "❌ Failed"
                      color: Theme.error
                      font.pixelSize: Theme.fontSizeS
                      font.family: Theme.fontFamily
                      visible: parent.status === Image.Error
                    }
                  }
                  
                  // Current wallpaper indicator
                  Rectangle {
                    anchors {
                      top: parent.top
                      right: parent.right
                      margins: Theme.spacingS
                    }
                    width: 28
                    height: 28
                    radius: 14
                    color: Theme.accent
                    visible: loader.manager.currentWallpaper === modelData
                    
                    Text {
                      anchors.centerIn: parent
                      text: "✓"
                      color: Theme.bg1
                      font.pixelSize: Theme.fontSizeM
                      font.family: Theme.fontFamily
                      font.bold: true
                    }
                  }
                  
                  // Selected indicator (keyboard nav)
                  Rectangle {
                    anchors {
                      top: parent.top
                      left: parent.left
                      margins: Theme.spacingS
                    }
                    width: 28
                    height: 28
                    radius: 14
                    color: Theme.accent
                    visible: index === wallpaperWindow.selectedIndex && 
                             loader.manager.currentWallpaper !== modelData
                    
                    Text {
                      anchors.centerIn: parent
                      text: "→"
                      color: Theme.bg1
                      font.pixelSize: Theme.fontSizeM
                      font.family: Theme.fontFamily
                      font.bold: true
                    }
                  }
                }
                
                // Filename
                Text {
                  Layout.fillWidth: true
                  text: modelData
                  color: {
                    if (index === wallpaperWindow.selectedIndex) return Theme.bg1
                    if (loader.manager.currentWallpaper === modelData) return Theme.accent
                    return Theme.fg
                  }
                  font.pixelSize: Theme.fontSizeS
                  font.family: Theme.fontFamily
                  elide: Text.ElideMiddle
                  horizontalAlignment: Text.AlignHCenter
                  
                  Behavior on color {
                    ColorAnimation {
                      duration: 150
                      easing.type: Easing.OutCubic
                    }
                  }
                }
              }
              
              MouseArea {
                id: itemMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                
                onClicked: {
                  wallpaperWindow.selectedIndex = index
                  console.log("[WallpaperGrid] Selected via click:", modelData)
                  loader.manager.setWallpaper(modelData)
                }
              }
            }
          }
          
          // Scrollbar
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
            visible: wallpaperGrid.contentHeight > wallpaperGrid.height
            
            Rectangle {
              anchors.fill: parent
              radius: parent.radius
              color: Theme.borderDim
              opacity: 0.2
            }
            
            Rectangle {
              width: parent.width
              height: {
                if (wallpaperGrid.contentHeight <= wallpaperGrid.height) return 0
                return Math.max(30, parent.height * (wallpaperGrid.height / wallpaperGrid.contentHeight))
              }
              y: {
                if (wallpaperGrid.contentHeight <= wallpaperGrid.height) return 0
                var maxY = parent.height - height
                var progress = wallpaperGrid.contentY / (wallpaperGrid.contentHeight - wallpaperGrid.height)
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
