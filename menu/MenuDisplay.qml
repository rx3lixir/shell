import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import "../theme"

LazyLoader {
  id: loader
  
  required property var manager
  
  // Load when visible
  active: manager.visible
  
  PanelWindow {
    id: menuWindow
    
    // Fill screen - menu box will be centered inside
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
      console.log("=== MENU WINDOW LOADED ===")
      exclusiveZone = 0
    }
    
    // Handle keyboard shortcuts
    contentItem {
      focus: true
      
      Keys.onPressed: event => {
        console.log("Key pressed in menu:", event.key)
        
        if (event.key === Qt.Key_Escape) {
          console.log("Escape pressed - closing menu")
          loader.manager.visible = false
          event.accepted = true
        }
        else if (event.key === Qt.Key_Up || (event.key === Qt.Key_P && (event.modifiers & Qt.ControlModifier))) {
          console.log("Up navigation (↑ or Ctrl+P)")
          if (menuList.currentIndex > 0) {
            menuList.currentIndex--
          }
          event.accepted = true
        }
        else if (event.key === Qt.Key_Down || (event.key === Qt.Key_N && (event.modifiers & Qt.ControlModifier))) {
          console.log("Down navigation (↓ or Ctrl+N)")
          if (menuList.currentIndex < menuList.count - 1) {
            menuList.currentIndex++
          }
          event.accepted = true
        }
        else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
          console.log("Enter pressed - executing item")
          const filteredItems = menuList.getFilteredItems()
          if (menuList.currentIndex >= 0 && menuList.currentIndex < filteredItems.length) {
            const selectedItem = filteredItems[menuList.currentIndex]
            loader.manager.executeItem(selectedItem)
          }
          event.accepted = true
        }
      }
    }
    
      
    MouseArea {
      anchors.fill: parent
      onClicked: {
        console.log("Background clicked - closing menu")
        loader.manager.visible = false
      }
    }
    
    // Menu box - centered
    Rectangle {
      id: menuBox
      x: (parent.width - 500) / 2
      y: (parent.height - 480) / 2
      width: 500
      height: 480
      radius: Theme.radiusXLarge
      color: Theme.bg1transparentLauncher
      
      // Prevent clicks on menu from closing it
      MouseArea {
        anchors.fill: parent
        onClicked: {
          console.log("Menu box clicked (preventing close)")
        }
      }
      
      ColumnLayout {
        anchors {
          fill: parent
          margins: Theme.spacingL
        }
        spacing: Theme.spacingM
        
        // Search bar
        MenuSearchBar {
          Layout.fillWidth: true
          Layout.preferredHeight: 40
          
          onSearchChanged: text => {
            loader.manager.searchText = text
          }
        }
        
        // Menu items list
        ListView {
          id: menuList
          Layout.fillWidth: true
          Layout.fillHeight: true
          clip: true
          spacing: Theme.spacingS
          
          currentIndex: 0
          
          // Filtered model based on search
          model: ScriptModel {
            values: {
              console.log("=== FILTERING MENU ITEMS ===")
              const search = loader.manager.searchText.toLowerCase()
              console.log("Search term:", search)
              
              const allItems = loader.manager.menuItems
              console.log("Total items:", allItems.length)
              
              if (!search) {
                console.log("No search term, showing all items")
                return allItems
              }
              
              const filtered = allItems.filter(item => {
                const name = (item.name || "").toLowerCase()
                const description = (item.description || "").toLowerCase()
                return name.includes(search) || description.includes(search)
              })
              
              console.log("Filtered items:", filtered.length)
              return filtered
            }
          }
          
          // Keep current item visible
          onCurrentIndexChanged: {
            positionViewAtIndex(currentIndex, ListView.Contain)
          }
          
          // Helper function to get filtered items
          function getFilteredItems() {
            return model.values
          }
          
          delegate: MenuItem {
            required property var modelData
            required property int index
            
            width: menuList.width
            height: 70
            item: modelData
            isSelected: index === menuList.currentIndex
            
            onClicked: {
              menuList.currentIndex = index
            }
            
            onActivated: {
              console.log("Item activated:", modelData.name)
              loader.manager.executeItem(modelData)
            }
          }
          
          // Empty state
          Text {
            anchors.centerIn: parent
            text: loader.manager.searchText ? "No items found" : "No menu items available"
            color: Theme.fgMuted
            font.pixelSize: Theme.fontSizeM
            font.family: Theme.fontFamily
            visible: menuList.count === 0
          }
        }
        
        // Footer with hint
        Text {
          Layout.fillWidth: true
          text: " Navigate • Enter Select • Esc Close"
          color: Theme.fgMuted
          font.pixelSize: Theme.fontSizeS
          font.family: Theme.fontFamily
          horizontalAlignment: Text.AlignHCenter
        }
      }
    }
  }
}
