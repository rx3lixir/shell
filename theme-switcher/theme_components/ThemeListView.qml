import QtQuick
import "../../theme"

ListView {
  id: listView
  
  // Properties
  property var themes: []
  property int selectedIndex: 0
  property string currentTheme: ""
  
  // Signals
  signal themeSelected(string themeName)
  signal indexSelected(int index)
  
  clip: true
  spacing: Theme.spacingS
  
  model: themes
  
  currentIndex: selectedIndex
  
  // Keep current item visible
  onCurrentIndexChanged: {
    positionViewAtIndex(currentIndex, ListView.Contain)
  }
  
  // Function to position view at index (exposed for keyboard nav)
  function positionViewAtIndex(index, mode) {
    ListView.positionViewAtIndex(index, mode)
  }
  
  delegate: ThemeListItem {
    required property string modelData
    required property int index
    
    width: listView.width
    height: 80
    
    themeName: modelData
    isSelected: index === listView.selectedIndex
    isCurrent: listView.currentTheme === modelData
    
    onClicked: {
      listView.indexSelected(index)
      listView.themeSelected(modelData)
    }
  }
}
