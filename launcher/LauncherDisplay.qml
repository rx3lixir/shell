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
    id: launcherWindow
    
    // Fill screen - the launcher box will be centered inside
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
      console.log("=== LAUNCHER WINDOW LOADED ===")
      exclusiveZone = 0
    }
    
    // Focus management - handle keyboard shortcuts
    contentItem {
      focus: true
      
      Keys.onPressed: event => {
        console.log("Key pressed:", event.key)
        
        if (event.key === Qt.Key_Escape) {
          console.log("Escape pressed - closing launcher")
          loader.manager.visible = false
          event.accepted = true
        } 
        else if (event.key === Qt.Key_Up) {
          console.log("Up arrow pressed")
          appListComponent.moveUp()
          event.accepted = true
        }
        else if (event.key === Qt.Key_Down) {
          console.log("Down arrow pressed")
          appListComponent.moveDown()
          event.accepted = true
        }
        else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
          console.log("Enter pressed - launching selected app")
          event.accepted = true
          
          const selectedApp = appListComponent.getCurrentApp()
          
          if (selectedApp) {
            console.log("Launching app:", selectedApp.name)
            console.log("Command:", selectedApp.command)
            
            try {
              console.log("Calling execute()...")
              selectedApp.execute()
              console.log("App launched successfully via Enter!")
              loader.manager.visible = false
            } catch (error) {
              console.error("Failed to launch app via Enter:", error)
              
              // Fallback
              try {
                console.log("Trying fallback with execDetached...")
                Quickshell.execDetached({
                  command: selectedApp.command,
                  workingDirectory: selectedApp.workingDirectory || ""
                })
                console.log("Fallback successful!")
                loader.manager.visible = false
              } catch (fallbackError) {
                console.error("Fallback failed:", fallbackError)
              }
            }
          } else {
            console.log("No app selected to launch")
          }
        }
      }
    }
    
    Rectangle {
      id: background
      x: (parent.width - 600) / 2
      y: (parent.height - 400) / 2
      width: 600
      height: 400
      radius: Theme.radiusXLarge
      color: Theme.bg1transparentLauncher
      
      // Catch clicks on the launcher itself to prevent closing
      MouseArea {
        anchors.fill: parent
        onClicked: {
          console.log("Launcher box clicked (preventing background close)")
        }
      }
      
      ColumnLayout {
        anchors {
          fill: parent
          margins: Theme.spacingL
        }
        spacing: Theme.spacingM
        
        // Search bar
        LauncherSearchBar {
          Layout.fillWidth: true
          Layout.preferredHeight: 40
          
          onSearchChanged: text => {
            loader.manager.searchText = text
          }
        }
        
        // App list
        LauncherAppList {
          id: appListComponent
          Layout.fillWidth: true
          Layout.fillHeight: true
          
          searchTerm: loader.manager.searchText
          
          onAppLaunched: {
            loader.manager.visible = false
          }
        }
        
        // Footer with hint
        Text {
          Layout.fillWidth: true
          text: "↑↓ Navigate • Enter Launch • Esc Close"
          color: Theme.fgMuted
          font.pixelSize: Theme.fontSizeS
          font.family: Theme.fontFamily
          horizontalAlignment: Text.AlignHCenter
        }
      }
      
      // Click outside to close
      MouseArea {
        anchors.fill: parent
        z: -1
        onClicked: {
          console.log("Background clicked - closing launcher")
          loader.manager.visible = false
        }
      }
    }
  }
}
