import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import "../theme"
import "theme_components" as Components

LazyLoader {
  id: loader
  
  required property var manager
  
  active: manager.visible
  
  PanelWindow {
    id: themeWindow
    
    // Fill screen - theme picker will be centered
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
    
    // Selection state
    property int selectedIndex: 0
    property var filteredThemes: []
    
    // Filter themes based on search
    function updateFilteredThemes() {
      var search = themeWindow.searchText.toLowerCase()
      
      if (!search) {
        themeWindow.filteredThemes = loader.manager.themes
      } else {
        var filtered = []
        for (var i = 0; i < loader.manager.themes.length; i++) {
          var themeName = loader.manager.themes[i].toLowerCase()
          if (themeName.includes(search)) {
            filtered.push(loader.manager.themes[i])
          }
        }
        themeWindow.filteredThemes = filtered
      }
      
      themeWindow.selectedIndex = 0
    }
    
    property string searchText: ""
    
    onSearchTextChanged: {
      updateFilteredThemes()
    }
    
    // Update filtered list when themes change
    Connections {
      target: loader.manager
      function onThemesChanged() {
        themeWindow.updateFilteredThemes()
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
          if (themeWindow.selectedIndex >= 0 && 
              themeWindow.selectedIndex < themeWindow.filteredThemes.length) {
            var selected = themeWindow.filteredThemes[themeWindow.selectedIndex]
            loader.manager.applyTheme(selected)
          }
          event.accepted = true
        }
        else if (event.key === Qt.Key_Up || (event.key === Qt.Key_P && (event.modifiers & Qt.ControlModifier))) {
          if (themeWindow.selectedIndex > 0) {
            themeWindow.selectedIndex--
            themeListView.positionViewAtIndex(themeWindow.selectedIndex, ListView.Contain)
          }
          event.accepted = true
        }
        else if (event.key === Qt.Key_Down || (event.key === Qt.Key_N && (event.modifiers & Qt.ControlModifier))) {
          if (themeWindow.selectedIndex < themeWindow.filteredThemes.length - 1) {
            themeWindow.selectedIndex++
            themeListView.positionViewAtIndex(themeWindow.selectedIndex, ListView.Contain)
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
    
    // Main container - centered
    Rectangle {
      id: container
      x: (parent.width - 400) / 2
      y: (parent.height - 440) / 2
      width: 400
      height: 440
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
            text: "Theme Switcher"
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
                loader.manager.refreshThemes()
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
        Components.ThemeSearchBar {
          Layout.fillWidth: true
          Layout.preferredHeight: 40
          
          onSearchChanged: text => {
            themeWindow.searchText = text
          }
        }
        
        // Loading indicator
        Text {
          Layout.fillWidth: true
          Layout.alignment: Qt.AlignCenter
          text: "Loading themes..."
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
        
        // Theme list
        Components.ThemeListView {
          id: themeListView
          Layout.fillWidth: true
          Layout.fillHeight: true
          
          visible: !loader.manager.isLoading && loader.manager.errorMessage === ""
          
          themes: themeWindow.filteredThemes
          selectedIndex: themeWindow.selectedIndex
          currentTheme: loader.manager.currentTheme
          
          onThemeSelected: themeName => {
            loader.manager.applyTheme(themeName)
          }
          
          onIndexSelected: index => {
            themeWindow.selectedIndex = index
          }
        }
        
        // Empty state
        Text {
          Layout.fillWidth: true
          Layout.fillHeight: true
          text: themeWindow.searchText ? 
                "No themes match '" + themeWindow.searchText + "'" : 
                "No themes found in " + loader.manager.themesDir
          color: Theme.fgMuted
          font.pixelSize: Theme.fontSizeM
          font.family: Theme.fontFamily
          horizontalAlignment: Text.AlignHCenter
          verticalAlignment: Text.AlignVCenter
          visible: !loader.manager.isLoading && 
                   themeWindow.filteredThemes.length === 0 && 
                   loader.manager.errorMessage === ""
        }
        
        // Footer hint
        Text {
          Layout.fillWidth: true
          text: "↑↓ Navigate • Ctrl+N/P • Enter Apply • Esc Close"
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
