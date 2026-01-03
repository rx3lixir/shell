import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import "../theme"
import "emoji_components" as Components

LazyLoader {
  id: loader
  
  required property var manager
  
  active: manager.visible
  
  PanelWindow {
    id: emojiWindow
    
    // Fill screen - emoji picker will be centered
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
      console.log("[EmojiDisplay] Window loaded")
      exclusiveZone = 0
    }
    
    // Search and selection state
    property string searchText: ""
    property int selectedIndex: 0
    property var filteredEmojis: []
    
    // Filter emojis based on search and group
    function updateFilteredEmojis() {
      var search = emojiWindow.searchText.toLowerCase()
      var group = loader.manager.selectedGroup
      
      var filtered = []
      
      for (var i = 0; i < loader.manager.emojis.length; i++) {
        var emoji = loader.manager.emojis[i]
        
        // Filter by group if selected
        if (group && emoji.group !== group) {
          continue
        }
        
        // Filter by search
        if (search) {
          // Search in name and keywords
          if (!emoji.keywords.includes(search)) {
            continue
          }
        }
        
        filtered.push(emoji)
      }
      
      emojiWindow.filteredEmojis = filtered
      emojiWindow.selectedIndex = 0
      
      console.log("[EmojiDisplay] Filtered:", filtered.length, "emojis")
    }
    
    // Update filtered list when emojis or filters change
    Connections {
      target: loader.manager
      function onEmojisChanged() {
        emojiWindow.updateFilteredEmojis()
      }
      function onSelectedGroupChanged() {
        emojiWindow.updateFilteredEmojis()
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
          // Select current emoji
          if (emojiWindow.selectedIndex >= 0 && 
              emojiWindow.selectedIndex < emojiWindow.filteredEmojis.length) {
            var selected = emojiWindow.filteredEmojis[emojiWindow.selectedIndex]
            console.log("[EmojiDisplay] Selected via Enter:", selected.emoji)
            loader.manager.copyEmoji(selected.emoji)
          }
          event.accepted = true
        }
        else if (event.key === Qt.Key_Up) {
          // Move up by columns (6 per row)
          if (emojiWindow.selectedIndex >= 6) {
            emojiWindow.selectedIndex -= 6
            gridView.positionViewAtIndex(emojiWindow.selectedIndex, GridView.Contain)
          }
          event.accepted = true
        }
        else if (event.key === Qt.Key_Down) {
          // Move down by columns (6 per row)
          if (emojiWindow.selectedIndex + 6 < emojiWindow.filteredEmojis.length) {
            emojiWindow.selectedIndex += 6
            gridView.positionViewAtIndex(emojiWindow.selectedIndex, GridView.Contain)
          }
          event.accepted = true
        }
        else if (event.key === Qt.Key_Left) {
          // Move left
          if (emojiWindow.selectedIndex > 0) {
            emojiWindow.selectedIndex--
            gridView.positionViewAtIndex(emojiWindow.selectedIndex, GridView.Contain)
          }
          event.accepted = true
        }
        else if (event.key === Qt.Key_Right) {
          // Move right
          if (emojiWindow.selectedIndex < emojiWindow.filteredEmojis.length - 1) {
            emojiWindow.selectedIndex++
            gridView.positionViewAtIndex(emojiWindow.selectedIndex, GridView.Contain)
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
      x: (parent.width - 700) / 2
      y: (parent.height - 600) / 2
      width: 700
      height: 600
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
            text: "Emoji Picker"
            color: Theme.fg
            font.pixelSize: Theme.fontSizeL
            font.family: Theme.fontFamily
            font.bold: true
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
        Components.EmojiSearchBar {
          Layout.fillWidth: true
          Layout.preferredHeight: 40
          
          onSearchChanged: text => {
            emojiWindow.searchText = text
            emojiWindow.updateFilteredEmojis()
          }
        }
        
        // Group filter buttons (horizontal scroll)
        Components.EmojiGroupFilter {
          Layout.fillWidth: true
          Layout.preferredHeight: 40
          
          groups: loader.manager.emojiGroups
          selectedGroup: loader.manager.selectedGroup
          
          onGroupSelected: group => {
            loader.manager.selectedGroup = group
          }
        }
        
        // Loading indicator
        Text {
          Layout.fillWidth: true
          Layout.alignment: Qt.AlignCenter
          text: "Loading emojis..."
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
        
        // Emoji grid
        Components.EmojiGridView {
          id: gridView
          Layout.fillWidth: true
          Layout.fillHeight: true
          
          visible: !loader.manager.isLoading && loader.manager.errorMessage === ""
          
          emojis: emojiWindow.filteredEmojis
          selectedIndex: emojiWindow.selectedIndex
          
          onEmojiSelected: emoji => {
            console.log("[EmojiDisplay] Selected via click:", emoji)
            loader.manager.copyEmoji(emoji)
          }
          
          onIndexSelected: index => {
            emojiWindow.selectedIndex = index
          }
        }
        
        // Empty state
        Text {
          Layout.fillWidth: true
          Layout.fillHeight: true
          text: emojiWindow.searchText ? 
                "No emojis match '" + emojiWindow.searchText + "'" : 
                "No emojis found"
          color: Theme.fgMuted
          font.pixelSize: Theme.fontSizeM
          font.family: Theme.fontFamily
          horizontalAlignment: Text.AlignHCenter
          verticalAlignment: Text.AlignVCenter
          visible: !loader.manager.isLoading && 
                   emojiWindow.filteredEmojis.length === 0 && 
                   loader.manager.errorMessage === ""
        }
        
        // Footer hint
        Text {
          Layout.fillWidth: true
          text: "Arrow keys Navigate • Enter Copy • Esc Close"
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
