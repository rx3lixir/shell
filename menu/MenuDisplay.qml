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
    id: menuWindow
    
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
    
    contentItem {
      focus: true
      
      Keys.onPressed: event => {
        if (event.key === Qt.Key_Escape) {
          loader.manager.visible = false
          event.accepted = true
        }
        else if (event.key === Qt.Key_Up || (event.key === Qt.Key_P && (event.modifiers & Qt.ControlModifier))) {
          if (menuList.currentIndex > 0) {
            menuList.currentIndex--
          }
          event.accepted = true
        }
        else if (event.key === Qt.Key_Down || (event.key === Qt.Key_N && (event.modifiers & Qt.ControlModifier))) {
          if (menuList.currentIndex < menuList.count - 1) {
            menuList.currentIndex++
          }
          event.accepted = true
        }
        else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
          const filteredItems = menuList.getFilteredItems()
          if (menuList.currentIndex >= 0 && menuList.currentIndex < filteredItems.length) {
            const selectedItem = filteredItems[menuList.currentIndex]
            
            // Trigger press animation on current item
            const currentItem = menuList.itemAtIndex(menuList.currentIndex)
            if (currentItem) {
              currentItem.triggerPressAnimation()
            }
            
            // Small delay before executing to show the animation
            Qt.callLater(() => {
              loader.manager.executeItem(selectedItem)
            })
          }
          event.accepted = true
        }
      }
    }
    
    // Background overlay with fade
    Rectangle {
      anchors.fill: parent
      color: Theme.scrim
      opacity: loader.manager.visible ? 0.4 : 0
      
      Behavior on opacity {
        NumberAnimation {
          duration: 200
          easing.type: Easing.OutCubic
        }
      }
      
      MouseArea {
        anchors.fill: parent
        onClicked: {
          loader.manager.visible = false
        }
      }
    }
    
    // Main container with Material 3 style
    Rectangle {
      id: menuBox
      x: (parent.width - 520) / 2
      y: (parent.height - 520) / 2
      width: 520
      height: 520
      radius: Theme.radius.xl
      color: Theme.surface_container
      border.width: 1
      border.color: Qt.lighter(Theme.surface_container, 1.3)
      
      // Entrance animation
      scale: loader.manager.visible ? 1.0 : 0.92
      opacity: loader.manager.visible ? 1.0 : 0
      
      Behavior on scale {
        NumberAnimation {
          duration: 250
          easing.type: Easing.OutCubic
        }
      }
      
      Behavior on opacity {
        NumberAnimation {
          duration: 200
          easing.type: Easing.OutCubic
        }
      }
      
      // Prevent clicks on menu from closing it
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
            text: "Menu"
            color: Theme.on_surface
            font.pixelSize: Theme.typography.xl
            font.family: Theme.typography.fontFamily
            font.weight: Theme.typography.weightMedium
          }
          
          // Close button
          Text {
            Layout.rightMargin: Theme.padding.sm
            text: "✕"
            color: Theme.on_surface
            font.pixelSize: Theme.typography.lg
            font.family: Theme.typography.fontFamily
            opacity: closeMouseArea.containsMouse ? 0.7 : 1
            
            scale: closeMouseArea.pressed ? 0.9 : 1.0
            
            Behavior on opacity {
              NumberAnimation { duration: 200 }
            }
            
            Behavior on scale {
              NumberAnimation { 
                duration: 100
                easing.type: Easing.OutCubic
              }
            }

            MouseArea {
              id: closeMouseArea
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: loader.manager.visible = false
            }
          }
        }
        
        // ========== SEARCH BAR ==========
        MenuSearchBar {
          Layout.fillWidth: true
          Layout.preferredHeight: 48
          
          onSearchChanged: text => {
            loader.manager.searchText = text
          }
        }
        
        // ========== MENU ITEMS LIST ==========
        Item {
          Layout.fillWidth: true
          Layout.fillHeight: true
          clip: true  // Clip the highlight so it doesn't go outside bounds
          
          // Selection highlight - slides between items
          Rectangle {
            id: selectionHighlight
            width: menuList.width
            height: 72
            radius: Theme.radius.xl
            color: Theme.primary_container
            visible: menuList.count > 0 && menuList.currentIndex >= 0 && menuList.currentIndex < menuList.count
            
            y: {
              if (!visible) return 0
              
              // Calculate position relative to contentY (scroll position)
              const itemY = menuList.currentIndex * (72 + Theme.spacing.xs)
              return itemY - menuList.contentY
            }
            
            // Smooth transitions
            Behavior on y {
              enabled: selectionHighlight.visible
              NumberAnimation {
                duration: 200
                easing.type: Easing.OutCubic
              }
            }
            
            Behavior on opacity {
              NumberAnimation {
                duration: 150
                easing.type: Easing.OutCubic
              }
            }
          }
          
          ListView {
            id: menuList
            anchors.fill: parent
            clip: true
            spacing: Theme.spacing.xs
            
            currentIndex: 0
            
            // Smooth scrolling
            maximumFlickVelocity: 2500
            flickDeceleration: 1500
          
          // Filtered model based on search
          model: ScriptModel {
            values: {
              const search = loader.manager.searchText.toLowerCase()
              const allItems = loader.manager.menuItems
              
              if (!search) {
                return allItems
              }
              
              const filtered = allItems.filter(item => {
                const name = (item.name || "").toLowerCase()
                const description = (item.description || "").toLowerCase()
                return name.includes(search) || description.includes(search)
              })
              
              return filtered
            }
          }
          
          onCountChanged: {
            // Reset to first item when results change
            if (count > 0 && currentIndex >= count) {
              currentIndex = 0
            } else if (count === 0) {
              currentIndex = -1
            }
          }
          
          onCurrentIndexChanged: {
            if (currentIndex >= 0 && currentIndex < count) {
              positionViewAtIndex(currentIndex, ListView.Contain)
            }
          }
          
          function getFilteredItems() {
            return model.values
          }
          
          // Staggered entrance animation
          add: Transition {
            NumberAnimation {
              properties: "opacity"
              from: 0
              to: 1
              duration: 200
              easing.type: Easing.OutCubic
            }
            NumberAnimation {
              properties: "x"
              from: -20
              duration: 250
              easing.type: Easing.OutCubic
            }
          }
          
          // Smooth removal
          remove: Transition {
            NumberAnimation {
              properties: "opacity"
              to: 0
              duration: 150
              easing.type: Easing.InCubic
            }
          }
          
          // Smooth move when filtering
          move: Transition {
            NumberAnimation {
              properties: "y"
              duration: 200
              easing.type: Easing.OutCubic
            }
          }
          
          delegate: MenuItem {
            required property var modelData
            required property int index
            
            width: menuList.width
            height: 72
            item: modelData
            isSelected: index === menuList.currentIndex
            
            onClicked: {
              menuList.currentIndex = index
            }
            
            onActivated: {
              loader.manager.executeItem(modelData)
            }
          }
          
          // Empty state
          Text {
            anchors.centerIn: parent
            text: loader.manager.searchText ? "No items found" : "No menu items available"
            color: Theme.on_surface_variant
            font.pixelSize: Theme.typography.md
            font.family: Theme.typography.fontFamily
            opacity: menuList.count === 0 ? 0.7 : 0
            
            Behavior on opacity {
              NumberAnimation {
                duration: 200
                easing.type: Easing.OutCubic
              }
            }
          }
        }
      }
        
        // ========== FOOTER WITH HINT ==========
        Text {
          Layout.fillWidth: true
          text: "↑↓ Navigate • Enter Select • Esc Close"
          color: Theme.on_surface_variant
          font.pixelSize: Theme.typography.sm
          font.family: Theme.typography.fontFamily
          horizontalAlignment: Text.AlignHCenter
          opacity: 0.7
        }
      }
    }
  }
}
