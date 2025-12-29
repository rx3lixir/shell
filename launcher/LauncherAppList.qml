import QtQuick
import Quickshell
import "../theme"

Rectangle {
  id: root
  
  property string searchTerm: ""
  property int currentIndex: 0
  signal appLaunched()
  
  radius: Theme.radiusXLarge
  color: "transparent"
  
  // Reset index when search changes
  onSearchTermChanged: {
    currentIndex = 0
  }
  
  ListView {
    id: appList
    anchors.fill: parent
    clip: true
    spacing: Theme.spacingS
    
    // Bind current index for keyboard navigation
    currentIndex: root.currentIndex
    
    // Keep current item visible
    onCurrentIndexChanged: {
      positionViewAtIndex(currentIndex, ListView.Contain)
    }
    
    model: ScriptModel {
      values: {
        const search = root.searchTerm.toLowerCase()
        
        const allApps = DesktopEntries.applications.values
        
        if (!search) {
          return allApps
        }
        
        const filtered = allApps.filter(app => {
          if (app.hidden) return false
          const name = (app.name || "").toLowerCase()
          const comment = (app.comment || "").toLowerCase()
          return name.includes(search) || comment.includes(search)
        })
        
        return filtered
      }
    }
    
    delegate: LauncherAppItem {
      required property var modelData
      required property int index
      
      width: appList.width
      height: 50
      app: modelData
      isSelected: index === root.currentIndex
      
      onLaunched: {
        root.appLaunched()
      }
      
      onClicked: {
        root.currentIndex = index
      }
    }
    
    // Empty state
    Text {
      anchors.centerIn: parent
      text: root.searchTerm ? "No apps found" : "No applications available"
      color: Theme.fgMuted
      font.pixelSize: Theme.fontSizeM
      font.family: Theme.fontFamily
      visible: appList.count === 0
    }
  }
  
  // Helper function to get the filtered apps (for Enter key handling)
  function getFilteredApps() {
    return appList.model.values
  }
  
  // Navigation functions
  function moveUp() {
    if (root.currentIndex > 0) {
      root.currentIndex--
    }
  }
  
  function moveDown() {
    const maxIndex = appList.count - 1
    if (root.currentIndex < maxIndex) {
      root.currentIndex++
    }
  }
  
  function getCurrentApp() {
    const apps = getFilteredApps()
    if (root.currentIndex >= 0 && root.currentIndex < apps.length) {
      return apps[root.currentIndex]
    }
    return null
  }
}
